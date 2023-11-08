package com.beneyal

import atto.*, Atto.*
import cats.*
import cats.syntax.all.*
import com.beneyal.parse.{ColumnType, Qpl, QplParser, SqlSchema}
import io.brunk.tokenizers.Tokenizer
import io.circe.{Codec, HCursor}
import io.circe.Decoder.Result
import io.circe.derivation.{Configuration, ConfiguredCodec}
import io.circe.generic.semiauto.*
import sttp.model.StatusCode
import sttp.tapir.Schema
import sttp.tapir.generic.auto.*
import sttp.tapir.swagger.bundle.SwaggerInterpreter
import sttp.tapir.json.circe.*
import sttp.tapir.ztapir.*
import zio.*

import java.nio.file.Paths

object Endpoints {
  type PicardEndpoint = ZServerEndpoint[ServerState, Any]
  type Detokenize     = Chunk[Long] => ZIO[Any, Nothing, String]

  final case class BatchParseRequest(inputIds: Chunk[Chunk[Long]], topTokens: Chunk[Chunk[Long]])
      derives ConfiguredCodec

  object BatchParseRequest {
    given Codec[BatchParseRequest] = deriveCodec
    given Configuration            = Configuration.default.withSnakeCaseMemberNames
  }

  enum FeedResult derives ConfiguredCodec {
    case Complete
    case Partial
    case Failure(message: String)
  }

  object FeedResult {
    given Codec[FeedResult] = deriveCodec
    given Configuration =
      Configuration.default.withSnakeCaseMemberNames
        .withDiscriminator("tag")
        .withTransformConstructorNames(_.toLowerCase)
  }

  final case class BatchFeedResult(batchId: Int, topToken: Long, feedResult: FeedResult) derives ConfiguredCodec

  object BatchFeedResult {
    given Codec[BatchFeedResult] = deriveCodec
    given Configuration          = Configuration.default.withSnakeCaseMemberNames
  }

  final case class ValidationRequest(qpl: String) derives ConfiguredCodec

  object ValidationRequest {
    given Codec[ValidationRequest] = deriveCodec
    given Configuration            = Configuration.default.withSnakeCaseMemberNames
  }

  enum ValidationResult derives ConfiguredCodec {
    case Invalid(reason: String)
    case Valid
  }

  object ValidationResult {
    given Codec[ValidationResult] = deriveCodec
    given Configuration =
      Configuration.default.withSnakeCaseMemberNames
        .withDiscriminator("tag")
        .withTransformConstructorNames(_.toLowerCase)
  }

  final case class PartialParse(decodedInputIds: String, result: ParseResult[Qpl])

  final case class ServerState(
      counter: Ref[Int],
      tokenizer: Ref[Option[Tokenizer]],
      schemas: Ref[Map[String, SqlSchema]],
      detokenize: Ref[Option[Detokenize]],
      partialParses: Ref[Map[Chunk[Long], PartialParse]]
  )

  given Schema[Map[Int, Int]] = Schema.schemaForMap(_.toString)

  val parseQpl: PicardEndpoint =
    endpoint.post
      .in("parse")
      .in(jsonBody[BatchParseRequest])
      .out(jsonBody[Chunk[BatchFeedResult]])
      .errorOut(statusCode(StatusCode.BadRequest).and(plainBody[String]))
      .zServerLogic { req =>
        for {
          state         <- ZIO.service[ServerState]
          detokenizeOpt <- state.detokenize.get
          detokenize    <- ZIO.fromOption(detokenizeOpt).mapError(_ => "Tokenizer not registered")
          result        <- batchFeed(detokenize, req.inputIds, req.topTokens)
        } yield result
      }

  val validateQpl: PicardEndpoint =
    endpoint.post
      .in("validate")
      .in(jsonBody[ValidationRequest])
      .out(jsonBody[ValidationResult])
      .zServerLogic { req =>
        ZIO.serviceWithZIO[ServerState](_.schemas.get).map { schemas =>
          val parser = for {
            schema <- mkSchemaParser(schemas)
            _      <- skipWhitespace ~> char('|') <~ skipWhitespace
            res    <- QplParser.make(schema)
          } yield res

          parser.parseOnly(req.qpl) match {
            case ParseResult.Done("", _) => ValidationResult.Valid
            case ParseResult.Done(input, _) =>
              ValidationResult.Invalid(s"Error in line: ${input.drop(3).takeWhile(_ != ';').strip}")
            case ParseResult.Partial(_)          => ValidationResult.Invalid("Partial result")
            case ParseResult.Fail(_, _, message) => ValidationResult.Invalid(s"Failed with message: $message")
          }
        }
      }

  val registerSchema: PicardEndpoint =
    endpoint.post.in("schema").in(jsonBody[SqlSchema]).zServerLogic { schema =>
      ZIO.serviceWithZIO[ServerState](_.schemas.update(_.updated(schema.dbId, schema))) *> initializeParserCache
    }

  val registerTokenizer: PicardEndpoint =
    endpoint.post.in("tokenizer").in(stringJsonBody).zServerLogic { json =>
      for {
        sem <- Semaphore.make(permits = 1)
        _   <- ZIO.writeFile("./tokenizer.json", json).orDie
        tokenizer  = Tokenizer.fromFile(Paths.get("./tokenizer.json"))
        detokenize = (inputIds: Seq[Long]) => sem.withPermit(ZIO.succeed(tokenizer.decode(inputIds)))
        _ <- ZIO.serviceWithZIO[ServerState](_.tokenizer.set(Some(tokenizer)))
        _ <- ZIO.serviceWithZIO[ServerState](_.detokenize.set(Some(detokenize)))
        _ <- initializeParserCache
      } yield ()
    }

  val debugGetSchemas: PicardEndpoint =
    endpoint.get.in("schemas" / path[String]).zServerLogic { dbId =>
      ZIO.serviceWithZIO[ServerState](_.schemas.get).flatMap { schemas =>
        pprint.pprintln(schemas(dbId), height = 9999)
        ZIO.unit
      }
    }

  val health: PicardEndpoint =
    endpoint.get.in("health").zServerLogic { _ => ZIO.unit }

  val apiEndpoints: List[ZServerEndpoint[ServerState, Any]] =
    List(registerTokenizer, registerSchema, parseQpl, validateQpl, debugGetSchemas, health)

  val docEndpoints: List[ZServerEndpoint[ServerState, Any]] =
    SwaggerInterpreter().fromServerEndpoints(apiEndpoints, "qpl-parser", "1.0.0")

  val all: List[ZServerEndpoint[ServerState, Any]] = apiEndpoints ++ docEndpoints

  def batchFeed(
      detokenize: Detokenize,
      inputIds: Chunk[Chunk[Long]],
      topTokens: Chunk[Chunk[Long]]
  ): ZIO[ServerState, Nothing, Chunk[BatchFeedResult]] = {
    val triplets = topTokens
      .zip(inputIds)
      .zip(LazyList.from(0))
      .map { case ((tokens, inputs), batchId) =>
        tokens.map(t => (batchId, inputs, t))
      }
      .flatten

    ZIO.foreachPar(triplets) { case (batchId, inputs, token) =>
      feed(detokenize, inputs, token).map(BatchFeedResult(batchId, token, _))
    }
  }

  def feed(detokenize: Detokenize, inputIds: Chunk[Long], token: Long): ZIO[ServerState, Nothing, FeedResult] = {
    def getPartialParseZIO: ZIO[ServerState, Nothing, PartialParse] = {
      for {
        pp              <- lookupResult(detokenize, inputIds)
        decodedAndToken <- decodedTokenFromDifference(pp.decodedInputIds)
        (decoded, decodedToken) = decodedAndToken
        partialParseResult = decodedToken match {
          case "</s>" => pp.result.done
          case s      => pp.result.feed(s)
        }
      } yield PartialParse(decoded, partialParseResult)
    }

    def decodedTokenFromDifference(decodedInputIds: String): ZIO[Any, Nothing, (String, String)] = {
      for {
        decoded <- detokenize(inputIds :+ token)
        decodedToken <- stripPrefix(decodedInputIds, decoded) match {
          case Some(value) => ZIO.succeed(value)
          case None        => ZIO.dieMessage("prefix error")
        }
      } yield (decoded, decodedToken)
    }

    for {
      _            <- nukeParserCacheEvery(10000)
      partialParse <- getPartialParseZIO
      _ <- ZIO.serviceWithZIO[ServerState](_.partialParses.update(_.updated(inputIds :+ token, partialParse)))
    } yield partialParse.result match {
      case ParseResult.Done("", _)          => FeedResult.Complete
      case ParseResult.Done(notConsumed, _) => FeedResult.Failure(s"notConsumed: $notConsumed")
      case ParseResult.Partial(_)           => FeedResult.Partial
      case ParseResult.Fail(_, _, message)  => FeedResult.Failure(message)
    }
  }

  def initializeParserCache: ZIO[ServerState, Nothing, Unit] = for {
    _       <- ZIO.serviceWithZIO[ServerState](_.partialParses.set(Map.empty))
    schemas <- ZIO.serviceWithZIO[ServerState](_.schemas.get)
    partialParse = getPartialParse(schemas, "")
    _ <- ZIO.serviceWithZIO[ServerState](_.partialParses.update(_.updated(Chunk.empty, partialParse)))
  } yield ()

  def nukeParserCacheEvery(n: Int): ZIO[ServerState, Nothing, Unit] = for {
    counter <- ZIO.serviceWithZIO[ServerState](_.counter.updateAndGet(_ + 1))
    _       <- if (counter % n == 0) ZIO.serviceWithZIO[ServerState](_.partialParses.set(Map.empty)) else ZIO.unit
  } yield ()

  def lookupResult(decode: Detokenize, inputIds: Chunk[Long]): ZIO[ServerState, Nothing, PartialParse] = {
    for {
      partialParses <- ZIO.serviceWithZIO[ServerState](_.partialParses.get)
      schemas       <- ZIO.serviceWithZIO[ServerState](_.schemas.get)
      pp <- partialParses.get(inputIds) match {
        case Some(pp) => ZIO.succeed(pp)
        case None     => decode(inputIds).map(getPartialParse(schemas, _))
      }
      _ <- ZIO.serviceWithZIO[ServerState](_.partialParses.update(_.updated(inputIds, pp)))
    } yield pp
  }

  def getPartialParse(schemas: Map[String, SqlSchema], input: String): PartialParse =
    PartialParse(input, mkParser(schemas).parse(input))

  def mkParser(schemas: Map[String, SqlSchema]): Parser[Qpl] = {
    val specialToken: Parser[Unit] = for {
      _ <- char('<')
      _ <- string("pad") | string("s") | string("/s")
      _ <- char('>')
    } yield ()

    for {
      _      <- skipWhitespace
      _      <- many(specialToken)
      schema <- mkSchemaParser(schemas)
      _      <- skipWhitespace ~> char('|') <~ skipWhitespace
      res    <- QplParser.make(schema)
    } yield res
  }

  def mkSchemaParser(schemas: Map[String, SqlSchema]): Parser[SqlSchema] = {
    def lowercaseSchema(dbId: String): Parser[String] = for {
      dbId0 <- stringCI(dbId)
      _     <- if (dbId.toLowerCase == dbId0.toLowerCase) ok(()) else err(s"Schema $dbId0 does not exist")
    } yield dbId

    schemas.toList
      .sortBy(_._1.length)(using Ordering[Int].reverse)
      .foldLeft(Alternative[Parser].empty) { case (acc, (dbId, schema)) =>
        acc | lowercaseSchema(dbId).as(schema)
      }
  }

  def stripPrefix(prefix: String, string: String): Option[String] =
    if (string.startsWith(prefix)) Some(string.stripPrefix(prefix)) else None
}
