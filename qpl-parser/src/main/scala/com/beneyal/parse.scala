package com.beneyal

import atto.*, Atto.*
import cats.*
import cats.data.*
import cats.syntax.all.*
import io.circe.{Parser => _, *}
import io.circe.Decoder.Result
import io.circe.derivation.{Configuration, ConfiguredCodec}

object parse {
  type SchemaReader[A] = ReaderT[Parser, SqlSchema, A]

  final case class QplParser[A](inner: StateT[SchemaReader, QplState, A]) { self =>
    def map[B](f: A => B): QplParser[B] = QplParser(inner.map(f))

    def as[B](b: => B): QplParser[B] = self.map(_ => b)

    def flatMap[B](f: A => QplParser[B]): QplParser[B] = QplParser(inner.flatMap(f(_).inner))

    def run(state: QplState, schema: SqlSchema): Parser[(QplState, A)] = inner.run(state).run(schema)

    def orElse(that: => QplParser[A]): QplParser[A] = QplParser {
      StateT { state =>
        ReaderT { schema =>
          self.run(state, schema) | that.run(state, schema)
        }
      }
    }

    def |(that: => QplParser[A]): QplParser[A] = self.orElse(that)

    def optional: QplParser[Option[A]] = QplParser {
      StateT { state =>
        ReaderT { schema =>
          opt(self.run(state, schema)).map {
            case Some((s, a)) => (s, Some(a))
            case None         => (state, None)
          }
        }
      }
    }

    def either[B](that: => QplParser[B]): QplParser[Either[A, B]] = QplParser {
      StateT { state =>
        ReaderT { schema =>
          Atto.either(self.run(state, schema), that.run(state, schema)).map {
            case Right((s, a)) => (s, Right(a))
            case Left((s, b))  => (s, Left(b))
          }
        }
      }
    }

    def ||[B](that: => QplParser[B]): QplParser[Either[A, B]] = self.either(that)

    def many: QplParser[List[A]] =
      self.map(List(_)).flatMap(as => self.many.map(as ++ _)).orElse(ok(Nil).lift)

    def ~>[B](that: => QplParser[B]): QplParser[B] = QplParser {
      StateT { state =>
        ReaderT { schema =>
          self.run(state, schema) ~> that.run(state, schema)
        }
      }
    }

    def sepBy1(s: QplParser[_]): QplParser[List[A]] = for {
      a  <- self
      as <- (s ~> self).many
    } yield a :: as
  }

  object QplParser {
    def ask: QplParser[SqlSchema] = QplParser(StateT.liftF(ReaderT(ok)))

    def get: QplParser[QplState] = QplParser(StateT.get[SchemaReader, QplState])

    def modify(f: QplState => QplState): QplParser[Unit] = QplParser(StateT.modify(f))

    def make(schema: SqlSchema): Parser[Qpl] = qpl.run(QplState.empty, schema).map(_._2)
  }

  extension [A](parser: Parser[A]) {
    def lift: QplParser[A] = QplParser(StateT.liftF(ReaderT.liftF(parser)))
  }

  def string(s: String): QplParser[String] =
    s.toList.foldRight(ok("").lift) { case (ch, acc) =>
      for {
        c  <- char(ch).lift
        cs <- acc
      } yield s"$c$cs"
    }

  def stringCI(s: String): QplParser[String] =
    s.toList.foldRight(ok("").lift) { case (ch, acc) =>
      for {
        c  <- (char(ch.toLower) | char(ch.toUpper)).lift
        cs <- acc
      } yield s"$c$cs"
    }

  def choice[A](ps: Iterable[QplParser[A]]): QplParser[A] =
    ps.foldRight[QplParser[A]](err("choice: no match").lift)(_ | _)

  def startsWithAgg(s: String): Boolean =
    Agg.values.map(agg => s"${agg.toString}_").exists(s.startsWith(_)) || s.startsWith("countstar")

  enum ColumnType {
    case Number, Boolean, Text, Time, Others
  }

  object ColumnType {
    given Codec[ColumnType] with {
      override def apply(a: ColumnType): Json = Json.fromString(a.toString.toLowerCase)
      override def apply(c: HCursor): Result[ColumnType] = c.as[String].flatMap {
        case "number"  => Right(ColumnType.Number)
        case "boolean" => Right(ColumnType.Boolean)
        case "text"    => Right(ColumnType.Text)
        case "time"    => Right(ColumnType.Time)
        case "others"  => Right(ColumnType.Others)
        case t         => Left(DecodingFailure(s"Unknown type: $t", Nil))
      }
    }
  }

  final case class SqlSchema(
      dbId: String,
      tableNames: Vector[String],
      columnNames: Vector[String],
      columnTypes: Vector[ColumnType],
      columnToTable: Vector[Int],
      tableToColumns: Map[String, Vector[Int]],
      foreignKeys: List[(Int, Int)],
      primaryKeys: Vector[Int]
  ) derives ConfiguredCodec

  object SqlSchema {
    given Configuration = Configuration.default.withSnakeCaseMemberNames
  }

  final case class QplState(currentIdx: Int, seen: Set[Int], idxToTable: Map[Int, Table]) {
    def incrementCurrentIndex: QplState = copy(currentIdx = currentIdx + 1)
  }

  object QplState {
    def empty: QplState = QplState(0, Set.empty, Map.empty)
  }

  enum KeyType {
    case PrimaryKey(table: String)
    case ForeignKey(table: String)
  }

  enum Column(val name: String, val typ: ColumnType, val keys: List[KeyType]) {
    case Dummy extends Column("1 AS One", ColumnType.Number, List.empty)
    case Plain(override val name: String, override val typ: ColumnType, override val keys: List[KeyType])
        extends Column(name, typ, keys)
    case Aliased(override val name: String, override val typ: ColumnType, override val keys: List[KeyType])
        extends Column(name, typ, keys)
  }

  enum Table(val columns: List[Column]) {
    case Named(name: String, override val columns: List[Column]) extends Table(columns)
    case Indexed(idx: Int, override val columns: List[Column])   extends Table(columns)
  }

  enum Comparable {
    case Number(value: Double)
    case Str(value: String)
    case Bool(value: Boolean)
    case Null
    case Col(column: String)
  }

  enum Comparison {
    case Equal(lhs: Comparable, rhs: Comparable)
    case NotEqual(lhs: Comparable, rhs: Comparable)
    case GreaterThan(lhs: Comparable, rhs: Comparable)
    case GreaterThanOrEqual(lhs: Comparable, rhs: Comparable)
    case LessThan(lhs: Comparable, rhs: Comparable)
    case LessThanOrEqual(lhs: Comparable, rhs: Comparable)
    case Is(lhs: Comparable, rhs: Comparable)
    case IsNot(lhs: Comparable, rhs: Comparable)
    case Like(lhs: Comparable, rhs: Comparable)
    case NotLike(lhs: Comparable, rhs: Comparable)
  }

  object Comparison {
    def fromStringOp(op: String, lhs: Comparable, rhs: Comparable): Comparison =
      op match {
        case "="        => Equal(lhs, rhs)
        case "<>"       => NotEqual(lhs, rhs)
        case ">"        => GreaterThan(lhs, rhs)
        case ">="       => GreaterThanOrEqual(lhs, rhs)
        case "<"        => LessThan(lhs, rhs)
        case "<="       => LessThanOrEqual(lhs, rhs)
        case "IS"       => Is(lhs, rhs)
        case "IS NOT"   => IsNot(lhs, rhs)
        case "LIKE"     => Like(lhs, rhs)
        case "NOT LIKE" => NotLike(lhs, rhs)
        case _          => throw new RuntimeException(s"$op is not a valid operator")
      }
  }

  enum Predicate {
    case Single(comparison: Comparison)
    case Conjunction(lhs: Predicate, rhs: Predicate)
    case Disjunction(lhs: Predicate, rhs: Predicate)
  }

  enum Operation {
    case Aggregate(input: Int, groupBy: List[String])
    case Except(inputs: List[Int], operator: Either[Predicate, String], isDistinct: Boolean)
    case Filter(input: Int, predicate: Option[Predicate], isDistinct: Boolean)
    case Intersect(inputs: List[Int], predicate: Option[Predicate], isDistinct: Boolean)
    case Join(inputs: List[Int], predicate: Option[Predicate], isDistinct: Boolean)
    case Scan(table: String, predicate: Option[Predicate], isDistinct: Boolean)
    case Top(input: Int, rows: Int)
    case Sort(input: Int, orderBy: List[String], isDistinct: Boolean)
    case TopSort(input: Int, rows: Int, orderBy: List[String], withTies: Boolean)
    case Union(inputs: List[Int])
  }

  enum Agg {
    case Sum, Min, Max, Count, Avg
  }

  final case class Line(idx: Int, operation: Operation)

  type Qpl = List[Line]

  def chainl1[A](p: QplParser[A], op: QplParser[(A, A) => A]): QplParser[A] = {
    def rest(a: A): QplParser[A] =
      op.flatMap(f => p.flatMap(b => rest(f(a, b)))) | ok(a).lift

    p.flatMap(rest)
  }

  val tableName: QplParser[String] = for {
    schema <- QplParser.ask
    p = (tn: String) => stringCI(tn).as(tn)
    table <- choice(schema.tableNames.sortBy(_.length)(using Ordering[Int].reverse).map(p))
  } yield table

  val columnName: QplParser[String] = for {
    schema <- QplParser.ask
    p = (cn: String) => stringCI(cn).as(cn)
    column <- choice(schema.columnNames.sortBy(_.length)(using Ordering[Int].reverse).map(p))
  } yield column

  val aliasedColumn: QplParser[String] = for {
    state <- QplParser.get
    p           = (cn: String) => stringCI(cn).as(cn)
    prevAliases = state.idxToTable.values.map(_.columns.map(_.name)).flatten.filter(startsWithAgg).toList
    alias <- choice(prevAliases.sortBy(_.length)(using Ordering[Int].reverse).map(p))
  } yield alias

  def indexedColumn(inputs: List[Int]): QplParser[(Int, String)] = for {
    _      <- char('#').lift
    idx    <- int.lift
    _      <- (if (inputs.contains(idx)) ok(()) else err(s"Index $idx is invalid given the inputs $inputs")).lift
    _      <- char('.').lift
    column <- columnInIndex(idx, columnName) | columnInIndex(idx, aliasedColumn)
  } yield (idx, column)

  val comparisonOp: QplParser[String] =
    string("<>") | string("<=") | string(">=") |
      stringCI("is not").as("IS NOT") | stringCI("is").as("IS") |
      stringCI("like").as("LIKE") | stringCI("not like").as("NOT LIKE") |
      string("<") | string(">") | string("=")

  val number: QplParser[Comparable] = double.map(Comparable.Number(_)).lift
  val str: QplParser[Comparable]    = (char('\'') ~> takeWhile(_ != '\'') <~ char('\'')).map(Comparable.Str(_)).lift
  val bool: QplParser[Comparable]   = (string("0").as(false) | string("1").as(true)).map(Comparable.Bool(_))
  val null_ : QplParser[Comparable] = string("NULL").as(Comparable.Null)

  val andOr: QplParser[(Predicate, Predicate) => Predicate] = for {
    _  <- skipWhitespace.lift
    op <- string("AND").as(Predicate.Conjunction.apply) | string("OR").as(Predicate.Disjunction.apply)
    _  <- skipWhitespace.lift
  } yield op

  val inputIds: QplParser[List[Int]] = for {
    state <- QplParser.get
    _     <- string("[ ")
    ids   <- (char('#') ~> int).lift.sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
    _     <- (if (ids.forall(state.seen)) ok(()) else err(s"Some inputs were not seen before: $ids")).lift
    _     <- string(" ] ")
  } yield ids.sorted

  def predicateWrapper(inner: QplParser[Predicate]): QplParser[Predicate] = for {
    _ <- string("Predicate [ ")
    p <- inner
    _ <- string(" ] ")
  } yield p

  def columnType(schema: SqlSchema, table: String, column: String): Option[ColumnType] = {
    val t = schema.tableNames.indexOf(table)
    val c = schema.columnNames.zipWithIndex
      .filter { case (cn, i) => cn.toLowerCase == column.toLowerCase && schema.columnToTable(i) == t }
      .headOption
      .map(_._2)

    c.map(schema.columnTypes(_))
  }

  def columnKey(schema: SqlSchema, table: String, column: String): List[KeyType] = {
    val t = schema.tableNames.indexOf(table)
    val c = schema.columnNames.zipWithIndex
      .filter { case (cn, i) => cn.toLowerCase == column.toLowerCase && schema.columnToTable(i) == t }
      .headOption
      .map(_._2)
      .toList

    c.flatMap { i =>
      val pk =
        if (schema.primaryKeys.contains(i) || schema.foreignKeys.map(_._2).contains(i))
          List(KeyType.PrimaryKey(table))
        else List.empty
      val fk =
        if (schema.foreignKeys.map(_._1).contains(i))
          schema.foreignKeys.map { case (_, pk) =>
            KeyType.ForeignKey(schema.tableNames(schema.columnToTable(pk)))
          }.distinct
        else List.empty
      pk ++ fk
    }
  }

  def columnInTable(table: String): QplParser[(String, Option[String])] = for {
    schema <- QplParser.ask
    column <- columnName
    alias  <- (string(" AS ") ~> many1(letterOrDigit).lift).optional.map(_.map(_.toList.mkString))
    t = schema.tableNames.indexOf(table)
    isColumnInTable = schema.columnNames.zipWithIndex.exists { case (cn, i) =>
      cn.toLowerCase == column.toLowerCase && schema.columnToTable(i) == t
    }
    _ <- (if (isColumnInTable) ok(()) else err(s"No column $column in table $table")).lift
  } yield (column, alias)

  def columnInIndex(input: Int, columnP: QplParser[String]): QplParser[String] = for {
    state  <- QplParser.get
    column <- columnP
    columnInTable = state.idxToTable
      .get(input)
      .map(_.columns.exists {
        case Column.Dummy                  => false
        case Column.Plain(column0, _, _)   => column == column0
        case Column.Aliased(column0, _, _) => column == column0
      })
      .getOrElse(false)
    _ <- (if (columnInTable) ok(()) else err(s"Column $column was not defined in index $input")).lift
  } yield column

  def getTableFromIndexedOutputs(inputs: List[Int], outs: List[(Int, String)]): QplParser[Table] = {
    QplParser.ask.flatMap { schema =>
      QplParser.get.flatMap { state =>
        val columns = outs.map {
          case (_, "1 AS One")                => Some(Column.Dummy)
          case (_, "countstar AS Count_Star") => Some(Column.Aliased("Count_Star", ColumnType.Number, List.empty))
          case (_, out) if startsWithAgg(out) => Some(Column.Aliased(out, ColumnType.Number, List.empty))
          case (idx, out)                     => state.idxToTable(idx).columns.find(_.name == out)
        }.sequence

        columns
          .map(Table.Indexed(state.currentIdx, _))
          .map(ok)
          .getOrElse(err(s"Could not create output table for index ${state.currentIdx}"))
          .lift
      }
    }
  }

  def getOutput(inputs: List[Int], outs: List[String]): QplParser[Table] = {
    QplParser.ask.flatMap { schema =>
      QplParser.get.flatMap { state =>
        val prev = inputs.map(state.idxToTable(_))
        val columns = outs.map {
          case "1 AS One"                => Some(Column.Dummy)
          case "countstar AS Count_Star" => Some(Column.Aliased("Count_Star", ColumnType.Number, List.empty))
          case out if startsWithAgg(out) => Some(Column.Aliased(out, ColumnType.Number, List.empty))
          case out =>
            prev.foldLeft(Option.empty[Column]) { case (res, table) =>
              res.orElse(table.columns.find(_.name == out))
            }
        }.sequence

        columns
          .map(Table.Indexed(state.currentIdx, _))
          .map(ok)
          .getOrElse(err(s"Could not create output table for index ${state.currentIdx}"))
          .lift
      }
    }
  }

  def orderBy(input: Int): QplParser[String] = {
    for {
      state <- QplParser.get
      by    <- aliasedColumn | columnName
      isValidByColumn = state.idxToTable(input).columns.exists(_.name == by)
      _   <- (if (isValidByColumn) ok(()) else err(s"Column $by was not output before, can't order by it")).lift
      _   <- skipWhitespace.lift
      dir <- string("ASC") | string("DESC")
    } yield s"$by $dir"
  }

  def scan: QplParser[Operation] = {
    def predicate(table: String): QplParser[Predicate] = {
      def columnInTableOfType(typ: ColumnType): QplParser[String] = for {
        schema <- QplParser.ask
        column <- columnName
        t = schema.tableNames.indexOf(table)
        isColumnInTableOfType = schema.columnNames.zipWithIndex.exists { case (cn, i) =>
          cn == column && schema.columnToTable(i) == t && schema.columnTypes(i) == typ
        }
        _ <- (if (isColumnInTableOfType) ok(())
              else err(s"No column $column of type $typ in table $table")).lift
      } yield column

      def comparable(lhsType: ColumnType): QplParser[Comparable] = {
        import ColumnType.*

        lhsType match {
          case Number  => number | null_ | columnInTableOfType(Number).map(Comparable.Col(_))
          case Boolean => bool | null_ | columnInTableOfType(Boolean).map(Comparable.Col(_))
          case Text    => str | null_ | columnInTableOfType(Text).map(Comparable.Col(_))
          case Time    => str | null_ | columnInTableOfType(Time).map(Comparable.Col(_))
          case Others  => number | bool | str | null_ | columnInTableOfType(Others).map(Comparable.Col(_))
        }
      }

      val comparison: QplParser[Comparison] = for {
        schema          <- QplParser.ask
        columnWithAlias <- columnInTable(table)
        (column, _) = columnWithAlias
        typ <- columnType(schema, table, column)
          .map(ok)
          .getOrElse(err(s"No column $column in table $table"))
          .lift
        _   <- skipWhitespace.lift
        op  <- comparisonOp
        _   <- skipWhitespace.lift
        rhs <- comparable(typ)
      } yield Comparison.fromStringOp(op, Comparable.Col(column), rhs)

      chainl1(comparison.map(Predicate.Single(_)), andOr)
    }

    def getOutputTable(table: String, outs: List[(String, Option[String])]): QplParser[Table] = {
      QplParser.ask.map { schema =>
        Table.Named(
          table,
          outs.map {
            case ("1 AS One", _) =>
              Column.Dummy
            case (out, Some(alias)) =>
              Column.Plain(alias, columnType(schema, table, out).get, columnKey(schema, table, out))
            case (out, None) =>
              Column.Plain(out, columnType(schema, table, out).get, columnKey(schema, table, out))
          }
        )
      }
    }

    for {
      _          <- string("Scan Table [ ")
      table      <- tableName
      _          <- string(" ] ")
      predicate  <- predicateWrapper(predicate(table)).optional
      isDistinct <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _          <- string("Output [ ")
      outsWithAliases <- string("1 AS One").map(x => List(x -> None)) |
        columnInTable(table).sepBy1(skipWhitespace.lift ~> Atto.string(", ").lift)
      _ <-
        if (outsWithAliases.toSet.size == outsWithAliases.size) ok(()).lift
        else err("Duplicate outputs in Scan node").lift
      outputTable <- getOutputTable(table, outsWithAliases)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Scan(table, predicate, isDistinct)
  }

  def aggregate: QplParser[Operation] = {
    def groupBy(input: Int): QplParser[List[String]] = for {
      _       <- string("GroupBy [ ")
      columns <- columnInIndex(input, columnName).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _       <- string(" ] ")
    } yield columns

    def parseOutput(input: Int): QplParser[List[String]] = {
      val aliasedAggregate: QplParser[String] =
        for {
          agg        <- choice(Agg.values.map(agg => string(agg.toString.toUpperCase).as(agg)).toList)
          _          <- char('(').lift
          isDistinct <- string("DISTINCT ").as(true).optional.map(_.getOrElse(false))
          column     <- columnInIndex(input, columnName)
          _          <- string(") AS ")
          prefix     <- string(s"${agg.toString}_")
          dist       <- if (isDistinct) string("Dist_") else ok("").lift
          alias      <- stringCI(column)
        } yield s"$prefix$dist$alias"

      (string("countstar AS Count_Star") | aliasedAggregate | columnName)
        .sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
    }

    def validateOutput(input: Int, outs: List[String]): QplParser[Unit] = {
      val withoutAliases = outs.filterNot(startsWithAgg)

      QplParser.get.flatMap { state =>
        val prevColumns    = state.idxToTable(input).columns.map(_.name).toSet
        val isSubsetOfPrev = withoutAliases.forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (isSubsetOfPrev && noDups) ok(()) else err(s"Some outputs in Aggregate do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Aggregate ")
      inputs <- inputIds
      _ <- (if (inputs.length == 1) ok(())
            else err(s"Incorrect number of inputs to Aggregate, expected 1 but got ${inputs.length}")).lift
      input = inputs.head
      gbs         <- groupBy(input).optional
      _           <- string("Output [ ")
      outs        <- parseOutput(input)
      _           <- validateOutput(input, outs)
      outputTable <- getOutput(inputs, outs)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Aggregate(input, gbs.getOrElse(List.empty))
  }

  def filter: QplParser[Operation] = {
    def predicate(input: Int): QplParser[Predicate] = {
      def columnInIndexOfType(typ: ColumnType): QplParser[String] = for {
        state  <- QplParser.get
        column <- columnName
        table                 = state.idxToTable(input)
        isColumnInTableOfType = table.columns.exists(c => c.name == column && c.typ == typ)
        _ <- (if (isColumnInTableOfType) ok(())
              else err(s"No column $column of type $typ in table $table")).lift
      } yield column

      def comparable(lhsType: ColumnType): QplParser[Comparable] = {
        import ColumnType.*

        lhsType match {
          case Number  => number | null_ | columnInIndexOfType(Number).map(Comparable.Col(_))
          case Boolean => bool | null_ | columnInIndexOfType(Boolean).map(Comparable.Col(_))
          case Text    => str | null_ | columnInIndexOfType(Text).map(Comparable.Col(_))
          case Time    => str | null_ | columnInIndexOfType(Time).map(Comparable.Col(_))
          case Others  => number | bool | str | null_ | columnInIndexOfType(Others).map(Comparable.Col(_))
        }
      }

      val comparison: QplParser[Comparison] = for {
        state  <- QplParser.get
        column <- columnInIndex(input, columnName) | columnInIndex(input, aliasedColumn)
        typ <- state
          .idxToTable(input)
          .columns
          .find(_.name == column)
          .map(c => ok(c.typ))
          .getOrElse(err(s"Column $column is not in input $input"))
          .lift
        _   <- skipWhitespace.lift
        op  <- comparisonOp
        _   <- skipWhitespace.lift
        rhs <- comparable(typ)
      } yield Comparison.fromStringOp(op, Comparable.Col(column), rhs)

      chainl1(comparison.map(Predicate.Single(_)), andOr)
    }

    def validateOutput(input: Int, outs: List[String]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = state.idxToTable(input).columns.map(_.name).toSet
        val isDummy        = outs == List("1 AS One")
        val isSubsetOfPrev = outs.forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && (isSubsetOfPrev || isDummy)) ok(())
         else err(s"Some outputs in Filter do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Filter ")
      inputs <- inputIds
      _ <- (if (inputs.length == 1) ok(())
            else err(s"Incorrect number of inputs to Filter, expected 1 but got ${inputs.length}")).lift
      input = inputs.head
      pred       <- predicateWrapper(predicate(input)).optional
      isDistinct <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _          <- string("Output [ ")
      outs <- string("1 AS One").map(List(_)) |
        (columnName | aliasedColumn).sepBy1(skipWhitespace.lift ~> Atto.string(", ").lift)
      _           <- validateOutput(input, outs)
      outputTable <- getOutput(inputs, outs)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Filter(input, pred, isDistinct)
  }

  def top: QplParser[Operation] = {
    def validateOutput(input: Int, outs: List[String]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = state.idxToTable(input).columns.map(_.name).toSet
        val isSubsetOfPrev = outs.forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && isSubsetOfPrev) ok(())
         else err(s"Some outputs in Top do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Top ")
      inputs <- inputIds
      _ <- (if (inputs.length == 1) ok(())
            else err(s"Incorrect number of inputs to Top, expected 1 but got ${inputs.length}")).lift
      input = inputs.head
      _           <- string("Rows [ ")
      rows        <- int.lift
      _           <- string(" ] ")
      _           <- string("Output [ ")
      outs        <- (columnName | aliasedColumn).sepBy1(skipWhitespace.lift ~> Atto.string(", ").lift)
      _           <- validateOutput(input, outs)
      outputTable <- getOutput(inputs, outs)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Top(input, rows)
  }

  def sort: QplParser[Operation] = {
    def validateOutput(input: Int, outs: List[String]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = state.idxToTable(input).columns.map(_.name).toSet
        val isSubsetOfPrev = outs.forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && isSubsetOfPrev) ok(())
         else err(s"Some outputs in Sort do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Sort ")
      inputs <- inputIds
      _ <- (if (inputs.length == 1) ok(())
            else err(s"Incorrect number of inputs to Sort, expected 1 but got ${inputs.length}")).lift
      input = inputs.head
      _           <- string("OrderBy [ ")
      obs         <- orderBy(input).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _           <- string(" ] ")
      isDistinct  <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _           <- string("Output [ ")
      outs        <- (columnName | aliasedColumn).sepBy1(skipWhitespace.lift ~> Atto.string(", ").lift)
      _           <- validateOutput(input, outs)
      outputTable <- getOutput(inputs, outs)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Sort(input, obs, isDistinct)
  }

  def topSort: QplParser[Operation] = {
    def validateOutput(input: Int, outs: List[String]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = state.idxToTable(input).columns.map(_.name).toSet
        val isSubsetOfPrev = outs.forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && isSubsetOfPrev) ok(())
         else err(s"Some outputs in TopSort do not exist in the input")).lift
      }
    }

    for {
      _      <- string("TopSort ")
      inputs <- inputIds
      _ <- (if (inputs.length == 1) ok(())
            else err(s"Incorrect number of inputs to TopSort, expected 1 but got ${inputs.length}")).lift
      input = inputs.head
      _           <- string("Rows [ ")
      rows        <- int.lift
      _           <- string(" ] ")
      _           <- string("OrderBy [ ")
      obs         <- orderBy(input).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _           <- string(" ] ")
      withTies    <- string("WithTies [ true ] ").as(true).optional.map(_.getOrElse(false))
      _           <- string("Output [ ")
      outs        <- (aliasedColumn | columnName).sepBy1(skipWhitespace.lift ~> Atto.string(", ").lift)
      _           <- validateOutput(input, outs)
      outputTable <- getOutput(inputs, outs)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.TopSort(input, rows, obs, withTies)
  }

  def join: QplParser[Operation] = {
    def predicate(inputs: List[Int]): QplParser[Predicate] = {
      def columnInIndexOfType(typ: ColumnType): QplParser[String] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column)         = idxAndColumn
        table                 = state.idxToTable(idx)
        isColumnInTableOfType = table.columns.exists(c => c.name == column && c.typ == typ)
        _ <- (if (isColumnInTableOfType) ok(())
              else err(s"No column $column of type $typ in table $table")).lift
      } yield column

      def comparable(lhsType: ColumnType): QplParser[Comparable] = {
        import ColumnType.*

        lhsType match {
          case Number  => number | null_ | columnInIndexOfType(Number).map(Comparable.Col(_))
          case Boolean => bool | null_ | columnInIndexOfType(Boolean).map(Comparable.Col(_))
          case Text    => str | null_ | columnInIndexOfType(Text).map(Comparable.Col(_))
          case Time    => str | null_ | columnInIndexOfType(Time).map(Comparable.Col(_))
          case Others  => number | bool | str | null_ | columnInIndexOfType(Others).map(Comparable.Col(_))
        }
      }

      def isPrimaryKeyOf(key: KeyType, table: String): Boolean =
        key match {
          case KeyType.PrimaryKey(t) => table == t
          case KeyType.ForeignKey(_) => false
        }

      def isForeignKeyOf(key: KeyType, table: String): Boolean =
        key match {
          case KeyType.ForeignKey(t) => table == t
          case KeyType.PrimaryKey(_) => false
        }

      def comparableKeyAndType(lhsType: ColumnType, lhsTable: String, decider: (KeyType, String) => Boolean) = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column) = idxAndColumn
        t             = state.idxToTable(idx)
        isColumnInTableOfTypeAndKey = t.columns.exists { c =>
          c.name == column && c.typ == lhsType && c.keys.exists(decider(_, lhsTable))
        }
        _ <- (if (isColumnInTableOfTypeAndKey) ok(())
              else err(s"Invalid Join right-hand side: column $column in index $idx")).lift
      } yield Comparable.Col(column)

      def comparableKey(lhsType: ColumnType, lhsKeys: List[KeyType]): QplParser[Comparable] = {
        val p1: QplParser[Comparable] = choice {
          lhsKeys.map {
            case KeyType.PrimaryKey(table) => comparableKeyAndType(lhsType, table, isForeignKeyOf)
            case KeyType.ForeignKey(table) =>
              comparableKeyAndType(lhsType, table, isPrimaryKeyOf) |
              comparableKeyAndType(lhsType, table, isForeignKeyOf)
          }
        }

        val p2: QplParser[Comparable] = for {
          state        <- QplParser.get
          idxAndColumn <- indexedColumn(inputs)
          (idx, column) = idxAndColumn
          t             = state.idxToTable(idx)
          isValid = t.columns.exists {
            case Column.Aliased(name, typ, _) => name == column && typ == lhsType
            case _                            => false
          }
          _ <- (if (isValid) ok(())
                else err(s"Invalid Join right-hand side: column $column in index $idx")).lift
        } yield Comparable.Col(column)

        p1 | p2
      }

      val comparison: QplParser[Comparison] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column) = idxAndColumn
        lhsColInfo <- state
          .idxToTable(idx)
          .columns
          .find(_.name == column)
          .map {
            case Column.Dummy                    => ok((Column.Dummy.typ, Column.Dummy.keys, false))
            case Column.Plain(name, typ, keys)   => ok((typ, keys, false))
            case Column.Aliased(name, typ, keys) => ok((typ, keys, true))
          }
          .getOrElse(err(s"Column $column is not in input $idx"))
          .lift
        (typ, keys, isAliased) = lhsColInfo
        _   <- skipWhitespace.lift
        op  <- comparisonOp
        _   <- skipWhitespace.lift
        rhs <- if (op == "=" && !isAliased) comparableKey(typ, keys) else comparable(typ)
      } yield Comparison.fromStringOp(op, Comparable.Col(column), rhs)

      chainl1(comparison.map(Predicate.Single(_)), andOr)
    }

    def validateOutput(inputs: List[Int], outs: List[(Int, String)]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = inputs.map(state.idxToTable(_)).map(_.columns).flatten.map(_.name).toSet
        val isDummy        = outs.map(_._2) == List("1 AS One")
        val isSubsetOfPrev = outs.map(_._2).forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && (isSubsetOfPrev || isDummy)) ok(())
         else err(s"Some outputs in Join do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Join ")
      inputs <- inputIds
      _ <- (if (inputs.length == 2) ok(())
            else err(s"Incorrect number of inputs to Join, expected 2 but got ${inputs.length}")).lift
      pred       <- predicateWrapper(predicate(inputs)).optional
      isDistinct <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _          <- string("Output [ ")
      outsWithIndex <- string("1 AS One").map(x => List(-1 -> x)) |
        indexedColumn(inputs).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _           <- validateOutput(inputs, outsWithIndex)
      outputTable <- getTableFromIndexedOutputs(inputs, outsWithIndex)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Join(inputs, pred, isDistinct)
  }

  def intersect: QplParser[Operation] = {
    def predicate(inputs: List[Int]): QplParser[Predicate] = {
      def columnInIndexOfType(typ: ColumnType): QplParser[String] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column)         = idxAndColumn
        table                 = state.idxToTable(idx)
        isColumnInTableOfType = table.columns.exists(c => c.name == column && c.typ == typ)
        _ <- (if (isColumnInTableOfType) ok(())
              else err(s"No column $column of type $typ in table $table")).lift
      } yield column

      def comparable(lhsType: ColumnType): QplParser[Comparable] = {
        columnInIndexOfType(lhsType).map(Comparable.Col(_))
      }

      val comparison: QplParser[Comparison] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column) = idxAndColumn
        typ <- state
          .idxToTable(idx)
          .columns
          .find(_.name == column)
          .map(c => ok(c.typ))
          .getOrElse(err(s"Column $column is not in input $idx"))
          .lift
        _   <- skipWhitespace.lift
        op  <- comparisonOp
        _   <- skipWhitespace.lift
        rhs <- comparable(typ)
      } yield Comparison.fromStringOp(op, Comparable.Col(column), rhs)

      comparison.map(Predicate.Single(_))
    }

    def validateOutput(inputs: List[Int], outs: List[(Int, String)]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = inputs.map(state.idxToTable(_)).map(_.columns).flatten.map(_.name).toSet
        val isDummy        = outs.map(_._2) == List("1 AS One")
        val isSubsetOfPrev = outs.map(_._2).forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && (isSubsetOfPrev || isDummy)) ok(())
         else err(s"Some outputs in Intersect do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Intersect ")
      inputs <- inputIds
      _ <- (if (inputs.length == 2) ok(())
            else err(s"Incorrect number of inputs to Intersect, expected 2 but got ${inputs.length}")).lift
      pred       <- predicateWrapper(predicate(inputs)).optional
      isDistinct <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _          <- string("Output [ ")
      outsWithIndex <- string("1 AS One").map(x => List(-1 -> x)) |
        indexedColumn(inputs).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _           <- validateOutput(inputs, outsWithIndex)
      outputTable <- getTableFromIndexedOutputs(inputs, outsWithIndex)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Intersect(inputs, pred, isDistinct)
  }

  def except: QplParser[Operation] = {
    def predicate(inputs: List[Int]): QplParser[Predicate] = {
      def columnInIndexOfType(typ: ColumnType): QplParser[String] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column)         = idxAndColumn
        table                 = state.idxToTable(idx)
        isColumnInTableOfType = table.columns.exists(c => c.name == column && c.typ == typ)
        _ <- (if (isColumnInTableOfType) ok(())
              else err(s"No column $column of type $typ in table $table")).lift
      } yield column

      def comparable(lhsType: ColumnType): QplParser[Comparable] = {
        null_ | columnInIndexOfType(lhsType).map(Comparable.Col(_))
      }

      val comparison: QplParser[Comparison] = for {
        state        <- QplParser.get
        idxAndColumn <- indexedColumn(inputs)
        (idx, column) = idxAndColumn
        typ <- state
          .idxToTable(idx)
          .columns
          .find(_.name == column)
          .map(c => ok(c.typ))
          .getOrElse(err(s"Column $column is not in input $idx"))
          .lift
        _   <- skipWhitespace.lift
        op  <- comparisonOp
        _   <- skipWhitespace.lift
        rhs <- comparable(typ)
      } yield Comparison.fromStringOp(op, Comparable.Col(column), rhs)

      chainl1(comparison.map(Predicate.Single(_)), andOr)
    }

    def validateOutput(inputs: List[Int], outs: List[(Int, String)]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = inputs.map(state.idxToTable(_)).map(_.columns).flatten.map(_.name).toSet
        val isDummy        = outs.map(_._2) == List("1 AS One")
        val isSubsetOfPrev = outs.map(_._2).forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && (isSubsetOfPrev || isDummy)) ok(())
         else err(s"Some outputs in Except do not exist in the input")).lift
      }
    }

    def exceptColumn(inputs: List[Int]): QplParser[String] = {
      for {
        _            <- string("ExceptColumns [ ")
        idxAndColumn <- indexedColumn(inputs)
        _            <- string(" ] ")
      } yield idxAndColumn._2
    }

    for {
      _      <- string("Except ")
      inputs <- inputIds
      _ <- (if (inputs.length == 2) ok(())
            else err(s"Incorrect number of inputs to Except, expected 2 but got ${inputs.length}")).lift
      pred       <- predicateWrapper(predicate(inputs)) || exceptColumn(inputs)
      isDistinct <- string("Distinct [ true ] ").as(true).optional.map(_.getOrElse(false))
      _          <- string("Output [ ")
      outsWithIndex <- string("1 AS One").map(x => List(-1 -> x)) |
        indexedColumn(inputs).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _           <- validateOutput(inputs, outsWithIndex)
      outputTable <- getTableFromIndexedOutputs(inputs, outsWithIndex)
      _           <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _           <- string(" ]")
    } yield Operation.Except(inputs, pred, isDistinct)
  }

  def union: QplParser[Operation] = {
    def validateOutput(inputs: List[Int], outs: List[(Int, String)]): QplParser[Unit] = {
      QplParser.get.flatMap { state =>
        val prevColumns    = inputs.map(state.idxToTable(_)).map(_.columns).flatten.map(_.name).toSet
        val isDummy        = outs.map(_._2) == List("1 AS One")
        val isSubsetOfPrev = outs.map(_._2).forall(prevColumns.contains)
        val noDups         = outs.toSet.size == outs.size
        (if (noDups && (isSubsetOfPrev || isDummy)) ok(())
         else err(s"Some outputs in Union do not exist in the input")).lift
      }
    }

    for {
      _      <- string("Union ")
      inputs <- inputIds
      _ <- (if (inputs.length == 2) ok(())
            else err(s"Incorrect number of inputs to Union, expected 2 but got ${inputs.length}")).lift
      _             <- string("Output [ ")
      outsWithIndex <- indexedColumn(inputs).sepBy1((skipWhitespace ~> Atto.string(", ")).lift)
      _             <- validateOutput(inputs, outsWithIndex)
      outputTable   <- getTableFromIndexedOutputs(inputs, outsWithIndex)
      _             <- QplParser.modify(s => s.copy(idxToTable = s.idxToTable.updated(s.currentIdx, outputTable)))
      _             <- string(" ]")
    } yield Operation.Union(inputs)
  }

  val qpl: QplParser[Qpl] = (for {
    _         <- QplParser.modify(_.incrementCurrentIndex)
    state     <- QplParser.get
    _         <- string(s"#${state.currentIdx}")
    _         <- string(" = ")
    operation <- scan | aggregate | filter | top | sort | topSort | join | intersect | except | union
    _         <- QplParser.modify(s => s.copy(seen = s.seen + state.currentIdx))
  } yield Line(state.currentIdx, operation)).sepBy1(string(" ; "))
}
