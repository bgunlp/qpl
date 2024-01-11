package com.beneyal.qpl

import cats.*
import cats.data.*
import com.beneyal.qpl.domain.*
import com.beneyal.qpl.reading.*
import scopt.OParser
import zio.*
import zio.json.*

import java.nio.file.Path

object plantoqpl extends ZIOAppDefault {
  import DefinedValue.*
  import ScalarOperator.*
  import RelOpType.*

  type Env = Map[String, String]

  final case class Opt(name: String, args: Chunk[String])

  object Opt {
    def apply(name: String, arg: String): Opt =
      new Opt(name, Chunk(arg))
  }

  final case class Operation(
      name: String,
      outs: Chunk[String],
      ins: Chunk[Operation] = Chunk.empty,
      options: Chunk[Opt] = Chunk.empty
  )

  object Operation {
    def apply(name: String, returns: Chunk[String], ins: Chunk[Operation], option: Opt): Operation =
      new Operation(name, returns, ins, Chunk(option))

    def tableSpool: Operation = Operation("TableSpool", Chunk.empty)
  }

  final case class QplLine(idx: Int, ins: Chunk[Int], operation: Operation)

  final case class QplState(
      currentIdx: Int,
      outs: Map[Int, Chunk[String]]
  )

  object QplState {
    def empty: QplState = QplState(1, Map.empty)
  }

  def toQpl(si: SpiderInstance): String = {
    def recur(op: Operation, isRoot: Boolean = false): State[QplState, Chunk[QplLine]] = {
      op.name match {
        case "Scan" =>
          for {
            state <- State.get[QplState]
            _ <- State.set[QplState](
              QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, op.outs))
            )
          } yield Chunk(QplLine(state.currentIdx, Chunk.empty, op))
        case "Aggregate" =>
          val outs = if (op.ins.head.name == "Sort" && op.ins.head.ins.head.name == "Scan") {
            op.outs.map {
              case s"COUNT($col)" => s"COUNT(DISTINCT $col)"
              case s              => s
            }
          } else {
            op.outs
          }
          for {
            inner <- recur(op.ins.head)
            state <- State.get[QplState]
            _ <- State.set[QplState](
              QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, outs))
            )
          } yield inner :+ QplLine(state.currentIdx, Chunk(state.currentIdx - 1), op.copy(outs = outs))
        case "Filter" =>
          for {
            inner <- recur(op.ins.head)
            state <- State.get[QplState]
            prevIdx  = state.currentIdx - 1
            prevOuts = state.outs(prevIdx)
            outs = op.outs.map {
              case s"COUNT($col)" if prevOuts.contains(s"COUNT(DISTINCT $col)") => s"COUNT(DISTINCT $col)"
              case s                                                            => s
            }
            opts = op.options.map {
              case Opt("Predicate", p) =>
                Opt(
                  "Predicate",
                  p.map {
                    case s"COUNT($col)$rest" if prevOuts.contains(s"COUNT(DISTINCT $col)") =>
                      s"COUNT(DISTINCT $col)$rest"
                    case s => s
                  }
                )
              case opt => opt
            }
            _ <- State.set[QplState](
              QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, outs))
            )
          } yield inner :+ QplLine(
            state.currentIdx,
            Chunk(state.currentIdx - 1),
            op.copy(outs = outs, options = opts)
          )
        case "Sort" =>
          val isDistinct = op.options.exists { case Opt("Distinct", _) => true; case _ => false }
          for {
            inner <- recur(op.ins.head)
            state <- State.get[QplState]
            _ <-
              if (isRoot) {
                State.set[QplState](
                  QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, op.outs))
                )
              } else {
                State.pure(())
              }
          } yield
            if (isRoot) {
              if (isDistinct) {
                val last   = inner.last
                val lastOp = last.operation
                val opts   = lastOp.options
                val newOpts = if (!opts.exists { case Opt("Distinct", _) => true; case _ => false }) {
                  opts :+ Opt("Distinct", "true")
                } else {
                  opts
                }
                val newLast = last.copy(operation = lastOp.copy(outs = op.outs, options = newOpts))
                inner.init :+ newLast
              } else {
                inner :+ QplLine(state.currentIdx, Chunk(state.currentIdx - 1), op)
              }
            } else if (isDistinct) {
              val init  = inner.init
              val op    = inner.last.operation
              val newOp = op.copy(options = op.options :+ Opt("Distinct", "true"))
              init :+ QplLine(inner.last.idx, inner.last.ins, newOp)
            } else {
              inner
            }
        case "Top" =>
          for {
            inner <- recur(op.ins.head)
            state <- State.get[QplState]
            prevIdx  = state.currentIdx - 1
            prevOuts = state.outs(prevIdx)
            outs = op.outs.map {
              case s"COUNT($col)" if prevOuts.contains(s"COUNT(DISTINCT $col)") => s"COUNT(DISTINCT $col)"
              case s                                                            => s
            }
            _ <- State.set[QplState](
              QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, outs))
            )
          } yield inner :+ QplLine(state.currentIdx, Chunk(state.currentIdx - 1), op.copy(outs = outs))
        case "TopSort" =>
          for {
            inner <- recur(op.ins.head)
            state <- State.get[QplState]
            prevIdx  = state.currentIdx - 1
            prevOuts = state.outs(prevIdx)
            outs = op.outs.map {
              case s"COUNT($col)" if prevOuts.contains(s"COUNT(DISTINCT $col)") => s"COUNT(DISTINCT $col)"
              case s                                                            => s
            }
            _ <- State.set[QplState](
              QplState(state.currentIdx + 1, state.outs.updated(state.currentIdx, outs))
            )
          } yield inner :+ QplLine(state.currentIdx, Chunk(state.currentIdx - 1), op.copy(outs = outs))
        case "Join" | "Intersect" | "Except" | "Union" =>
          for {
            top    <- recur(op.ins(0))
            s1     <- State.get[QplState]
            bottom <- recur(op.ins(1))
            s2     <- State.get[QplState]
            outs = op.outs
              .map {
                case s"COUNT($col)"
                    if top.last.operation.outs.contains(s"COUNT(DISTINCT $col)") ||
                      bottom.last.operation.outs.contains(s"COUNT(DISTINCT $col)") =>
                  s"COUNT(DISTINCT $col)"
                case s => s
              }
            // .distinctBy {
            //   case s"$table.$column" => column
            //   case s                 => s
            // }
            opts =
              if (
                op.name == "Join" &&
                top.last.operation.options.map(_.name).contains("Distinct") &&
                bottom.last.operation.options.map(_.name).contains("Distinct")
              ) {
                op.options :+ Opt("Distinct", "true")
              } else {
                op.options
              }
            _ <- State.set[QplState](
              QplState(s2.currentIdx + 1, s2.outs.updated(s2.currentIdx, outs))
            )
          } yield (top ++ bottom) :+ QplLine(
            s2.currentIdx,
            Chunk(s1.currentIdx - 1, s2.currentIdx - 1),
            op.copy(options = opts, outs = outs)
          )
        case _ => throw new IllegalArgumentException(s"What is ${op.name}?!")
      }
    }

    val lines = recur(toOperation(si), true).run(QplState.empty).value._2.map { line =>
      val idx     = line.idx
      val ins     = line.ins
      val op      = line.operation
      val opName  = op.name
      val opts    = op.options.map(opt => s"${opt.name} ${opt.args.mkString("[ ", " , ", " ]")}").mkString(" ")
      val outputs = op.outs.mkString("Output [ ", " , ", " ]")

      if (opName == "Scan") {
        s"#$idx = $opName $opts $outputs"
      } else if (line.operation.options.isEmpty) {
        s"#$idx = $opName [ ${ins.map(i => s"#$i").mkString(" , ")} ] $outputs"
      } else {
        s"#$idx = $opName [ ${ins.map(i => s"#$i").mkString(" , ")} ] $opts $outputs"
      }
    }

    s"${si.db.name} | ${lines.mkString(" ; ")}"
  }

  def toOperation(si: SpiderInstance): Operation = {
    val (env, result) = toCR(si.ep.relop).run(si.ep.getInitialEnv).value
    result
  }

  extension [S, A](xs: Chunk[State[S, A]]) {
    def sequence: State[S, Chunk[A]] =
      if (xs.isEmpty) State(s => (s, Chunk.empty))
      else
        for {
          o  <- xs.head
          os <- xs.tail.sequence
        } yield o +: os
  }

  extension (env: Env) {
    private def merge(env2: Env): Env =
      env ++ env2.map { case (k, v) =>
        env.find(_._2 == k).map(_._1 -> v).getOrElse(k -> v)
      }

    private def deref(column: String): String = {
      val value = env.getOrElse(column, column)
      if (value == column) column else env.deref(value)
    }
  }

  def getOrDeref(env: Env)(cr: ColumnReference): String = {
    val derefed = env.deref(cr.column)
    if (derefed == cr.column) cr.strip.toString else derefed
  }

  def toMap(definedValues: Chunk[DefinedValue]): Map[String, ScalarOperator | String] =
    definedValues.collect {
      case Assignment(columnReference, scalarOperator) => columnReference.toString -> scalarOperator
      case UnionAssignment(unionName, lhs, _)          => unionName.toString       -> lhs.toString
    }.toMap

  def addDefinedValuesToEnv(definedValues: Chunk[DefinedValue])(env: Env): Map[String, String] =
    toMap(definedValues).view.mapValues {
      case so: ScalarOperator => toCR(env)(so)
      case s: String          => s
    }.toMap merge env

  def assignAliases(p: ScalarOperator): ScalarOperator = {
    def recur(so: ScalarOperator, alias: Option[String]): ScalarOperator = {
      so match {
        case Aggregate(aggType, distinct, scalarOperators) =>
          Aggregate(aggType, distinct, scalarOperators.map(recur(_, alias)))
        case Arithmetic(operation, lhs, rhs) =>
          Arithmetic(operation, recur(lhs, Some("T")), recur(rhs, Some("B")))
        case Compare(operation, lhs, rhs) =>
          Compare(operation, recur(lhs, Some("T")), recur(rhs, Some("B")))
        case Const(value) =>
          Const(value)
        case Convert(scalarOperator) =>
          recur(scalarOperator, alias)
        case If(condition, ifTrue, ifFalse) =>
          If(recur(condition, alias), recur(ifTrue, alias), recur(ifFalse, alias))
        case Identifier(cr) =>
          Identifier(ColumnReference(None, cr.column, None, alias, None, None))
        case Intrinsic(functionName, lhs, rhs) =>
          Intrinsic(functionName, recur(lhs, alias), recur(rhs, alias))
        case Logical(operation, scalarOperators) =>
          if (operation == LogicalOperation.ISNULL) Logical(operation, scalarOperators)
          else Logical(operation, Chunk(recur(scalarOperators(0), Some("T")), recur(scalarOperators(1), Some("B"))))
      }
    }
    recur(p, None)
  }

  private def skipSort(current: RelOp) =
    current.operation match {
      case Sort(false, _, relop, _) => relop
      case _                        => current
    }

  private val skipSortAndConvert = skipSort andThen toCR

  private def toCR(relop: RelOp): State[Env, Operation] = {
    val outputList = relop.outputList
    relop.operation match {
      case ComputeScalar(relop, _, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
          isConvertOp = definedValues.exists {
            case Assignment(columnReference, Convert(_)) => true
            case _                                       => false
          }
          derefedOutputList = outputList.map(getOrDeref(env))
          aggPat            = """MIN|MAX|COUNT|SUM|AVG""".r
          groupBy = Opt(
            "GroupBy",
            outputList.filterNot(cr => aggPat.findPrefixOf(getOrDeref(env)(cr)).isDefined).map(_.column)
          )
          arithmeticOps = definedValues.collect { case Assignment(columnReference, a: Arithmetic) => a }
          arithColumns  = arithmeticOps.flatMap(a => Chunk(a.lhs, a.rhs)).flatMap(extractColumns)
          ifs           = definedValues.collect { case Assignment(columnReference, if_ : If) => if_ }
          finalResults  = ifs.map(toCR(env))
        } yield
          if (inner.name == "Aggregate" || isConvertOp) inner.copy(outs = derefedOutputList)
          else if (arithColumns.nonEmpty) {
            val newOutputList = relop.outputList.filterNot(arithColumns.contains(_)).map(getOrDeref(env))
            inner.copy(outs = newOutputList ++ arithmeticOps.map(toCR(env)))
          } else if (derefedOutputList.exists(s => s.contains("AVG") || s.contains("SUM"))) {
            inner.copy(outs = finalResults)
          } else if (derefedOutputList.toSet == inner.outs.toSet) {
            inner
          } else {
            Operation("Aggregate", derefedOutputList, Chunk(inner), groupBy)
          }
      case Concat(relops, definedValues) =>
        for {
          inners <- relops.map(toCR).sequence
          _      <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env    <- State.get[Env]
        } yield Operation("Union", outputList.map(cr => env.deref(cr.column)), inners)
      case Filter(startupExpression, relop, predicate, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
        } yield Operation(
          "Filter",
          outputList.map(getOrDeref(env)),
          Chunk(inner),
          Opt("Predicate", toCR(env)(predicate))
        )
      case HashAggregate(relop, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
        } yield Operation("Aggregate", outputList.map(getOrDeref(env)), Chunk(inner))
      case HashJoin(top, bottom, hashKeysBuild, hashKeysProbe, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          hashKeys      = hashKeysBuild.map(getOrDeref(env)).zip(hashKeysProbe.map(getOrDeref(env)))
          newOutputList = if (outputList.isEmpty) t.outs else outputList.map(getOrDeref(env))
        } yield Operation(
          "Join",
          newOutputList,
          Chunk(t, b),
          Opt("Predicate", hashKeys.map { case (lhs, rhs) => s"$lhs = $rhs" })
        )
      case HashUnion(top, bottom, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
        } yield Operation("Union", outputList.map(cr => env.deref(cr.column)), Chunk(t, b))
      case HashIntersect(top, bottom, hashKeysBuild, hashKeysProbe, dir, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          hashKeys      = hashKeysBuild.map(getOrDeref(env)).zip(hashKeysProbe.map(getOrDeref(env)))
          newOutputList = if (outputList.isEmpty) t.outs else outputList.map(getOrDeref(env))
          ins           = if (dir == Direction.Left) Chunk(t, b) else Chunk(b, t)
        } yield Operation(
          "Intersect",
          outputList.map(getOrDeref(env)),
          ins,
          Opt("Predicate", hashKeys.map { case (lhs, rhs) => s"$lhs = $rhs" })
        )
      case HashExcept(top, bottom, hashKeysBuild, hashKeysProbe, dir, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          hashKeys = hashKeysBuild.map(getOrDeref(env)).zip(hashKeysProbe.map(getOrDeref(env)))
          ins      = if (dir == Direction.Left) Chunk(t, b) else Chunk(b, t)
        } yield Operation(
          "Except",
          outputList.map(getOrDeref(env)),
          ins,
          Opt("Predicate", hashKeys.map { case (lhs, rhs) => s"$lhs = $rhs" })
        )
      case IndexScan(ordered, obj, seekPredicate, predicate, definedValues) =>
        for {
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          p = predicate.map(toCR(env)).filterNot(_.contains("==="))
          otherOutputs = predicate.toList
            .flatMap(extractColumns)
            .filter(_.table.exists(_ == obj.table))
            .to(Chunk)
            .distinctBy(cr => (cr.table, cr.column))
          newOutputs = outputList ++ otherOutputs
        } yield Operation(
          "Scan",
          if (newOutputs.isEmpty) Chunk("*")
          else newOutputs.map(getOrDeref(env)),
          Chunk.empty,
          Chunk(Opt("Table", Chunk(obj.strip.toString))) /* ++ isOrdered */ ++
            (if (p.isDefined) Chunk(Opt("Predicate", Chunk(p.get))) else Chunk.empty)
        )
      case MergeJoin(top, bottom, joinColumns, definedValues) =>
        for {
          t   <- skipSortAndConvert(top)
          b   <- skipSortAndConvert(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          predicate = joinColumns
            .map { jc =>
              val lhs = getOrDeref(env)(jc.inner)
              val rhs = getOrDeref(env)(jc.outer)
              Chunk(Opt("Predicate", s"$lhs = $rhs"))
            }
            .getOrElse(Chunk.empty)
        } yield Operation("Join", outputList.map(getOrDeref(env)), Chunk(t, b), predicate)
      case MergeExcept(top, bottom, joinColumns, dir, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          predicate = joinColumns
            .map { jc =>
              val lhs = getOrDeref(env)(jc.inner)
              val rhs = getOrDeref(env)(jc.outer)
              Chunk(Opt("Predicate", s"$lhs = $rhs"))
            }
            .getOrElse(Chunk.empty)
          ins = if (dir == Direction.Left) Chunk(t, b) else Chunk(b, t)
        } yield Operation("Except", outputList.map(getOrDeref(env)), ins, predicate)
      case MergeUnion(top, bottom, definedValues) =>
        for {
          t   <- toCR(top)
          b   <- toCR(bottom)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
        } yield Operation("Union", outputList.map(cr => env.deref(cr.column)), Chunk(t, b))
      case NestedLoopsJoin(top, bottom, predicate, definedValues) =>
        for {
          t <- toCR(top)
          newBottom = bottom.operation match {
            case Top(_, _, relop, _) => relop
            case _                   => bottom
          }
          b <- toCR(newBottom)
          bWithOutputList = b.copy(outs = if (b.outs.isEmpty) t.outs else b.outs)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          p               = predicate.map(toCR(env))
          shouldGiveAlias = p.exists(_.contains("==="))
          newP            = if (shouldGiveAlias) predicate.map(assignAliases).map(toCR(env)) else p
        } yield Operation(
          "Join",
          outputList.map(getOrDeref(env)),
          Chunk(t, b),
          newP.map(p => Chunk(Opt("Predicate", p))).getOrElse(Chunk.empty)
        )
      case NestedLoopsExcept(top, bottom, predicate, outerReferences, definedValues) =>
        for {
          t <- skipSortAndConvert(top)
          newBottom = bottom.operation match {
            case Top(_, _, relop, _) => relop
            case _                   => bottom
          }
          b <- toCR(newBottom)
          bWithOutputList = b.copy(outs = if (b.outs.isEmpty) t.outs else b.outs)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          p               = predicate.map(toCR(env))
          shouldGiveAlias = p.exists(_.contains("==="))
          newP            = if (shouldGiveAlias) predicate.map(assignAliases).map(toCR(env)) else p
          exceptColumns =
            if (outerReferences.nonEmpty) Chunk(Opt("ExceptColumns", outerReferences.map(getOrDeref(env))))
            else Chunk.empty
          newOutputList = if (outputList.isEmpty) t.outs else outputList.map(getOrDeref(env))
        } yield Operation(
          "Except",
          newOutputList,
          Chunk(t, b),
          newP.map(p => Chunk(Opt("Predicate", p))).getOrElse(Chunk.empty) ++ exceptColumns
        )
      case Intersect(top, bottom, predicate, definedValues) =>
        for {
          t <- skipSortAndConvert(top)
          newBottom = bottom.operation match {
            case Top(_, _, relop, _) => relop
            case _                   => bottom
          }
          b <- toCR(newBottom)
          bWithOutputList = b.copy(outs = if (b.outs.isEmpty) t.outs else b.outs)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          p               = predicate.map(toCR(env))
          shouldGiveAlias = p.exists(_.contains("==="))
          newP            = if (shouldGiveAlias) predicate.map(assignAliases).map(toCR(env)) else p
        } yield Operation(
          "Intersect",
          outputList.map(getOrDeref(env)),
          Chunk(t, b),
          newP.map(p => Chunk(Opt("Predicate", p))).getOrElse(Chunk.empty)
        )
      case Sort(distinct, orderBy, relop, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
        } yield Operation(
          "Sort",
          outputList.map(getOrDeref(env)),
          Chunk(inner),
          Chunk(
            Opt(
              "OrderBy",
              orderBy.map(c => s"${env.deref(c.column.strip.toString)} ${if (c.ascending) "ASC" else "DESC"}")
            )
          ) ++ (if (distinct) Chunk(Opt("Distinct", Chunk("true"))) else Chunk.empty)
        )
      case Spool(relop, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
        } yield inner
      case StreamAggregate(relop, groupBy, definedValues) =>
        for {
          inner <- skipSortAndConvert(relop)
          innerWithOutputList = inner.copy(outs = if (inner.outs.isEmpty) Chunk("1") else inner.outs)
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          derefedOutputList = outputList.map(getOrDeref(env))
        } yield Operation(
          "Aggregate",
          derefedOutputList,
          Chunk(innerWithOutputList),
          (if (groupBy.nonEmpty)
             Chunk(
               Opt(
                 "GroupBy",
                 groupBy.map(_.column).map(env.deref).map {
                   case s"$table.$col" => col
                   case s              => s
                 }
               )
             )
           else Chunk.empty)
        )
      case TableScan(ordered, obj, predicate, definedValues) =>
        for {
          _   <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env <- State.get[Env]
          isOrdered = if (ordered) Chunk(Opt("IsOrdered", Chunk("true"))) else Chunk.empty
          p = predicate.map(toCR(env)).filterNot(_.contains("===")).map(s => Opt("Predicate", Chunk(s))).to(Chunk)
          otherOutputs = predicate.toList
            .flatMap(extractColumns)
            .filter(_.table.exists(_ == obj.table))
            .to(Chunk)
            .distinctBy(cr => (cr.table, cr.column))
          newOutputs = outputList ++ otherOutputs
        } yield Operation(
          "Scan",
          if (newOutputs.isEmpty) Chunk("*")
          else newOutputs.map(getOrDeref(env)),
          Chunk.empty,
          Chunk(Opt("Table", Chunk(obj.strip.toString))) ++ isOrdered ++ p
        )
      case Top(tieColumns, topExpression, relop, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
        } yield Operation(
          "Top",
          outputList.map(getOrDeref(env)),
          Chunk(inner),
          Chunk(Opt("Rows", toCR(env)(topExpression)))
        )
      case TopSort(rows, distinct, orderBy, relop, definedValues) =>
        for {
          inner <- toCR(relop)
          _     <- State.modify[Env](addDefinedValuesToEnv(definedValues))
          env   <- State.get[Env]
        } yield Operation(
          "TopSort",
          outputList.map(getOrDeref(env)),
          Chunk(inner),
          Chunk(Opt("Rows", rows.toString)) ++
            (if (distinct) Chunk(Opt("Distinct", "true")) else Chunk.empty) ++
            Chunk(
              Opt(
                "OrderBy",
                orderBy.map(c => s"${env.deref(c.column.strip.toString)} ${if (c.ascending) "ASC" else "DESC"}")
              )
            )
        )
      case EmptySpool => State.pure(Operation.tableSpool)
    }
  }

  private def toCR(env: Env)(so: ScalarOperator): String =
    so match {
      case Aggregate(aggType, distinct, scalarOperator) =>
        val credScalarOperator = scalarOperator.map(toCR(env))
        aggType match {
          case "countstar" | "COUNT*" => "countstar"
          case "ANY"                  => s"${credScalarOperator.get}"
          case "COUNT_BIG" =>
            s"COUNT(${if (distinct) "DISTINCT " else ""}${credScalarOperator.get})"
          case agg @ ("SUM" | "MIN" | "MAX" | "COUNT") =>
            scalarOperator.get match {
              case Identifier(ColumnReference(_, col, _, _, _, _)) if col.startsWith("partialagg") =>
                credScalarOperator.get
              case _ => s"$agg(${if (distinct) "DISTINCT " else ""}${credScalarOperator.get})"
            }
          case _ if credScalarOperator == Some("countstar") => "countstar"
          case _ => s"$aggType(${if (distinct) "DISTINCT " else ""}${credScalarOperator.get})"
        }
      case Arithmetic(operation, lhs, rhs) =>
        s"${toCR(env)(lhs)} ${operation.sign} ${toCR(env)(rhs)}"
      case Compare(operation, lhs, rhs) =>
        val lhs_ = toCR(env)(lhs)
        val rhs_ = toCR(env)(rhs)
        if (lhs_ == rhs_) s"$lhs_ === $rhs_"
        else s"${lhs_} ${operation.sign} ${rhs_}"
      case Const(value) =>
        value match {
          case s"'$str '" => s"'$str'"
          case s"N'$str'" => s"'$str'"
          case _          => value
        }
      case Convert(scalarOperator) =>
        toCR(env)(scalarOperator)
      case ifExpr @ If(condition, ifTrue, ifFalse) =>
        if (isAvg(ifExpr)) toAvg(ifExpr, env)
        else if (isSum(ifExpr)) toSum(ifExpr, env)
        else if (isCountColumn(ifExpr)) toCountColumn(ifExpr, env)
        else if (isCountStar(ifExpr)) "countstar"
        else if (isAssertion(ifExpr)) toAssertion(ifExpr, env)
        else ???
      case Identifier(columnReference) =>
        columnReference.scalarOperator
          .map(toCR(env))
          .map(env.deref)
          .getOrElse {
            columnReference match {
              case ColumnReference(_, column, _, Some(table), _, _) => s"$table.${env.deref(column)}"
              case ColumnReference(_, column, _, None, _, _)        => env.deref(column)
            }
          }
      case Intrinsic(functionName, lhs, rhs) =>
        s"${toCR(env)(lhs)} $functionName ${toCR(env)(rhs)}"
      case Logical(operation, scalarOperators) =>
        if (operation == LogicalOperation.NOT)
          scalarOperators match {
            case Chunk(Intrinsic("like", lhs, rhs)) => s"${toCR(env)(lhs)} NOT LIKE ${toCR(env)(rhs)}"
            case _                                  => s"${toCR(env)(scalarOperators(0))} ${operation.toString}"
          }
        else if (operation == LogicalOperation.ISNULL)
          s"${toCR(env)(scalarOperators(0))} ${operation.toString}"
        else
          s"${toCR(env)(scalarOperators(0))} ${operation.toString} ${toCR(env)(scalarOperators(1))}"
    }

  def extractColumns(so: ScalarOperator): List[ColumnReference] = {
    def recur(so: ScalarOperator): List[ColumnReference] =
      so match {
        case Aggregate(_, _, Some(scalarOperator)) =>
          recur(scalarOperator)
        case Arithmetic(_, lhs, rhs) =>
          recur(lhs) ++ recur(rhs)
        case Compare(_, lhs, rhs) =>
          recur(lhs) ++ recur(rhs)
        case Convert(scalarOperator) =>
          recur(scalarOperator)
        case If(condition, ifTrue, ifFalse) =>
          recur(condition) ++ recur(ifTrue) ++ recur(ifFalse)
        case Identifier(cr @ ColumnReference(_, _, _, Some(_), _, _)) =>
          List(cr)
        case Intrinsic(_, lhs, rhs) =>
          recur(lhs) ++ recur(rhs)
        case Logical(_, scalarOperators) =>
          scalarOperators.toList.flatMap(recur)
        case _ =>
          List.empty
      }
    recur(so)
  }

  def isZeroEqualZero(ifExpr: If): Boolean = {
    val isZeroNull = ifExpr.condition match {
      case Logical(LogicalOperation.ISNULL, Chunk(Const("0"))) => true
      case _                                                   => false
    }
    val isThenZero = ifExpr.ifTrue match {
      case Const("0") => true
      case _          => false
    }
    val isElseOne = ifExpr.ifFalse match {
      case Const("1") => true
      case _          => false
    }
    isZeroNull && isThenZero && isElseOne
  }

  def isCountStar(ifExpr: If): Boolean = {
    val isIsNullCondition = ifExpr.condition match {
      case Logical(LogicalOperation.ISNULL, Chunk(Const("0"))) => true
      case _                                                   => false
    }
    val isZeroIfTrue = ifExpr.ifTrue match {
      case Const("0") => true
      case _          => false
    }
    val isOneIfFalse = ifExpr.ifFalse match {
      case Const("1") => true
      case _          => false
    }
    isIsNullCondition && isZeroIfTrue && isOneIfFalse
  }

  def isCountColumn(ifExpr: If): Boolean = {
    val isIsNullCondition = ifExpr.condition match {
      case Logical(LogicalOperation.ISNULL, Chunk(Identifier(_))) => true
      case _                                                      => false
    }
    val isZeroIfTrue = ifExpr.ifTrue match {
      case Const("0") => true
      case _          => false
    }
    val isOneIfFalse = ifExpr.ifFalse match {
      case Const("1") => true
      case _          => false
    }
    isIsNullCondition && isZeroIfTrue && isOneIfFalse
  }

  def toCountColumn(ifExpr: If, env: Env): String = {
    val colToCount = ifExpr.condition match {
      case Logical(LogicalOperation.ISNULL, Chunk(ident)) => toCR(env)(ident)
      case _                                              => ???
    }
    s"COUNT($colToCount)"
  }

  def isAvg(ifExpr: If): Boolean = {
    val isThenNull = ifExpr.ifTrue match {
      case ScalarOperator.Const("NULL") => true
      case _                            => false
    }
    val isAltDivision = ifExpr.ifFalse match {
      case Arithmetic(ArithmeticOperation.DIV, _, _) => true
      case _                                         => false
    }
    isThenNull && isAltDivision
  }

  def toAvg(ifExpr: If, env: Env): String = {
    val columnToAverage = ifExpr.ifFalse match {
      case Arithmetic(ArithmeticOperation.DIV, lhs, _) => toCR(env)(lhs)
      case _                                           => ???
    }
    columnToAverage match {
      case s"SUM($col)" => s"AVG($col)"
      case _            => s"AVG($columnToAverage)"
    }
  }

  def isSum(ifExpr: If): Boolean = {
    val isCondEqZero = ifExpr.condition match {
      case Compare(ComparisonOperation.EQ, _, rhs) =>
        rhs match {
          case Const(value) => value.toDouble == 0
          case _            => false
        }
      case _ => false
    }
    val isThenNull = ifExpr.ifTrue match {
      case ScalarOperator.Const("NULL") => true
      case _                            => false
    }
    isCondEqZero && isThenNull
  }

  def toSum(ifExpr: If, env: Env): String = {
    ifExpr.ifFalse match {
      case id @ Identifier(_) => toCR(env)(id)
      case _                  => ???
    }
  }

  def isAssertion(ifExpr: If): Boolean = {
    ifExpr match {
      case If(_, Const("0"), Const("NULL")) => true
      case _                                => false
    }
  }

  def toAssertion(ifExpr: If, env: Env): String =
    s"NOT (${toCR(env)(ifExpr.condition)})"

  final case class QplInstance(
      id: String,
      question: String,
      query: String,
      difficulty: String,
      qpl: String
  )

  object QplInstance {
    given JsonCodec[QplInstance] = DeriveJsonCodec.gen
  }

  def writeQplsToJson(instances: Chunk[SpiderInstance], outputPath: Path): Task[Unit] =
    for {
      qpls <- ZIO.foreach(instances) { ins =>
        ZIO
          .attempt(toQpl(ins))
          .catchAll(_ => ZIO.succeed(""))
          .map(QplInstance(ins.id, ins.question, ins.query, ins.difficulty, _))
      }
      json = qpls.filter(_.qpl.nonEmpty).toJsonPretty
      _ <- ZIO.writeFile(outputPath, json)
    } yield ()

  final case class CommandLineArgs(
      spiderPath: Option[Path] = None,
      datasetPath: Option[Path] = None,
      outputPath: Option[Path] = None
  )

  val builder = OParser.builder[CommandLineArgs]
  val cmdLineParser = {
    import builder.*

    OParser.sequence(
      programName("ep2qpl"),
      opt[Path]('s', "spider").action((x, c) => c.copy(spiderPath = Some(x))).text("Path to the Spider dataset"),
      opt[Path]('i', "input").action((x, c) => c.copy(datasetPath = Some(x))).text("Path to dataset file to convert"),
      opt[Path]('o', "output").action((x, c) => c.copy(outputPath = Some(x))).text("Output path")
    )
  }

  val program = for {
    args <- getArgs.flatMap(args => ZIO.fromOption(OParser.parse(cmdLineParser, args, CommandLineArgs())))
    paths <- ZIO.fromOption(for {
      s <- args.spiderPath
      d <- args.datasetPath
      o <- args.outputPath
    } yield (s, d, o))
    (spiderPath, datasetPath, outputPath) = paths
    tablesPath                            = spiderPath.resolve("tables.json")
    instances <- readDataset(datasetPath, tablesPath)
    _         <- writeQplsToJson(instances, outputPath)
  } yield ()

  override def run = program
}
