package com.beneyal.qpl

import scala.xml.*
import zio.*
import zio.json.*
import java.nio.file.Path

import com.beneyal.qpl.parsing.*
import com.beneyal.qpl.domain.ExecutionPlan
import scala.util.Failure
import scala.util.Success

object reading {
  final case class JsonSchema(
      @jsonField("db_id") dbId: String,
      @jsonField("table_names_original") tableNames: Chunk[String],
      @jsonField("column_names_original") columnNames: Chunk[(Int, String)]
  ) {
    def toSchema: Schema = {
      val db = columnNames.foldLeft(Map.empty[String, Chunk[String]]) { case (acc, (ti, cn)) =>
        if (ti == -1) acc
        else {
          val tn = tableNames(ti)
          if (acc.contains(tn)) acc.updated(tn, acc(tn) :+ cn)
          else acc + (tn -> Chunk(cn))
        }
      }
      Schema(dbId, db - "*")
    }
  }

  object JsonSchema {
    given JsonCodec[JsonSchema] = DeriveJsonCodec.gen
  }

  final case class JsonInstance(
      @jsonField("question_id") questionId: Int,
      @jsonField("db_id") dbId: String,
      question: String,
      evidence: String,
      @jsonField("SQL") sql: String,
      difficulty: String,
      @jsonField("TSQL") tsql: String,
      ep: Option[String],
      @jsonField("err_msg") errMsg: Option[String]
  )

  object JsonInstance {
    given JsonCodec[JsonInstance] = DeriveJsonCodec.gen
  }

  final case class Schema(
      name: String,
      db: Map[String, Chunk[String]]
  )

  final case class BirdInstance(
      id: Int,
      dbId: String,
      query: String,
      question: String,
      difficulty: String,
      ep: ExecutionPlan
  )

  def readDataset(datasetPath: Path /* , tablesPath: Path */ ): Task[Chunk[BirdInstance]] = {
    for {
      // tablesJson  <- ZIO.readFile(tablesPath)
      // schemasList <- ZIO.fromEither(tablesJson.fromJson[Chunk[JsonSchema]]).mapError(new RuntimeException(_))
      // schemas = schemasList.map(s => s.dbId -> s).toMap
      dataset   <- ZIO.readFile(datasetPath)
      instances <- ZIO.fromEither(dataset.fromJson[Chunk[JsonInstance]]).mapError(new RuntimeException(_))
      instancesWithEps = instances.filter(_.ep.isDefined)
      eps = instancesWithEps.map { ins =>
        ins.ep.map(XML.loadString).toRight(new RuntimeException("No EP")).toTry.flatMap(parseExecutionPlan)
      }
      (result, numErrors) = instancesWithEps.zip(eps).foldLeft(Chunk.empty[BirdInstance], 0) {
        case ((result, numErrors), (ji, epTry)) =>
          epTry match {
            case Success(value) =>
              (result :+ BirdInstance(ji.questionId, ji.dbId, ji.tsql, ji.question, ji.difficulty, value), numErrors)
            case Failure(ex) =>
              println(s"Skipping ${ji.questionId} because of ${ex.getLocalizedMessage}")
              // ex.printStackTrace()
              (result, numErrors + 1)
          }
      }
      _ = println(s"Skipped $numErrors instances out of ${eps.length}")
    } yield result
  }
}
