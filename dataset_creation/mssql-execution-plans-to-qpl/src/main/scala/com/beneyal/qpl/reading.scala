package com.beneyal.qpl

import scala.xml.*
import zio.*
import zio.json.*
import java.nio.file.Path

import com.beneyal.qpl.parsing.*
import com.beneyal.qpl.domain.ExecutionPlan

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
      id: String,
      @jsonField("db_id") dbId: String,
      query: String,
      question: String,
      difficulty: String,
      ep: Option[String]
  )

  object JsonInstance {
    given JsonCodec[JsonInstance] = DeriveJsonCodec.gen
  }

  final case class Schema(
      name: String,
      db: Map[String, Chunk[String]]
  )

  final case class SpiderInstance(
      id: String,
      db: Schema,
      query: String,
      question: String,
      difficulty: String,
      ep: ExecutionPlan
  )

  def readDataset(datasetPath: Path, tablesPath: Path): Task[Chunk[SpiderInstance]] = {
    for {
      tablesJson  <- ZIO.readFile(tablesPath)
      schemasList <- ZIO.fromEither(tablesJson.fromJson[Chunk[JsonSchema]]).mapError(new RuntimeException(_))
      schemas = schemasList.map(s => s.dbId -> s).toMap
      dataset   <- ZIO.readFile(datasetPath)
      instances <- ZIO.fromEither(dataset.fromJson[Chunk[JsonInstance]]).mapError(new RuntimeException(_))
      instancesWithEps = instances.filter(_.ep.isDefined)
      eps = instancesWithEps.map { ins =>
        ins.ep.map(XML.loadString).toRight(new RuntimeException("No EP")).toTry.flatMap(parseExecutionPlan)
      }
      result <- ZIO.foreach(instancesWithEps.zip(eps)) { case (ji, epTry) =>
        for {
          ep <- ZIO
            .fromTry(epTry)
            .mapError(t =>
              new RuntimeException(s"${t.getLocalizedMessage} for ${ji.id}: ${t.getStackTrace.mkString("\n")}")
            )
        } yield SpiderInstance(ji.id, schemas(ji.dbId).toSchema, ji.query, ji.question, ji.difficulty, ep)
      }
    } yield result
  }
}
