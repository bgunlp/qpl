import atto.*, Atto.*
import com.beneyal.parse.QplParser
import atto.ParseResult.Fail
import atto.ParseResult.Partial
import atto.ParseResult.Done

class ParserSpec extends munit.FunSuite {
  test("some parser tests") {
    val positives = Vector(
      "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Capacity , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year >= 2014 ] Output [ Stadium_ID , Year ] ; #3 = Aggregate [ #2 ] GroupBy [ Stadium_ID ] Output [ Stadium_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name , #3.Count_Star , #1.Capacity ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Capacity , Count_Star , Name ]",
      "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Stadium_ID IS NULL OR #1.Stadium_ID = #2.Stadium_ID ] Output [ #1.Name ]",
      "#1 = Scan Table [ singer ] Predicate [ Country = 'france' ] Output [ Age , Country ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age , MAX(Age) AS Max_Age , MIN(Age) AS Min_Age ]",
      "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ singer_in_concert ] Output [ Singer_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Singer_ID ] Output [ Singer_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #3.Count_Star ]",
      "#1 = Scan Table [ stadium ] Distinct [ true ] Output [ Name ] ; #2 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #3 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Stadium_ID , Year ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Stadium_ID = #2.Stadium_ID ] Distinct [ true ] Output [ #2.Name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Name = #4.Name ] Output [ #1.Name ]",
      "#1 = Scan Table [ stadium ] Predicate [ Capacity >= 5000 AND Capacity <= 10000 ] Output [ Location , Capacity , Name ]",
      "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #2.Stadium_ID , #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Stadium_ID ] Output [ countstar AS Count_Star , Name ]",
      "#1 = Scan Table [ stadium ] Output [ Average , Capacity ] ; #2 = Aggregate [ #1 ] GroupBy [ Average ] Output [ Average , MAX(Capacity) AS Max_Capacity ]"
    )

    val negatives = Vector(
      "#1 = Scan Table [ stadium ] Output [ Name, Capacity, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year >= 2014 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #1.Capacity ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star, Capacity ]",
      "#1 = Scan Table [ stadium ] Output [ Location, Capacity, Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Capacity ] Output [ Capacity, countstar AS Count_Star, Location ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 10000.0 ] Output [ Location, Count_Star, Name ]",
      "#1 = Scan Table [ concert ] Output [ Concert_Name, Theme ] ; #2 = Scan Table [ singer_in_concert ] Output [ Concert_ID, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #1.Concert_Name, #1.Theme ] ; #4 = Aggregate [ #3 ] GroupBy [ Concert_Name ] Output [ Concert_Name, countstar AS Count_Star ]",
      "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Age DESC ] Output [ Age, Song_Name ]",
      "#1 = Scan Table [ concert ] Output [ Concert_Name, Theme, Concert_ID ] ; #2 = Scan Table [ singer_in_concert ] Output [ Concert_ID, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #1.Concert_Name, #2.Theme, #1.Concert_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Concert_Name ] Output [ Concert_Name, countstar AS Count_Star, Concert_Name ]",
      "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year, Concert_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #2.Name ]",
      "#1 = Scan Table [ singer ] Output [ Song_Name, Age ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age DESC ] Output [ Song_Name, Age, Song_Release_Year ]",
      "#1 = Scan Table [ stadium ] Output [ Name, Location, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 OR Year = 2015 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #2.Location ]",
      "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = Filter [ #2 ] Predicate [ Avg_Age >= 1 ] Output [ Song_Name ]",
      "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year, Concert_ID ] ; #3 = Scan Table [ singer_in_concert ] Output [ Singer_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Singer_ID = #2.Singer_ID ] Output [ #3.Name ]",
      "#1 = Scan Table [ stadium ] Output [ Location, Name, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 AND Year = 2015 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #2.Name, #1.Location ]",
      "#1 = Scan Table [ stadium ] Output [ Name, Capacity, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year > 2013 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #1.Capacity ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star, Capacity ]",
      "#1 = Scan Table [ stadium ] Output [ Capacity, Location, Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Capacity ] Output [ Capacity, countstar AS Count_Star, Location ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 10000.0 ] Output [ Location, Name, Count_Star, Location, Name, Count_Star, Location, Count_Star, Location, Name, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Count_Star, Location, Count_Star",
      "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Age DESC ] Output [ Song_Name, Avg_Age, Affect_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_"
    )

    positives.foreach { example =>
      QplParser.make(concertSinger).parseOnly(example) match {
        case Done(input, _)      => assertEquals(input, "")
        case Partial(_)          => fail("partial result")
        case Fail(_, _, message) => fail(message)
      }
    }

    negatives.foreach { example =>
      QplParser.make(concertSinger).parseOnly(example) match {
        case Done(input, _) => assertNotEquals(input, "")
        case _              => assert(true)
      }
    }
  }
}
