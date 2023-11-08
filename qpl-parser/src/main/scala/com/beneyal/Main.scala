package com.beneyal

import com.beneyal.Endpoints.*
import com.beneyal.parse.SqlSchema
import com.comcast.ip4s.{Host, Port, port}
import org.http4s.ember.server.EmberServerBuilder
import org.http4s.server.Router
import sttp.tapir.server.http4s.ztapir.ZHttp4sServerInterpreter
import zio.interop.catz.*
import zio.stream.interop.fs2z.io.networkInstance
import zio.*
import io.brunk.tokenizers.Tokenizer

object Main extends ZIOAppDefault {
  type PicardIO[+A] = RIO[ServerState, A]

  val serverStateLayer = ZLayer {
    for {
      counter       <- Ref.make[Int](0)
      tokenizer     <- Ref.make[Option[Tokenizer]](None)
      schemas       <- Ref.make[Map[String, SqlSchema]](Map.empty)
      detokenize    <- Ref.make[Option[Detokenize]](None)
      partialParses <- Ref.make[Map[Chunk[Long], PartialParse]](Map.empty)
    } yield ServerState(counter, tokenizer, schemas, detokenize, partialParses)
  }

  override def run = {
    val routes = ZHttp4sServerInterpreter().from(Endpoints.all).toRoutes[ServerState]
    val port   = port"8081"

    EmberServerBuilder
      .default[PicardIO]
      .withHost(Host.fromString("0.0.0.0").get)
      .withPort(port)
      .withHttpApp(Router("/" -> routes).orNotFound)
      .build
      .use { server =>
        for {
          _ <- Console.printLine(s"Server started at http://0.0.0.0:${server.address.getPort}.")
          _ <- ZIO.never
        } yield ()
      }
      .provide(serverStateLayer)
  }
}
