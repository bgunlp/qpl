{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# HLINT ignore "Use <$>" #-}
{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# OPTIONS_GHC -Wno-unused-do-bind #-}

module Parse where

import Control.Applicative ((<|>))
import Control.Monad.RWS (MonadReader (ask), MonadState (get, put), RWST, asks, evalRWST, forM_, lift, modify', unless)
import Data.Attoparsec.Text hiding (scan)
import Data.Either (fromRight)
import Data.Function (on)
import Data.Functor (($>))
import Data.HashMap.Strict (HashMap)
import Data.HashMap.Strict qualified as HashMap
import Data.List (sortBy)
import Data.List qualified as List
import Data.Maybe (mapMaybe)
import Data.Set (Set)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Text qualified as T
import GHC.Generics (Generic)
import Text.Parser.Char (spaces)
import Text.Parser.Combinators (Parsing (unexpected), chainl1, optional)

type ColumnId = Text

type TableId = Text

data SqlSchema = SqlSchema
    { peDbId :: Text
    , peTableNames :: HashMap TableId Text
    , peColumnNames :: HashMap ColumnId Text
    , peColumnToTable :: HashMap ColumnId TableId
    , peTableToColumns :: HashMap TableId [ColumnId]
    }
    deriving stock (Show, Generic)

data QplState = QplState
    { qsSeenIdxs :: Set Int
    , qsOutputs :: HashMap Int [Text]
    , qsCurrentIdx :: Int
    }
    deriving stock (Show)

emptyQplState :: QplState
emptyQplState = QplState mempty mempty 1

newtype Table = Table Text deriving newtype (Show)
newtype Column = Column Text deriving newtype (Show)
type InputId = Int

data IndexedColumn = IndexedColumn
    { icTableIdx :: Int
    , icColumnName :: UnaryOperationOutput
    }
    deriving stock (Show)

data Agg = Count | Sum | Min | Max | Avg deriving stock (Show)

data AliasedAggregate = AliasedAggregate
    { aaAgg :: Agg
    , aaDistinct :: Bool
    , aaColumn :: Column
    , aaAlias :: Text
    }
    deriving stock (Show)

data AggregateLineOutput
    = C Column
    | A AliasedAggregate
    | CS
    deriving stock (Show)

data UnaryOperationOutput
    = AliasOutput Text
    | ColumnOutput Column
    deriving stock (Show)

newtype AggregateOutput = AggregateOutput [AggregateLineOutput] deriving newtype (Show)
newtype ExceptOutput = ExceptOutput [Either Text IndexedColumn] deriving newtype (Show)
newtype FilterOutput = FilterOutput [Either Text UnaryOperationOutput] deriving newtype (Show)
newtype IntersectOutput = IntersectOutput [IndexedColumn] deriving newtype (Show)
newtype JoinOutput = JoinOutput [Either Text IndexedColumn] deriving newtype (Show)
newtype ScanOutput = ScanOutput [Either Text Column] deriving newtype (Show)
newtype TopOutput = TopOutput [UnaryOperationOutput] deriving newtype (Show)
newtype SortOutput = SortOutput [UnaryOperationOutput] deriving newtype (Show)
newtype TopSortOutput = TopSortOutput [UnaryOperationOutput] deriving newtype (Show)
newtype UnionOutput = UnionOutput [IndexedColumn] deriving newtype (Show)

data Comparable
    = ConstNum Double
    | ConstString Text
    | ConstNull
    | Col Column
    | Alias Text
    | IC IndexedColumn
    deriving stock (Show)

data Comparison
    = Equal Comparable Comparable
    | NotEqual Comparable Comparable
    | GreaterThan Comparable Comparable
    | GreaterThanOrEqual Comparable Comparable
    | LessThan Comparable Comparable
    | LessThanOrEqual Comparable Comparable
    | Is Comparable Comparable
    | IsNot Comparable Comparable
    | Like Comparable Comparable
    deriving stock (Show)

data Predicate
    = Single Comparison
    | Conjunction Predicate Predicate
    | Disjunction Predicate Predicate
    deriving stock (Show)

newtype GroupBy = GroupBy [Column] deriving newtype (Show)
data Direction = Ascending | Descending deriving stock (Show)
newtype OrderByColumn = OrderByColumn (UnaryOperationOutput, Direction) deriving newtype (Show)

data Operation
    = Aggregate [InputId] (Maybe GroupBy) AggregateOutput
    | Except [InputId] (Either Predicate IndexedColumn) ExceptOutput
    | Filter [InputId] Predicate Bool FilterOutput
    | Intersect [InputId] (Maybe Predicate) IntersectOutput
    | Join [InputId] (Maybe Predicate) Bool JoinOutput
    | Scan Table (Maybe Predicate) Bool ScanOutput
    | Top [InputId] Int TopOutput
    | Sort [InputId] [OrderByColumn] Bool SortOutput
    | TopSort [InputId] Int [OrderByColumn] TopSortOutput
    | Union [InputId] UnionOutput
    deriving stock (Show)

data Line = Line
    { lineIdx :: Int
    , lineOp :: Operation
    }
    deriving stock (Show)

type P a = RWST SqlSchema () QplState Parser a

type Qpl = [Line]
type QplParser = P Qpl

aggToPrefix :: Agg -> Text
aggToPrefix Count = "Count_"
aggToPrefix Sum = "Sum_"
aggToPrefix Min = "Min_"
aggToPrefix Max = "Max_"
aggToPrefix Avg = "Avg_"

unaryOperationOutputToText :: UnaryOperationOutput -> Text
unaryOperationOutputToText (AliasOutput a) = a
unaryOperationOutputToText (ColumnOutput (Column col)) = col

aggregateOutputToText :: AggregateOutput -> [Text]
aggregateOutputToText (AggregateOutput outputs) =
    fmap
        ( \case
            C (Column col) -> col
            A (AliasedAggregate{..}) -> aaAlias
            CS -> "Count_Star"
        )
        outputs

exceptOutputToText :: ExceptOutput -> [Text]
exceptOutputToText (ExceptOutput outputs) =
    fmap
        ( \case
            Left col -> col
            Right (IndexedColumn{..}) -> unaryOperationOutputToText icColumnName
        )
        outputs

filterOutputToText :: FilterOutput -> [Text]
filterOutputToText (FilterOutput outputs) =
    fmap
        ( \case
            Left col -> col
            Right uoo -> unaryOperationOutputToText uoo
        )
        outputs

intersectOutputToText :: IntersectOutput -> [Text]
intersectOutputToText (IntersectOutput outputs) =
    fmap (\IndexedColumn{..} -> unaryOperationOutputToText icColumnName) outputs

joinOutputToText :: JoinOutput -> [Text]
joinOutputToText (JoinOutput outputs) =
    fmap
        ( \case
            Left col -> col
            Right (IndexedColumn{..}) -> unaryOperationOutputToText icColumnName
        )
        outputs

topOutputToText :: TopOutput -> [Text]
topOutputToText (TopOutput outputs) = fmap unaryOperationOutputToText outputs

sortOutputToText :: SortOutput -> [Text]
sortOutputToText (SortOutput outputs) = fmap unaryOperationOutputToText outputs

topSortOutputToText :: TopSortOutput -> [Text]
topSortOutputToText (TopSortOutput outputs) = fmap unaryOperationOutputToText outputs

unionOutputToText :: UnionOutput -> [Text]
unionOutputToText (UnionOutput outputs) =
    fmap (\IndexedColumn{..} -> unaryOperationOutputToText icColumnName) outputs

opToConstructor :: Text -> (Comparable -> Comparable -> Comparison)
opToConstructor "=" = Equal
opToConstructor "<>" = NotEqual
opToConstructor ">" = GreaterThan
opToConstructor ">=" = GreaterThanOrEqual
opToConstructor "<" = LessThan
opToConstructor "<=" = LessThanOrEqual
opToConstructor "IS" = Is
opToConstructor "IS NOT" = IsNot
opToConstructor "LIKE" = Like
opToConstructor _ = error "No such comparison operator"

comparisonOp :: P Text
comparisonOp =
    lift $
        string "<>"
            <|> string "<="
            <|> string ">="
            <|> string "IS NOT"
            <|> string "IS"
            <|> (asciiCI "like" $> "LIKE")
            <|> string "<"
            <|> string ">"
            <|> string "="

tableName :: P Text
tableName = do
    tableNames <- asks (HashMap.elems . peTableNames)
    let p tn = lift $ asciiCI tn $> tn
    choice $ fmap p (sortBy (compare `on` (negate . T.length)) tableNames)

colName :: P Text
colName = do
    columnNames <- asks (HashMap.elems . peColumnNames)
    let p cn = lift $ asciiCI cn $> cn
    choice $ fmap p (sortBy (compare `on` (negate . T.length)) columnNames)

columnInTable :: Text -> P Text
columnInTable table = do
    SqlSchema{..} <- ask
    column <- colName
    let matchingColumnIds cn = HashMap.keys . HashMap.filter (\x -> T.toLower cn == T.toLower x) $ peColumnNames
        columnIdToTableNames = peTableNames `HashMap.compose` peColumnToTable
        matchingTableNames cn = mapMaybe (`HashMap.lookup` columnIdToTableNames) $ matchingColumnIds cn
        isColumnInTable cn = table `elem` matchingTableNames cn
    unless (isColumnInTable column) $ unexpected ("Column " <> T.unpack column <> " is not part of table " <> T.unpack table)
    pure column

inputIds :: P [Int]
inputIds = do
    state <- get
    lift $ string "[ "
    ids <- fmap Set.fromList (lift (char '#' *> decimal :: Parser Int) `sepBy1` lift (skipSpace *> string ", "))
    lift $ string " ] "
    put (state{qsSeenIdxs = Set.difference (qsSeenIdxs state) ids})
    forM_ ids $ \i -> unless (i `Set.member` qsSeenIdxs state) $ unexpected ("Instruction ID " <> show i <> " was not seen before.")
    pure (List.sort $ Set.toList ids)

predicate :: P Predicate -> P Predicate
predicate inner = do
    lift $ string "Predicate [ "
    p <- inner
    lift $ string " ] "
    pure p

constNum :: P Comparable
constNum = fmap ConstNum (lift double)

constStr :: P Comparable
constStr = do
    lift $ char '\''
    s <- lift $ takeTill (== '\'')
    lift $ char '\''
    pure $ ConstString s

constNull :: P Comparable
constNull = lift $ asciiCI "null" $> ConstNull

alias :: P Text
alias = do
    QplState{..} <- get
    let p cn = lift $ asciiCI cn $> cn
    value <- choice $ fmap p (sortBy (compare `on` (negate . T.length)) (concat $ HashMap.elems qsOutputs))
    let isValidAggAlias = or $ fmap (`T.isPrefixOf` value) ["Max_", "Min_", "Sum_", "Count_", "Avg_"]
    unless isValidAggAlias $ unexpected ("Alias " <> T.unpack value <> " is not an aggregate alias")
    pure value

indexedColumn :: P IndexedColumn
indexedColumn = do
    lift $ char '#'
    idx <- lift (decimal :: Parser Int)
    lift $ char '.'
    col <- fmap (ColumnOutput . Column) (columnInIndex idx colName) <|> fmap AliasOutput (columnInIndex idx alias)
    pure $ IndexedColumn idx col

columnInIndex :: Int -> P Text -> P Text
columnInIndex idx p = do
    QplState{..} <- get
    column <- p
    let outputs = HashMap.lookupDefault [] idx qsOutputs
    unless (column `elem` outputs) $ unexpected ("Column " <> T.unpack column <> " was not defined in index " <> show idx)
    pure column

scan :: P Operation
scan = do
    lift $ string "Scan Table [ "
    table <- tableName
    lift $ string " ] "
    maybePredicate <- optional (predicate $ inner' table)
    isDistinct <- lift $ option False (string "Distinct [ true ] " $> True)
    lift $ string "Output [ "
    columns <- (lift (string "1 AS One") `eitherP` columnInTable table) `sepBy1` lift (skipSpace *> string ", ")
    let outputs = fromRight [] $ sequence columns
        outputsText = fmap (\case Left x -> x; Right col -> col) columns
        outputsSet = Set.fromList outputsText
        noDups = Set.size outputsSet == length outputsText
    unless noDups $ unexpected "Duplicate outputs in Scan"
    modify' (\s -> s{qsOutputs = HashMap.insert (qsCurrentIdx s) outputs (qsOutputs s)})
    lift $ string " ]"
    pure $ Scan (Table table) maybePredicate isDistinct (ScanOutput $ fmap (fmap Column) columns)
  where
    comparable' :: Text -> P Comparable
    comparable' table = constNum <|> constStr <|> constNull <|> fmap (Col . Column) (columnInTable table)

    comparison' :: Text -> P Comparison
    comparison' table = do
        lhs <- fmap (Col . Column) (columnInTable table)
        spaces
        op <- comparisonOp
        spaces
        rhs <- comparable' table
        pure $ opToConstructor op lhs rhs

    inner' :: Text -> P Predicate
    inner' table =
        fmap Single (comparison' table)
            `chainl1` lift (skipSpace *> (Conjunction <$ string "AND" <|> Disjunction <$ string "OR") <* skipSpace)

aggregate :: P Operation
aggregate = do
    QplState{..} <- get
    lift $ string "Aggregate "
    inputs <- inputIds
    unless (length inputs == 1) $ unexpected "Wrong number of inputs for Aggregate"
    let input = head inputs
    gbs <- optional $ groupBy input
    ol <- outputList input
    let prevOutputs = Set.fromList $ HashMap.lookupDefault [] input qsOutputs
        outputsText = aggregateOutputToText ol
        p t = and $ fmap (not . (`T.isPrefixOf` t)) ["Max_", "Min_", "Sum_", "Count_", "Avg_"]
        outputsSet = Set.filter p $ Set.fromList outputsText
        noDups = Set.size outputsSet == length (Prelude.filter p outputsText)
    unless (noDups && outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Aggregate inputs gbs ol
  where
    groupBy :: Int -> P GroupBy
    groupBy input = do
        lift $ string "GroupBy [ "
        columns <- columnInIndex input colName `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ] "
        pure $ GroupBy $ fmap Column columns

    outputList :: Int -> P AggregateOutput
    outputList input = do
        lift $ string "Output [ "
        outputs <- fmap AggregateOutput $ aggLineOutput input `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

    aggLineOutput :: Int -> P AggregateLineOutput
    aggLineOutput input =
        lift (string "countstar AS Count_Star" $> CS)
            <|> fmap A (aliasedAggregate input)
            <|> fmap (C . Column) colName

    aliasedAggregate :: Int -> P AliasedAggregate
    aliasedAggregate input = do
        agg <-
            lift $
                string "AVG" $> Avg
                    <|> string "COUNT" $> Count
                    <|> string "SUM" $> Sum
                    <|> string "MIN" $> Min
                    <|> string "MAX" $> Max
        lift $ char '('
        isDistinct <- lift $ option False (string "DISTINCT " $> True)
        col <- columnInIndex input colName
        lift $ string ") AS "
        prefix <- lift $ string (aggToPrefix agg)
        dist <- if isDistinct then lift $ string "Dist_" else pure ""
        alias' <- lift $ string col
        let prefixedAlias = prefix <> dist <> alias'
        pure $ AliasedAggregate agg isDistinct (Column col) prefixedAlias

filter :: P Operation
filter = do
    QplState{..} <- get
    lift $ string "Filter "
    inputs <- inputIds
    unless (length inputs == 1) $ unexpected "Wrong number of inputs for Filter"
    pred' <- predicate (inner (head inputs))
    isDistinct <- lift $ option False (string "Distinct [ true ] " $> True)
    ol <- outputList
    let prevOutputs = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        outputsText = filterOutputToText ol
        outputsSet = Set.fromList outputsText
        isOneAsOne = outputsText == ["1 AS One"]
        noDups = Set.size outputsSet == length outputsText
    unless (noDups && (outputsSet `Set.isSubsetOf` prevOutputs || isOneAsOne)) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Filter inputs pred' isDistinct ol
  where
    comparable :: Int -> P Comparable
    comparable input =
        constNum
            <|> constStr
            <|> constNull
            <|> fmap (Col . Column) (columnInIndex input colName)
            <|> fmap Alias (columnInIndex input alias)

    comparison :: Int -> P Comparison
    comparison input = do
        lhs <- fmap (Col . Column) (columnInIndex input colName) <|> fmap Alias (columnInIndex input alias)
        spaces
        op <- comparisonOp
        spaces
        rhs <- comparable input
        pure $ opToConstructor op lhs rhs

    inner :: Int -> P Predicate
    inner input =
        fmap Single (comparison input)
            `chainl1` lift (skipSpace *> (Conjunction <$ string "AND" <|> Disjunction <$ string "OR") <* skipSpace)

    outputList :: P FilterOutput
    outputList = do
        lift $ string "Output [ "
        outputs <-
            fmap FilterOutput $
                (lift (string "1 AS One") `eitherP` (fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias))
                    `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

top :: P Operation
top = do
    QplState{..} <- get
    lift $ string "Top "
    inputs <- inputIds
    unless (length inputs == 1) $ unexpected "Wrong number of inputs for Top"
    lift $ string "Rows [ "
    rows <- lift (decimal :: Parser Int)
    lift $ string " ] "
    ol <- outputList
    let prevOutputs = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        outputsText = topOutputToText ol
        outputsSet = Set.fromList outputsText
    unless (outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Top inputs rows ol
  where
    outputList :: P TopOutput
    outputList = do
        lift $ string "Output [ "
        outputs <-
            fmap TopOutput $
                (fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias) `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

sort :: P Operation
sort = do
    QplState{..} <- get
    lift $ string "Sort "
    inputs <- inputIds
    unless (length inputs == 1) $ unexpected "Wrong number of inputs for TopSort"
    lift $ string "OrderBy [ "
    obs <- orderBy (head inputs) `sepBy1` lift (skipSpace *> string ", ")
    lift $ string " ] "
    isDistinct <- lift $ option False (string "Distinct [ true ] " $> True)
    ol <- outputList
    let prevOutputs = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        outputsText = sortOutputToText ol
        outputsSet = Set.fromList outputsText
        noDups = Set.size outputsSet == length outputsText
    unless (noDups && outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Sort inputs obs isDistinct ol
  where
    orderBy :: Int -> P OrderByColumn
    orderBy input = do
        QplState{..} <- get
        by <- fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias
        let prevOutputs = Set.fromList $ HashMap.lookupDefault [] input qsOutputs
            outputsSet = Set.fromList [unaryOperationOutputToText by]
        unless (outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to order by a column that has not been output by the input"
        spaces
        dir <- lift (Ascending <$ string "ASC" <|> Descending <$ string "DESC")
        pure $ OrderByColumn (by, dir)

    outputList :: P SortOutput
    outputList = do
        lift $ string "Output [ "
        outputs <-
            fmap SortOutput $
                (fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias) `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

topSort :: P Operation
topSort = do
    QplState{..} <- get
    lift $ string "TopSort "
    inputs <- inputIds
    unless (length inputs == 1) $ unexpected "Wrong number of inputs for TopSort"
    lift $ string "Rows [ "
    rows <- lift (decimal :: Parser Int)
    lift $ string " ] OrderBy [ "
    obs <- orderBy (head inputs) `sepBy1` lift (skipSpace *> string ", ")
    lift $ string " ] "
    ol <- outputList
    let prevOutputs = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        outputsText = topSortOutputToText ol
        outputsSet = Set.fromList outputsText
        noDups = Set.size outputsSet == length outputsText
    unless (noDups && outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ TopSort inputs rows obs ol
  where
    orderBy :: Int -> P OrderByColumn
    orderBy input = do
        QplState{..} <- get
        by <- fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias
        let prevOutputs = Set.fromList $ HashMap.lookupDefault [] input qsOutputs
            outputsSet = Set.fromList [unaryOperationOutputToText by]
        unless (outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to order by a column that has not been output by the input"
        spaces
        dir <- lift (Ascending <$ string "ASC" <|> Descending <$ string "DESC")
        pure $ OrderByColumn (by, dir)

    outputList :: P TopSortOutput
    outputList = do
        lift $ string "Output [ "
        outputs <-
            fmap TopSortOutput $
                (fmap (ColumnOutput . Column) colName <|> fmap AliasOutput alias) `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

join :: P Operation
join = do
    QplState{..} <- get
    lift $ string "Join "
    inputs <- inputIds
    unless (length inputs == 2) $ unexpected "Wrong number of inputs for Join"
    pred' <- optional (predicate inner)
    isDistinct <- lift $ option False (string "Distinct [ true ] " $> True)
    ol <- outputList
    let prevOutputs1 = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        prevOutputs2 = Set.fromList $ HashMap.lookupDefault [] (head $ tail inputs) qsOutputs
        prevOutputs = Set.union prevOutputs1 prevOutputs2
        outputsText = joinOutputToText ol
        isOneAsOne = outputsText == ["1 AS One"]
        outputsSet = Set.fromList outputsText
        noDups = Set.size outputsSet == length outputsText
    unless (noDups && (outputsSet `Set.isSubsetOf` prevOutputs || isOneAsOne)) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Join inputs pred' isDistinct ol
  where
    comparable' :: P Comparable
    comparable' = fmap IC indexedColumn

    comparison' :: P Comparison
    comparison' = do
        lhs <- fmap IC indexedColumn
        spaces
        op <- comparisonOp
        spaces
        rhs <- comparable'
        pure $ opToConstructor op lhs rhs

    inner :: P Predicate
    inner =
        fmap Single comparison'
            `chainl1` lift (skipSpace *> (Conjunction <$ string "AND" <|> Disjunction <$ string "OR") <* skipSpace)

    outputList :: P JoinOutput
    outputList = do
        lift $ string "Output [ "
        outputs <- fmap JoinOutput $ (lift (string "1 AS One") `eitherP` indexedColumn) `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

intersect :: P Operation
intersect = do
    QplState{..} <- get
    lift $ string "Intersect "
    inputs <- inputIds
    unless (length inputs == 2) $ unexpected "Wrong number of inputs for Intersect"
    pred' <- optional (predicate inner)
    ol <- outputList
    let prevOutputs1 = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        prevOutputs2 = Set.fromList $ HashMap.lookupDefault [] (head $ tail inputs) qsOutputs
        prevOutputs = Set.union prevOutputs1 prevOutputs2
        outputsText = intersectOutputToText ol
        outputsSet = Set.fromList outputsText
    unless (outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Intersect inputs pred' ol
  where
    comparable' :: P Comparable
    comparable' = fmap IC indexedColumn

    comparison' :: P Comparison
    comparison' = do
        lhs <- fmap IC indexedColumn
        spaces
        op <- comparisonOp
        spaces
        rhs <- comparable'
        pure $ opToConstructor op lhs rhs

    inner :: P Predicate
    inner = fmap Single comparison'

    outputList :: P IntersectOutput
    outputList = do
        lift $ string "Output [ "
        outputs <- fmap IntersectOutput $ indexedColumn `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

except :: P Operation
except = do
    QplState{..} <- get
    lift $ string "Except "
    inputs <- inputIds
    unless (length inputs == 2) $ unexpected "Wrong number of inputs for Except"
    arg <- eitherP (predicate inner) exceptCol
    ol <- outputList
    let prevOutputs1 = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        prevOutputs2 = Set.fromList $ HashMap.lookupDefault [] (head $ tail inputs) qsOutputs
        prevOutputs = Set.union prevOutputs1 prevOutputs2
        outputsText = exceptOutputToText ol
        isOneAsOne = outputsText == ["1 AS One"]
        outputsSet = Set.fromList outputsText
    unless (outputsSet `Set.isSubsetOf` prevOutputs || isOneAsOne) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Except inputs arg ol
  where
    comparable' :: P Comparable
    comparable' = fmap IC indexedColumn <|> constNull

    comparison' :: P Comparison
    comparison' = do
        lhs <- fmap IC indexedColumn
        spaces
        op <- comparisonOp
        spaces
        rhs <- comparable'
        pure $ opToConstructor op lhs rhs

    inner :: P Predicate
    inner =
        fmap Single comparison'
            `chainl1` lift (skipSpace *> (Conjunction <$ string "AND" <|> Disjunction <$ string "OR") <* skipSpace)

    exceptCol :: P IndexedColumn
    exceptCol = do
        lift $ string "ExceptColumns [ "
        col <- indexedColumn
        lift $ string " ] "
        pure col

    outputList :: P ExceptOutput
    outputList = do
        lift $ string "Output [ "
        outputs <- fmap ExceptOutput $ (lift (string "1 AS One") `eitherP` indexedColumn) `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

union :: P Operation
union = do
    QplState{..} <- get
    lift $ string "Union "
    inputs <- inputIds
    unless (length inputs == 2) $ unexpected "Wrong number of inputs for Union"
    ol <- outputList
    let prevOutputs1 = Set.fromList $ HashMap.lookupDefault [] (head inputs) qsOutputs
        prevOutputs2 = Set.fromList $ HashMap.lookupDefault [] (head $ tail inputs) qsOutputs
        prevOutputs = Set.union prevOutputs1 prevOutputs2
        outputsText = unionOutputToText ol
        outputsSet = Set.fromList outputsText
    unless (outputsSet `Set.isSubsetOf` prevOutputs) $ unexpected "Trying to output a column that has not been output by the input"
    modify' (\s -> s{qsOutputs = HashMap.insert qsCurrentIdx outputsText qsOutputs})
    pure $ Union inputs ol
  where
    outputList :: P UnionOutput
    outputList = do
        lift $ string "Output [ "
        outputs <- fmap UnionOutput $ indexedColumn `sepBy1` lift (skipSpace *> string ", ")
        lift $ string " ]"
        pure outputs

qpl :: QplParser
qpl = line `sepBy1` lift (string " ; ")
  where
    line :: P Line
    line = do
        lineIdx <- lift (char '#' *> decimal)
        lift $ string " = "
        operation <-
            scan
                <|> join
                <|> intersect
                <|> aggregate
                <|> Parse.filter
                <|> except
                <|> union
                <|> sort
                <|> topSort
                <|> top
        modify' (\s -> s{qsSeenIdxs = Set.insert lineIdx (qsSeenIdxs s), qsCurrentIdx = qsCurrentIdx s + 1})
        pure $ Line lineIdx operation

parseQpl :: SqlSchema -> Text -> Result Qpl
parseQpl schema = parse (fst <$> evalRWST qpl schema emptyQplState)

mkQplParser :: SqlSchema -> Parser Qpl
mkQplParser schema = fst <$> evalRWST qpl schema emptyQplState

checkParser :: P a -> Text -> Result a
checkParser p = parse (fst <$> evalRWST p testEnv emptyQplState)

testEnv :: SqlSchema
testEnv =
    SqlSchema
        { peDbId = "car_1"
        , peTableNames = HashMap.fromList [("0", "continents"), ("1", "countries"), ("2", "car_makers"), ("3", "model_list"), ("4", "car_names"), ("5", "cars_data")]
        , peColumnNames = HashMap.fromList [("1", "ContId"), ("2", "Continent"), ("3", "CountryId"), ("4", "CountryName"), ("5", "Continent"), ("6", "Id"), ("7", "Maker"), ("8", "FullName"), ("9", "Country"), ("10", "ModelId"), ("11", "Maker"), ("12", "Model"), ("13", "MakeId"), ("14", "Model"), ("15", "Make"), ("16", "Id"), ("17", "MPG"), ("18", "Cylinders"), ("19", "Edispl"), ("20", "Horsepower"), ("21", "Weight"), ("22", "Accelerate"), ("23", "Year")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "1"), ("6", "2"), ("7", "2"), ("8", "2"), ("9", "2"), ("10", "3"), ("11", "3"), ("12", "3"), ("13", "4"), ("14", "4"), ("15", "4"), ("16", "5"), ("17", "5"), ("18", "5"), ("19", "5"), ("20", "5"), ("21", "5"), ("22", "5"), ("23", "5")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4", "5"]), ("2", ["6", "7", "8", "9"]), ("3", ["10", "11", "12"]), ("4", ["13", "14", "15"]), ("5", ["16", "17", "18", "19", "20", "21", "22", "23"])]
        }