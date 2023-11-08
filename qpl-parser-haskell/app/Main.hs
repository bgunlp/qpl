{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import Control.Applicative (Alternative (empty), (<|>))
import Control.Concurrent.Async (mapConcurrently)
import Control.Concurrent.QSem (newQSem, signalQSem, waitQSem)
import Control.Concurrent.STM (STM, TVar, atomically, modifyTVar, newTVar, readTVar, readTVarIO, writeTVar)
import Control.Exception (bracket_)
import Control.Monad (ap)
import Control.Monad.Reader (MonadIO (liftIO), MonadReader (ask), ReaderT (runReaderT), asks, lift, when)
import Data.Aeson
import Data.Aeson.Types hiding (Parser, unexpected)
import Data.Attoparsec.Text (Parser, char, endOfInput, many', many1, string)
import Data.Attoparsec.Text qualified as Atto
import Data.ByteString (toStrict)
import Data.Char (toLower)
import Data.Either (isRight)
import Data.Foldable (Foldable (foldl'))
import Data.Function (on)
import Data.Functor (($>), (<&>))
import Data.HashMap.Strict (HashMap)
import Data.HashMap.Strict qualified as HashMap
import Data.List (sortBy)
import Data.Text (Text)
import Data.Text qualified as T
import Debug.Trace (trace)
import GHC.Generics
import Network.Wai.Handler.Warp
import Parse (ColumnType, Qpl, SqlSchema (peDbId), mkQplParser)
import Servant
import Text.Parser.Char (alphaNum, spaces)
import Text.Parser.Combinators (Parsing (eof, unexpected))
import Tokenizers (Tokenizer, createTokenizerFromJSONConfig, decode)

data BatchParseRequest = BatchParseRequest
    { bprInputIds :: [InputIds]
    , bprTopTokens :: [[Token]]
    }
    deriving (Generic)

instance FromJSON BatchParseRequest where
    parseJSON = genericParseJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

instance ToJSON BatchParseRequest where
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

newtype ValidationRequest = ValidationRequest {vrQpl :: Text} deriving (Generic)

instance FromJSON ValidationRequest where
    parseJSON = genericParseJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 2}

instance ToJSON ValidationRequest where
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 2}

type ParsingAPI =
    "tokenizer" :> ReqBody '[JSON] Value :> Post '[JSON] NoContent
        :<|> "schema" :> ReqBody '[JSON] SqlSchema :> Post '[JSON] NoContent
        :<|> "parse" :> ReqBody '[JSON] BatchParseRequest :> Post '[JSON] [BatchFeedResult]
        :<|> "validate" :> ReqBody '[JSON] ValidationRequest :> Post '[JSON] Bool

data State = State
    { stCounter :: TVar Int
    , stTokenizer :: TVar (Maybe Tokenizer)
    , stSchemas :: TVar (HashMap DbId SqlSchema)
    , stDetokenize :: TVar (Maybe Detokenize)
    , stPartialParses :: TVar (HashMap InputIds PartialParse)
    }

type AppM = ReaderT State Handler

type DbId = Text

type Token = Int

type InputIds = [Token]

type Detokenize = InputIds -> IO String

data FeedParseFailure = FeedParseFailure
    { fpfInput :: Text
    , fpfContexts :: [Text]
    , fpfDescription :: Text
    }
    deriving (Generic)

instance FromJSON FeedParseFailure where
    parseJSON = genericParseJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

instance ToJSON FeedParseFailure where
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

data FeedPartialSuccess = FeedPartialSuccess
    deriving (Generic)

instance FromJSON FeedPartialSuccess
instance ToJSON FeedPartialSuccess

newtype FeedCompleteSuccess = FeedCompleteSuccess {leftover :: Text}
    deriving (Generic)

instance FromJSON FeedCompleteSuccess
instance ToJSON FeedCompleteSuccess

data FeedResult
    = FeedResultFeedParseFailure FeedParseFailure
    | FeedResultFeedPartialSuccess FeedPartialSuccess
    | FeedResultFeedCompleteSuccess FeedCompleteSuccess
    deriving (Generic)

instance FromJSON FeedResult
instance ToJSON FeedResult

data BatchFeedResult = BatchFeedResult
    { bfrBatchId :: Int
    , bfrTopToken :: Token
    , bfrFeedResult :: FeedResult
    }
    deriving (Generic)

instance FromJSON BatchFeedResult where
    parseJSON = genericParseJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

instance ToJSON BatchFeedResult where
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 3}

data PartialParse = PartialParse !Text !(Atto.Result Qpl)

instance FromJSON ColumnType where
    parseJSON = genericParseJSON defaultOptions{constructorTagModifier = lowerFirst . tail}

instance ToJSON ColumnType where
    toJSON = genericToJSON defaultOptions{constructorTagModifier = lowerFirst . tail}

instance FromJSON SqlSchema where
    parseJSON = genericParseJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 2}

instance ToJSON SqlSchema where
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = camelTo2 '_' . lowerFirst . drop 2}

finalize :: Atto.IResult Text a -> Atto.IResult Text a
finalize r = case Atto.feed r mempty of
    Atto.Done notConsumed _ | not (T.null notConsumed) -> Atto.Fail mempty mempty "Not consumed: notConsumed"
    r' -> r'

nukeParserCacheEverySTM :: Int -> TVar Int -> TVar (HashMap InputIds PartialParse) -> STM ()
nukeParserCacheEverySTM n counter partialParses = do
    _ <- modifyTVar counter (+ 1)
    c <- readTVar counter
    case c `mod` n of
        0 -> nukeParserCache partialParses
        _ -> pure ()

toFeedResult :: Atto.IResult Text a -> FeedResult
toFeedResult (Atto.Done notConsumed _) =
    FeedResultFeedCompleteSuccess (FeedCompleteSuccess notConsumed)
toFeedResult (Atto.Partial _) =
    FeedResultFeedPartialSuccess FeedPartialSuccess
toFeedResult (Atto.Fail i contexts description) =
    FeedResultFeedParseFailure (FeedParseFailure i (T.pack <$> contexts) (T.pack description))

mkSchemaParser :: HashMap DbId SqlSchema -> Parser SqlSchema
mkSchemaParser sqlSchemas =
    foldl'
        (\acc (dbId, schema) -> acc <|> lowercaseSchema dbId $> schema)
        empty
        (sortBy (compare `on` (negate . T.length . fst)) (HashMap.toList sqlSchemas))
  where
    lowercaseSchema :: Text -> Parser Text
    lowercaseSchema dbId = do
        dbId' <- T.pack <$> many1 (alphaNum <|> char '_')
        when (T.toLower dbId /= T.toLower dbId') (unexpected $ "Schema \"" <> T.unpack dbId' <> "\" does not exist")
        pure dbId

mkParser :: Parser SqlSchema -> (SqlSchema -> Parser Qpl) -> Parser Qpl
mkParser schemaParser mkMainParser = do
    spaces
    many' specialToken
    spaces
    schema <- schemaParser
    spaces *> char '|' <* spaces
    mkMainParser schema <* eof
  where
    specialToken :: Parser ()
    specialToken = do
        char '<'
        string "pad" <|> string "s" <|> string "/s"
        char '>'
        pure ()

lowerFirst :: String -> String
lowerFirst "" = ""
lowerFirst (c : cs) = toLower c : cs

nt :: State -> AppM a -> Handler a
nt s x = runReaderT x s

initState :: IO State
initState =
    atomically $
        State
            <$> newTVar 0
            <*> newTVar Nothing
            <*> newTVar mempty
            <*> newTVar Nothing
            <*> newTVar mempty

registerTokenizer :: Value -> AppM NoContent
registerTokenizer jsonValue = do
    tokenizer <- liftIO $ createTokenizerFromJSONConfig $ toStrict $ encode jsonValue
    tokSem <- liftIO $ newQSem 1
    State{..} <- ask
    liftIO $ atomically $ do
        writeTVar stTokenizer . Just $ tokenizer
        writeTVar stDetokenize . Just $ \inputIds ->
            bracket_
                (waitQSem tokSem)
                (signalQSem tokSem)
                (Tokenizers.decode tokenizer inputIds)
    pure NoContent

registerSchema :: SqlSchema -> AppM NoContent
registerSchema schema = do
    s <- asks stSchemas
    liftIO $ atomically $ modifyTVar s $ HashMap.insert (peDbId schema) schema
    pure NoContent

getPartialParse :: HashMap DbId SqlSchema -> (SqlSchema -> Parser Qpl) -> Text -> PartialParse
getPartialParse sqlSchemas mkMainParser =
    let schemaParser = mkSchemaParser sqlSchemas
        m = mkParser schemaParser mkMainParser
     in ap PartialParse $ Atto.feed (Atto.parse m mempty)

initializeParserCacheSTM ::
    (SqlSchema -> Parser Qpl) ->
    TVar (HashMap DbId SqlSchema) ->
    TVar (HashMap InputIds PartialParse) ->
    STM ()
initializeParserCacheSTM mainParser sqlSchemas partialParses = do
    nukeParserCache partialParses
    partialParse <-
        getPartialParse
            <$> readTVar sqlSchemas
            <*> pure mainParser
            <*> pure mempty
    modifyTVar partialParses (HashMap.insert mempty partialParse)

nukeParserCache :: TVar (HashMap InputIds PartialParse) -> STM ()
nukeParserCache partialParses = writeTVar partialParses HashMap.empty

decodedTokenFromDifferenceIO :: (InputIds -> IO String) -> InputIds -> Token -> Text -> IO (Text, Text)
decodedTokenFromDifferenceIO decode inputIds token decodedInputIds = do
    decoded <- T.pack <$> decode (inputIds <> [token])
    let maybeDecodedToken = T.stripPrefix decodedInputIds decoded
    maybe (fail "Prefix error") (pure . (decoded,)) maybeDecodedToken

lookupResultIO ::
    TVar (HashMap DbId SqlSchema) ->
    (SqlSchema -> Parser Qpl) ->
    (InputIds -> IO String) ->
    TVar (HashMap InputIds PartialParse) ->
    InputIds ->
    IO PartialParse
lookupResultIO sqlSchemas mkMainParser decode partialParses inputIds = do
    schemas <- readTVarIO sqlSchemas
    parses <- readTVarIO partialParses
    !pp <- case HashMap.lookup inputIds parses of
        Just partialParse -> pure partialParse
        Nothing -> do
            decodedInputIds <- decode inputIds
            let !partialParse = getPartialParse schemas mkMainParser (T.pack decodedInputIds)
            pure partialParse
    atomically $ modifyTVar partialParses $ HashMap.insert inputIds pp
    pure pp

feedParserIO :: Atto.Result Qpl -> Text -> IO (Atto.Result Qpl)
feedParserIO partialParseResult decodedToken = do
    let !r = case decodedToken of
            "</s>" -> finalize partialParseResult
            s -> Atto.feed partialParseResult s
     in pure r

feedIO ::
    TVar Int ->
    TVar (HashMap DbId SqlSchema) ->
    (SqlSchema -> Parser Qpl) ->
    Detokenize ->
    TVar (HashMap InputIds PartialParse) ->
    InputIds ->
    Token ->
    IO FeedResult
feedIO counter sqlSchemas mkMainParser detokenize partialParses inputIds token = do
    liftIO . atomically $ nukeParserCacheEverySTM 10000 counter partialParses
    partialParse <- getPartialParseIO detokenize
    liftIO . atomically . modifyTVar partialParses $ HashMap.insert (inputIds <> [token]) partialParse
    toFeedResultIO partialParse
  where
    getPartialParseIO tokenizer = do
        PartialParse decodedInputIds partialParseResult <-
            lookupResultIO sqlSchemas mkMainParser tokenizer partialParses inputIds
        (decoded, decodedToken) <- decodedTokenFromDifferenceIO tokenizer inputIds token decodedInputIds
        partialParseResult' <- feedParserIO partialParseResult decodedToken
        pure $ PartialParse decoded partialParseResult'
    toFeedResultIO (PartialParse _ r) = pure $ toFeedResult r

batchFeed ::
    TVar Int ->
    TVar (HashMap DbId SqlSchema) ->
    (SqlSchema -> Parser Qpl) ->
    Detokenize ->
    TVar (HashMap InputIds PartialParse) ->
    [InputIds] ->
    [[Token]] ->
    IO [BatchFeedResult]
batchFeed counter sqlSchemas mkMainParser detokenize partialParses inputIds topTokens = do
    mapConcurrently
        ( \(batchId, inputIds', token) ->
            feedIO counter sqlSchemas mkMainParser detokenize partialParses inputIds' token
                <&> BatchFeedResult batchId token
        )
        . concat
        . zipWith3 (\batchId inputIds' tokens -> (batchId,inputIds',) <$> tokens) [0 ..] inputIds
        $ topTokens

parseQpl :: BatchParseRequest -> AppM [BatchFeedResult]
parseQpl req = do
    State{..} <- ask
    maybeDetokenize <- liftIO $ readTVarIO stDetokenize
    detokenize <- lift $ maybe (throwError err400{errBody = "Tokenizer not registered"}) pure maybeDetokenize
    let BatchParseRequest{..} = req
    liftIO $ batchFeed stCounter stSchemas mkQplParser detokenize stPartialParses bprInputIds bprTopTokens

validateQpl :: ValidationRequest -> AppM Bool
validateQpl req = do
    sqlSchemasTVar <- asks stSchemas
    sqlSchemas <- liftIO $ readTVarIO sqlSchemasTVar
    let schemaParser = mkSchemaParser sqlSchemas
        parser = do
            schema <- schemaParser
            spaces *> char '|' <* spaces
            mkQplParser schema <* endOfInput
    pure $ isRight $ Atto.parseOnly parser (vrQpl req)

server :: ServerT ParsingAPI AppM
server = registerTokenizer :<|> registerSchema :<|> parseQpl :<|> validateQpl

parsingAPI :: Proxy ParsingAPI
parsingAPI = Proxy

app :: State -> Application
app s = serve parsingAPI $ hoistServer parsingAPI (nt s) server

main :: IO ()
main = do
    let port = 8081
    initialState <- initState
    liftIO $ putStrLn $ "Running server on port " <> show port
    run port $ app initialState
