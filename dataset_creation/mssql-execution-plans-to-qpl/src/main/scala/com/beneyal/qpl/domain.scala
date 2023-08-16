package com.beneyal.qpl

import zio.Chunk

object domain {
  final case class ColumnReference(
      scalarOperator: Option[ScalarOperator],
      column: String,
      schema: Option[String],
      table: Option[String],
      alias: Option[String],
      value: Option[String]
  ) {
    def strip: ColumnReference = {
      def f(s: String) = s match { case s"[$x]" => x; case _ => s }
      ColumnReference(
        scalarOperator,
        f(column),
        schema.map(f),
        table.map(f),
        alias.map(f),
        value
      )
    }
    override def toString(): String = s"${if (table.isDefined) s"${table.get}." else ""}$column"
  }

  final case class OrderByColumn(column: ColumnReference, ascending: Boolean)

  enum ArithmeticOperation(val sign: String) {
    case ADD extends ArithmeticOperation("+")
    case DIV extends ArithmeticOperation("/")
    case SUB extends ArithmeticOperation("-")
  }

  enum ComparisonOperation(val sign: String) {
    case EQ       extends ComparisonOperation("=")
    case GE       extends ComparisonOperation(">=")
    case GT       extends ComparisonOperation(">")
    case IS       extends ComparisonOperation("IS")
    case `IS NOT` extends ComparisonOperation("IS NOT")
    case LE       extends ComparisonOperation("<=")
    case LT       extends ComparisonOperation("<")
    case NE       extends ComparisonOperation("<>")
  }

  enum LogicalOperation {
    case AND, ISNULL, OR, NOT
  }

  enum Direction {
    case Left, Right
  }

  enum ScalarOperator {
    case Aggregate(aggType: String, distinct: Boolean, scalarOperator: Option[ScalarOperator])
    case Arithmetic(operation: ArithmeticOperation, lhs: ScalarOperator, rhs: ScalarOperator)
    case Compare(operation: ComparisonOperation, lhs: ScalarOperator, rhs: ScalarOperator)
    case Const(value: String)
    case Convert(scalarOperator: ScalarOperator)
    case If(condition: ScalarOperator, ifTrue: ScalarOperator, ifFalse: ScalarOperator)
    case Identifier(columnReference: ColumnReference)
    case Intrinsic(functionName: String, lhs: ScalarOperator, rhs: ScalarOperator)
    case Logical(operation: LogicalOperation, scalarOperators: Chunk[ScalarOperator])
  }

  enum DefinedValue {
    case Values(columnReferences: Chunk[ColumnReference])
    case Assignment(columnReference: ColumnReference, scalarOperator: ScalarOperator)
    case UnionAssignment(unionName: ColumnReference, lhs: ColumnReference, rhs: ColumnReference)
  }

  final case class JoinColumns(inner: ColumnReference, outer: ColumnReference)

  final case class Object(schema: String, table: String, alias: Option[String], index: Option[String]) {
    def strip: Object = {
      def f(s: String) = if (s.startsWith("[")) s.substring(1, s.length - 1) else s
      Object(
        f(schema),
        f(table),
        alias.map(f),
        index.map(f)
      )
    }
    override def toString(): String = table
  }
  final case class ScanRange(
      scanType: ComparisonOperation,
      rangeColumns: Chunk[ColumnReference],
      rangeExpression: Chunk[ScalarOperator]
  )
  final case class SeekPredicate(prefix: Option[ScanRange], startRange: Option[ScanRange], endRange: Option[ScanRange])

  enum RelOpType {
    case ComputeScalar(
        relop: RelOp,
        computeSequence: Option[Boolean],
        definedValues: Chunk[DefinedValue]
    )
    case Concat(
        relops: Chunk[RelOp],
        definedValues: Chunk[DefinedValue]
    )
    case Filter(
        startupExpression: Boolean,
        relop: RelOp,
        predicate: ScalarOperator,
        definedValues: Chunk[DefinedValue]
    )
    case HashJoin(
        top: RelOp,
        bottom: RelOp,
        hashKeysBuild: Chunk[ColumnReference],
        hashKeysProbe: Chunk[ColumnReference],
        definedValues: Chunk[DefinedValue]
    )
    case HashUnion(
        top: RelOp,
        bottom: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case HashIntersect(
        top: RelOp,
        bottom: RelOp,
        hashKeysBuild: Chunk[ColumnReference],
        hashKeysProbe: Chunk[ColumnReference],
        direction: Direction,
        definedValues: Chunk[DefinedValue]
    )
    case HashAggregate(
        relop: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case HashExcept(
        top: RelOp,
        bottom: RelOp,
        hashKeysBuild: Chunk[ColumnReference],
        hashKeysProbe: Chunk[ColumnReference],
        direction: Direction,
        definedValues: Chunk[DefinedValue]
    )
    case IndexScan(
        ordered: Boolean,
        obj: Object,
        seekPredicate: Option[SeekPredicate],
        predicates: Option[ScalarOperator],
        definedValues: Chunk[DefinedValue]
    )
    case MergeUnion(
        top: RelOp,
        bottom: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case MergeJoin(
        top: RelOp,
        bottom: RelOp,
        joinColumns: Option[JoinColumns],
        definedValues: Chunk[DefinedValue]
    )
    case MergeExcept(
        top: RelOp,
        bottom: RelOp,
        joinColumns: Option[JoinColumns],
        direction: Direction,
        definedValues: Chunk[DefinedValue]
    )
    case NestedLoopsJoin(
        top: RelOp,
        bottom: RelOp,
        predicate: Option[ScalarOperator],
        definedValues: Chunk[DefinedValue]
    )
    case NestedLoopsExcept(
        top: RelOp,
        bottom: RelOp,
        predicate: Option[ScalarOperator],
        outerReferences: Chunk[ColumnReference],
        definedValues: Chunk[DefinedValue]
    )
    case Intersect(
        top: RelOp,
        bottom: RelOp,
        predicate: Option[ScalarOperator],
        definedValues: Chunk[DefinedValue]
    )
    case Sort(
        distinct: Boolean,
        orderBy: Chunk[OrderByColumn],
        relop: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case Spool(
        relop: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case EmptySpool
    case StreamAggregate(
        relop: RelOp,
        groupBy: Chunk[ColumnReference],
        definedValues: Chunk[DefinedValue]
    )
    case TableScan(
        ordered: Boolean,
        obj: Object,
        predicate: Option[ScalarOperator],
        definedValues: Chunk[DefinedValue]
    )
    case Top(
        tieColumns: Chunk[ColumnReference],
        topExpression: ScalarOperator,
        relop: RelOp,
        definedValues: Chunk[DefinedValue]
    )
    case TopSort(
        rows: Int,
        distinct: Boolean,
        orderBy: Chunk[OrderByColumn],
        relop: RelOp,
        definedValues: Chunk[DefinedValue]
    )
  }

  final case class RelOp(operation: RelOpType, outputList: Chunk[ColumnReference])

  final case class ExecutionPlan(query: String, relop: RelOp, parameters: Chunk[ColumnReference]) {
    def getInitialEnv: Map[String, String] = parameters.map(cr => cr.column -> cr.value.get).toMap
  }
}
