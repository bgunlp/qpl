package com.beneyal.qpl

import com.beneyal.qpl.domain.*
import com.beneyal.qpl.domain.RelOpType.*
import com.beneyal.qpl.domain.ScalarOperator.*

import scala.util.Try
import scala.xml.*
import zio.Chunk

object parsing {
  def parseExecutionPlan(elem: Elem): Try[ExecutionPlan] = {
    val stmt  = elem \\ "StmtSimple"
    val query = stmt \@ "StatementText"
    val relop = (elem \\ "RelOp").head
    val params = (elem \\ "ParameterList").headOption
      .map(_.child.map(parseColumnReference).to(Chunk))
      .getOrElse(Chunk.empty)
    Try(ExecutionPlan(query, parseRelOp(relop), params))
  }

  private def parseRelOp(node: Node): RelOp = {
    val logicalOp  = node \@ "LogicalOp"
    val physicalOp = node \@ "PhysicalOp"
    val outputList = (node \ "OutputList").head.child.map(parseColumnReference)

    val operation = (logicalOp, physicalOp) match {
      case ("Compute Scalar", "Compute Scalar") =>
        parseComputeScalar((node \ "ComputeScalar").head)
      case ("Concatenation", "Concatenation") =>
        parseConcat((node \ "Concat").head)
      case ("Filter", "Filter") | ("Assert", "Assert") =>
        parseFilter((node \ logicalOp).head)
      case ("Inner Join", "Hash Match") =>
        parseHashJoin((node \ "Hash").head)
      case ("Aggregate", "Hash Match") =>
        parseHashAggregate((node \ "Hash").head)
      case (s"$dir Anti Semi Join", "Hash Match") =>
        if (dir == "Left") parseHashExcept((node \ "Hash").head, Direction.Left)
        else parseHashExcept((node \ "Hash").head, Direction.Right)
      case ("Clustered Index Scan", "Clustered Index Scan") | ("Clustered Index Seek", "Clustered Index Seek") |
          ("Index Scan", "Index Scan") | ("Index Seek", "Index Seek") =>
        parseIndexScan((node \ "IndexScan").head)
      case ("Union", "Merge Join") | ("Concatenation", "Merge Join") =>
        parseMergeUnion((node \ "Merge").head)
      case ("Inner Join", "Merge Join") | ("Left Semi Join", "Merge Join") =>
        parseMergeJoin((node \ "Merge").head)
      case (s"$dir Anti Semi Join", "Merge Join") =>
        if (dir == "Left") parseMergeExcept((node \ "Merge").head, Direction.Left)
        else parseMergeExcept((node \ "Merge").head, Direction.Right)
      case ("Inner Join", "Nested Loops") =>
        parseNestedLoopsJoin((node \ "NestedLoops").head)
      case ("Left Anti Semi Join", "Nested Loops") =>
        parseNestedLoopsExcept((node \ "NestedLoops").head)
      case ("Left Semi Join", "Nested Loops") =>
        parseIntersect((node \ "NestedLoops").head)
      case (s"$dir Semi Join", "Hash Match") =>
        if (dir == "Left") parseHashIntersect((node \ "Hash").head, Direction.Left)
        else parseHashIntersect((node \ "Hash").head, Direction.Right)
      case ("Union", "Hash Match") =>
        parseHashUnion((node \ "Hash").head)
      case ("Lazy Spool", "Table Spool") | ("Eager Spool", "Table Spool") | ("Eager Spool", "Index Spool") =>
        val spoolNode  = (node \ "Spool").head
        val maybeRelop = (spoolNode \ "RelOp").headOption
        maybeRelop.map(_ => parseSpool(spoolNode)).getOrElse(EmptySpool)
      case ("Lazy Spool", "Row Count Spool") =>
        parseSpool((node \ "RowCountSpool").head)
      case ("Distinct Sort", "Sort") | ("Sort", "Sort") =>
        parseSort((node \ "Sort").head)
      case ("Aggregate", "Stream Aggregate") =>
        parseStreamAggregate((node \ "StreamAggregate").head)
      case ("Table Scan", "Table Scan") =>
        if ((node \ "TableScan").nonEmpty) parseTableScan((node \ "TableScan").head)
        else parseIndexScan((node \ "IndexScan").head)
      case ("Top", "Top") =>
        parseTop((node \ "Top").head)
      case ("TopN Sort", "Sort") =>
        parseTopSort((node \ "TopSort").head)
      case _ =>
        throw new RuntimeException(s"Unknown RelOp combo: ($logicalOp, $physicalOp)")
    }

    RelOp(operation, outputList.to(Chunk))
  }

  private def parseComputeScalar(node: Node): ComputeScalar = {
    val relop           = parseRelOp((node \ "RelOp").head)
    val definedValues   = parseDefinedValues(node)
    val computeSequence = Option(node \@ "ComputeSequence").filter(_.nonEmpty).map(_ == "1")
    ComputeScalar(relop, computeSequence, definedValues)
  }

  private def parseStreamAggregate(node: Node): StreamAggregate = {
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    val groupBy       = (node \ "GroupBy").headOption.map(parseGroupBy).getOrElse(Chunk.empty)
    StreamAggregate(relop, groupBy, definedValues)
  }

  private def parseIndexScan(node: Node): IndexScan = {
    def parseScanRange(node: Node): ScanRange = {
      val scanType         = node \@ "ScanType"
      val rangeColumns     = (node \ "RangeColumns" \ "ColumnReference").map(parseColumnReference)
      val rangeExpressions = (node \ "RangeExpressions" \ "ScalarOperator").map(parseScalarOperator)
      ScanRange(
        ComparisonOperation.valueOf(scanType),
        rangeColumns.to(Chunk),
        rangeExpressions.to(Chunk)
      )
    }

    def parseSeekPredicate(node: Node): SeekPredicate = {
      val prefix     = (node \ "Prefix").headOption.map(parseScanRange)
      val startRange = (node \ "StartRange").headOption.map(parseScanRange)
      val endRange   = (node \ "EndRange").headOption.map(parseScanRange)
      SeekPredicate(prefix, startRange, endRange)
    }

    val obj           = parseObject((node \ "Object").head)
    val definedValues = parseDefinedValues(node)
    val ordered       = (node \@ "Ordered") == "true"
    val seekPredicate = (node \ "SeekPredicates" \ "SeekPredicateNew" \ "SeekKeys").headOption.map(parseSeekPredicate)
    val predicate     = (node \ "Predicate").map(parsePredicate).headOption
    IndexScan(ordered, obj, seekPredicate, predicate, definedValues)
  }

  private def parseSort(node: Node): Sort = {
    val distinct      = node \@ "Distinct" == "1"
    val orderBy       = parseOrderBy((node \ "OrderBy").head)
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    Sort(distinct, orderBy, relop, definedValues)
  }

  private def parseNestedLoopsJoin(node: Node): NestedLoopsJoin = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    val predicate     = (node \ "Predicate").headOption.map(parsePredicate)
    NestedLoopsJoin(top, bottom, predicate, definedValues)
  }

  private def parseNestedLoopsExcept(node: Node): NestedLoopsExcept = {
    val relops          = node \ "RelOp"
    val top             = parseRelOp(relops(0))
    val bottom          = parseRelOp(relops(1))
    val definedValues   = parseDefinedValues(node)
    val predicate       = (node \ "Predicate").headOption.map(parsePredicate)
    val outerReferences = (node \ "OuterReferences" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    NestedLoopsExcept(top, bottom, predicate, outerReferences, definedValues)
  }

  private def parseIntersect(node: Node): Intersect = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    val predicate     = (node \ "Predicate").headOption.map(parsePredicate)
    Intersect(top, bottom, predicate, definedValues)
  }

  private def parseFilter(node: Node): Filter = {
    val startupExpression = node \@ "StartupExpression" == "1"
    val relop             = parseRelOp((node \ "RelOp").head)
    val predicate         = parsePredicate((node \ "Predicate").head)
    val definedValues     = parseDefinedValues(node)
    Filter(startupExpression, relop, predicate, definedValues)
  }

  private def parseTopSort(node: Node): TopSort = {
    val rows          = (node \@ "Rows").toInt
    val distinct      = node \@ "Distinct" == "1"
    val orderBy       = parseOrderBy((node \ "OrderBy").head)
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    TopSort(rows, distinct, orderBy, relop, definedValues)
  }

  private def parseTop(node: Node): Top = {
    val topExpression = parseScalarOperator((node \ "TopExpression" \ "ScalarOperator").head)
    val tieColumns    = (node \ "TieColumns").map(parseColumnReference).to(Chunk)
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    Top(tieColumns, topExpression, relop, definedValues)
  }

  private def parseMergeUnion(node: Node): MergeUnion = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    MergeUnion(top, bottom, definedValues)
  }

  private def parseMergeJoin(node: Node): MergeJoin = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    val joinColumns =
      for {
        inner <- (node \ "InnerSideJoinColumns").headOption
        outer <- (node \ "OuterSideJoinColumns").headOption
        innerJoinColumn = parseColumnReference((inner \ "ColumnReference").head)
        outerJoinColumn = parseColumnReference((outer \ "ColumnReference").head)
      } yield JoinColumns(innerJoinColumn, outerJoinColumn)
    MergeJoin(top, bottom, joinColumns, definedValues)
  }

  private def parseMergeExcept(node: Node, dir: Direction): MergeExcept = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    val joinColumns =
      for {
        inner <- (node \ "InnerSideJoinColumns").headOption
        outer <- (node \ "OuterSideJoinColumns").headOption
        innerJoinColumn = parseColumnReference((inner \ "ColumnReference").head)
        outerJoinColumn = parseColumnReference((outer \ "ColumnReference").head)
      } yield JoinColumns(innerJoinColumn, outerJoinColumn)
    MergeExcept(top, bottom, joinColumns, dir, definedValues)
  }

  private def parseTableScan(node: Node): TableScan = {
    val ordered       = node \@ "Ordered" == "1"
    val obj           = parseObject((node \ "Object").head)
    val definedValues = parseDefinedValues(node)
    val predicate     = (node \ "Predicate").headOption.map(parsePredicate)
    TableScan(ordered, obj, predicate, definedValues)
  }

  private def parseHashJoin(node: Node): HashJoin = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val hashKeysBuild = (node \ "HashKeysBuild" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val hashKeysProbe = (node \ "HashKeysProbe" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val definedValues = parseDefinedValues(node)
    HashJoin(top, bottom, hashKeysBuild, hashKeysProbe, definedValues)
  }

  private def parseHashUnion(node: Node): HashUnion = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val definedValues = parseDefinedValues(node)
    HashUnion(top, bottom, definedValues)
  }

  private def parseHashIntersect(node: Node, dir: Direction): HashIntersect = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val hashKeysBuild = (node \ "HashKeysBuild" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val hashKeysProbe = (node \ "HashKeysProbe" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val definedValues = parseDefinedValues(node)
    HashIntersect(top, bottom, hashKeysBuild, hashKeysProbe, dir, definedValues)
  }

  private def parseHashAggregate(node: Node): HashAggregate = {
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    HashAggregate(relop, definedValues)
  }

  private def parseHashExcept(node: Node, dir: Direction): HashExcept = {
    val relops        = node \ "RelOp"
    val top           = parseRelOp(relops(0))
    val bottom        = parseRelOp(relops(1))
    val hashKeysBuild = (node \ "HashKeysBuild" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val hashKeysProbe = (node \ "HashKeysProbe" \ "ColumnReference").map(parseColumnReference).to(Chunk)
    val definedValues = parseDefinedValues(node)
    HashExcept(top, bottom, hashKeysBuild, hashKeysProbe, dir, definedValues)
  }

  private def parseConcat(node: Node): Concat = {
    val relops        = (node \ "RelOp").map(parseRelOp)
    val definedValues = parseDefinedValues(node)
    Concat(relops.to(Chunk), definedValues)
  }

  private def parseSpool(node: Node): Spool = {
    val relop         = parseRelOp((node \ "RelOp").head)
    val definedValues = parseDefinedValues(node)
    Spool(relop, definedValues)
  }

  private def parseScalarOperator(node: Node): ScalarOperator = {
    val operator = node.child.head

    operator.label match {
      case "Aggregate" =>
        val aggType        = operator \@ "AggType"
        val distinct       = operator \@ "Distinct"
        val scalarOperator = operator.child.map(parseScalarOperator).headOption
        Aggregate(aggType, distinct == "1", scalarOperator)
      case "Arithmetic" =>
        val operation      = operator \@ "Operation"
        val List(lhs, rhs) = operator.child.map(parseScalarOperator).toList
        Arithmetic(ArithmeticOperation.valueOf(operation), lhs, rhs)
      case "Compare" =>
        val comparisonOperation = operator \@ "CompareOp"
        val List(lhs, rhs)      = operator.child.map(parseScalarOperator).toList
        Compare(ComparisonOperation.valueOf(comparisonOperation), lhs, rhs)
      case "Const" =>
        val stringValue = operator \@ "ConstValue"
        val value =
          if (stringValue.startsWith("(")) {
            val value = stringValue.substring(1, stringValue.length - 1)
            value.toIntOption.getOrElse(value.toDouble).toString
          } else stringValue
        Const(value)
      case "Convert" =>
        val scalarOperator = parseScalarOperator((operator \ "ScalarOperator").head)
        // val dataType       = operator \@ "DataType"
        // val isImplicit     = operator \@ "Implicit" == "1"
        // val length         = Option(operator \@ "Length").filter(_.trim.nonEmpty).map(_.toInt)
        // val precision      = Option(operator \@ "Precision").filter(_.trim.nonEmpty).map(_.toInt)
        // val scale          = Option(operator \@ "Scale").filter(_.trim.nonEmpty).map(_.toInt)
        Convert(scalarOperator)
      case "IF" =>
        val condition = parseScalarOperator((operator \ "Condition" \ "ScalarOperator").head)
        val ifTrue    = parseScalarOperator((operator \ "Then" \ "ScalarOperator").head)
        val ifFalse   = parseScalarOperator((operator \ "Else" \ "ScalarOperator").head)
        If(condition, ifTrue, ifFalse)
      case "Identifier" =>
        val columnReference = parseColumnReference((operator \ "ColumnReference").head)
        Identifier(columnReference)
      case "Intrinsic" =>
        val functionName   = operator \@ "FunctionName"
        val List(lhs, rhs) = operator.child.map(parseScalarOperator).toList
        Intrinsic(functionName, lhs, rhs)
      case "Logical" =>
        val operation       = operator \@ "Operation"
        val scalarOperators = operator.child.map(parseScalarOperator)
        Logical(LogicalOperation.valueOf(operation.replace(" ", "")), scalarOperators.to(Chunk))
      case other => throw new RuntimeException(s"Unknown ScalarOperator: $other")
    }
  }

  private def parseColumnReference(node: Node): ColumnReference = {
    val scalarOperator = (node \ "ScalarOperator").headOption.map(parseScalarOperator)
    val column         = node \@ "Column"
    val schema         = Option(node \@ "Schema").filter(_.trim.nonEmpty)
    val table          = Option(node \@ "Table").filter(_.trim.nonEmpty)
    val alias          = Option(node \@ "Alias").filter(_.trim.nonEmpty)
    val value = Option(node \@ "ParameterCompiledValue").filter(_.trim.nonEmpty).map {
      case s"($v)"    => v
      case s"'$str '" => s"'$str'"
      case v          => v
    }
    ColumnReference(scalarOperator, column, schema, table, alias, value).strip
  }

  private def parseGroupBy(node: Node): Chunk[ColumnReference] =
    (node \ "ColumnReference").map(parseColumnReference).to(Chunk)

  private def parseDefinedValues(node: Node): Chunk[DefinedValue] = {
    val definedValues = node \ "DefinedValues" \ "DefinedValue"
    Chunk.fromIterable(definedValues.map { dv =>
      val columnReferences = (dv \ "ColumnReference").map(parseColumnReference).to(Chunk)
      val scalarOperator   = (dv \ "ScalarOperator").headOption.map(parseScalarOperator)
      if (scalarOperator.isDefined) DefinedValue.Assignment(columnReferences.head, scalarOperator.get)
      else if (columnReferences.length == 3) {
        val Chunk(u, lhs, rhs) = columnReferences
        DefinedValue.UnionAssignment(u, lhs, rhs)
      } else DefinedValue.Values(columnReferences)
    })
  }

  private def parseObject(node: Node): Object = {
    val schema = node \@ "Schema"
    val table  = node \@ "Table"
    val alias  = Option(node \@ "Alias").filter(_.trim.nonEmpty)
    val index  = Option(node \@ "Index").filter(_.trim.nonEmpty)
    Object(schema, table, alias, index).strip
  }

  private def parsePredicate(node: Node): ScalarOperator =
    parseScalarOperator((node \ "ScalarOperator").head)

  private def parseOrderBy(node: Node): Chunk[OrderByColumn] = {
    (node \ "OrderByColumn")
      .map { node =>
        val ascending = node \@ "Ascending" == "1"
        val column    = parseColumnReference((node \ "ColumnReference").head)
        OrderByColumn(column, ascending)
      }
      .to(Chunk)
  }
}
