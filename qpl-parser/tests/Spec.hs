{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Data.Attoparsec.Text
import Data.HashMap.Strict qualified as HashMap
import Data.Text
import Parse
import Test.Tasty
import Test.Tasty.HUnit

main = defaultMain tests

tests :: TestTree
tests = testGroup "Parser tests" [unitTests]

unitTests =
    testGroup
        "Unit tests"
        [ testCase "QPLs parse without leftovers" $
            forM_ testPlans $ \(pe, p) -> case feed (parseQpl pe p) mempty of
                Done leftovers _ -> leftovers @?= ""
                Partial _ -> assertFailure "partial parse"
                Fail{} -> assertFailure "failed parse"
        , testCase "QPLs with wrong indexing don't parse" $
            forM_ negativeTestPlans $ \(pe, p) -> case feed (parseQpl pe p) mempty of
                Done "" _ -> assertFailure ("parse completed with invalid indices: " <> unpack p)
                _ -> pure ()
        , testCase "QPLs with invalid schema items don't parse" $
            forM_ testPlans $ \(_, p) -> case parseQpl dummy p of
                Done leftovers _ -> assertFailure "parse completed with invalid schema items"
                _ -> pure ()
        ]

dummy :: SqlSchema
dummy =
    SqlSchema
        { peDbId = "dummy"
        , peTableNames = HashMap.fromList [("0", "table")]
        , peColumnNames = HashMap.fromList [("1", "column")]
        , peColumnToTable = HashMap.fromList [("1", "0")]
        , peTableToColumns = HashMap.fromList [("0", ["1"])]
        }

car1 :: SqlSchema
car1 =
    SqlSchema
        { peDbId = "car_1"
        , peTableNames = HashMap.fromList [("0", "continents"), ("1", "countries"), ("2", "car_makers"), ("3", "model_list"), ("4", "car_names"), ("5", "cars_data")]
        , peColumnNames = HashMap.fromList [("1", "ContId"), ("2", "Continent"), ("3", "CountryId"), ("4", "CountryName"), ("5", "Continent"), ("6", "Id"), ("7", "Maker"), ("8", "FullName"), ("9", "Country"), ("10", "ModelId"), ("11", "Maker"), ("12", "Model"), ("13", "MakeId"), ("14", "Model"), ("15", "Make"), ("16", "Id"), ("17", "MPG"), ("18", "Cylinders"), ("19", "Edispl"), ("20", "Horsepower"), ("21", "Weight"), ("22", "Accelerate"), ("23", "Year")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "1"), ("6", "2"), ("7", "2"), ("8", "2"), ("9", "2"), ("10", "3"), ("11", "3"), ("12", "3"), ("13", "4"), ("14", "4"), ("15", "4"), ("16", "5"), ("17", "5"), ("18", "5"), ("19", "5"), ("20", "5"), ("21", "5"), ("22", "5"), ("23", "5")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4", "5"]), ("2", ["6", "7", "8", "9"]), ("3", ["10", "11", "12"]), ("4", ["13", "14", "15"]), ("5", ["16", "17", "18", "19", "20", "21", "22", "23"])]
        }

dogKennels :: SqlSchema
dogKennels =
    SqlSchema
        { peDbId = "dog_kennels"
        , peTableNames = HashMap.fromList [("0", "Breeds"), ("1", "Charges"), ("2", "Sizes"), ("3", "Treatment_Types"), ("4", "Owners"), ("5", "Dogs"), ("6", "Professionals"), ("7", "Treatments")]
        , peColumnNames = HashMap.fromList [("1", "breed_code"), ("2", "breed_name"), ("3", "charge_id"), ("4", "charge_type"), ("5", "charge_amount"), ("6", "size_code"), ("7", "size_description"), ("8", "treatment_type_code"), ("9", "treatment_type_description"), ("10", "owner_id"), ("11", "first_name"), ("12", "last_name"), ("13", "street"), ("14", "city"), ("15", "state"), ("16", "zip_code"), ("17", "email_address"), ("18", "home_phone"), ("19", "cell_number"), ("20", "dog_id"), ("21", "owner_id"), ("22", "abandoned_yn"), ("23", "breed_code"), ("24", "size_code"), ("25", "name"), ("26", "age"), ("27", "date_of_birth"), ("28", "gender"), ("29", "weight"), ("30", "date_arrived"), ("31", "date_adopted"), ("32", "date_departed"), ("33", "professional_id"), ("34", "role_code"), ("35", "first_name"), ("36", "street"), ("37", "city"), ("38", "state"), ("39", "zip_code"), ("40", "last_name"), ("41", "email_address"), ("42", "home_phone"), ("43", "cell_number"), ("44", "treatment_id"), ("45", "dog_id"), ("46", "professional_id"), ("47", "treatment_type_code"), ("48", "date_of_treatment"), ("49", "cost_of_treatment")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "1"), ("6", "2"), ("7", "2"), ("8", "3"), ("9", "3"), ("10", "4"), ("11", "4"), ("12", "4"), ("13", "4"), ("14", "4"), ("15", "4"), ("16", "4"), ("17", "4"), ("18", "4"), ("19", "4"), ("20", "5"), ("21", "5"), ("22", "5"), ("23", "5"), ("24", "5"), ("25", "5"), ("26", "5"), ("27", "5"), ("28", "5"), ("29", "5"), ("30", "5"), ("31", "5"), ("32", "5"), ("33", "6"), ("34", "6"), ("35", "6"), ("36", "6"), ("37", "6"), ("38", "6"), ("39", "6"), ("40", "6"), ("41", "6"), ("42", "6"), ("43", "6"), ("44", "7"), ("45", "7"), ("46", "7"), ("47", "7"), ("48", "7"), ("49", "7")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4", "5"]), ("2", ["6", "7"]), ("3", ["8", "9"]), ("4", ["10", "11", "12", "13", "14", "15", "16", "17", "18", "19"]), ("5", ["20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32"]), ("6", ["33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43"]), ("7", ["44", "45", "46", "47", "48", "49"])]
        }

courseTeach :: SqlSchema
courseTeach =
    SqlSchema
        { peDbId = "course_teach"
        , peTableNames = HashMap.fromList [("0", "course"), ("1", "teacher"), ("2", "course_arrange")]
        , peColumnNames = HashMap.fromList [("1", "Course_ID"), ("2", "Staring_Date"), ("3", "Course"), ("4", "Teacher_ID"), ("5", "Name"), ("6", "Age"), ("7", "Hometown"), ("8", "Course_ID"), ("9", "Teacher_ID"), ("10", "Grade")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "1"), ("5", "1"), ("6", "1"), ("7", "1"), ("8", "2"), ("9", "2"), ("10", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3"]), ("1", ["4", "5", "6", "7"]), ("2", ["8", "9", "10"])]
        }

creDocTemplateMgt :: SqlSchema
creDocTemplateMgt =
    SqlSchema
        { peDbId = "cre_Doc_Template_Mgt"
        , peTableNames = HashMap.fromList [("0", "Ref_Template_Types"), ("1", "Templates"), ("2", "Documents"), ("3", "Paragraphs")]
        , peColumnNames = HashMap.fromList [("1", "Template_Type_Code"), ("2", "Template_Type_Description"), ("3", "Template_ID"), ("4", "Version_Number"), ("5", "Template_Type_Code"), ("6", "Date_Effective_From"), ("7", "Date_Effective_To"), ("8", "Template_Details"), ("9", "Document_ID"), ("10", "Template_ID"), ("11", "Document_Name"), ("12", "Document_Description"), ("13", "Other_Details"), ("14", "Paragraph_ID"), ("15", "Document_ID"), ("16", "Paragraph_Text"), ("17", "Other_Details")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "1"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "2"), ("10", "2"), ("11", "2"), ("12", "2"), ("13", "2"), ("14", "3"), ("15", "3"), ("16", "3"), ("17", "3")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4", "5", "6", "7", "8"]), ("2", ["9", "10", "11", "12", "13"]), ("3", ["14", "15", "16", "17"])]
        }

singer :: SqlSchema
singer =
    SqlSchema
        { peDbId = "singer"
        , peTableNames = HashMap.fromList [("0", "singer"), ("1", "song")]
        , peColumnNames = HashMap.fromList [("1", "Singer_ID"), ("2", "Name"), ("3", "Birth_Year"), ("4", "Net_Worth_Millions"), ("5", "Citizenship"), ("6", "Song_ID"), ("7", "Title"), ("8", "Singer_ID"), ("9", "Sales"), ("10", "Highest_Position")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5"]), ("1", ["6", "7", "8", "9", "10"])]
        }

voter1 :: SqlSchema
voter1 =
    SqlSchema
        { peDbId = "voter_1"
        , peTableNames = HashMap.fromList [("0", "AREA_CODE_STATE"), ("1", "CONTESTANTS"), ("2", "VOTES")]
        , peColumnNames = HashMap.fromList [("1", "area_code"), ("2", "state"), ("3", "contestant_number"), ("4", "contestant_name"), ("5", "vote_id"), ("6", "phone_number"), ("7", "state"), ("8", "contestant_number"), ("9", "created")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "2"), ("6", "2"), ("7", "2"), ("8", "2"), ("9", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4"]), ("2", ["5", "6", "7", "8", "9"])]
        }

pets1 :: SqlSchema
pets1 =
    SqlSchema
        { peDbId = "pets_1"
        , peTableNames = HashMap.fromList [("0", "Student"), ("1", "Has_Pet"), ("2", "Pets")]
        , peColumnNames = HashMap.fromList [("1", "StuID"), ("2", "LName"), ("3", "Fname"), ("4", "Age"), ("5", "Sex"), ("6", "Major"), ("7", "Advisor"), ("8", "city_code"), ("9", "StuID"), ("10", "PetID"), ("11", "PetID"), ("12", "PetType"), ("13", "pet_age"), ("14", "weight")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "0"), ("8", "0"), ("9", "1"), ("10", "1"), ("11", "2"), ("12", "2"), ("13", "2"), ("14", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6", "7", "8"]), ("1", ["9", "10"]), ("2", ["11", "12", "13", "14"])]
        }

pokerPlayer :: SqlSchema
pokerPlayer =
    SqlSchema
        { peDbId = "poker_player"
        , peTableNames = HashMap.fromList [("0", "poker_player"), ("1", "people")]
        , peColumnNames = HashMap.fromList [("1", "Poker_Player_ID"), ("2", "People_ID"), ("3", "Final_Table_Made"), ("4", "Best_Finish"), ("5", "Money_Rank"), ("6", "Earnings"), ("7", "People_ID"), ("8", "Nationality"), ("9", "Name"), ("10", "Birth_Date"), ("11", "Height")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "1")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6"]), ("1", ["7", "8", "9", "10", "11"])]
        }

tvshow :: SqlSchema
tvshow =
    SqlSchema
        { peDbId = "tvshow"
        , peTableNames = HashMap.fromList [("0", "TV_Channel"), ("1", "TV_series"), ("2", "Cartoon")]
        , peColumnNames = HashMap.fromList [("1", "id"), ("2", "series_name"), ("3", "Country"), ("4", "Language"), ("5", "Content"), ("6", "Pixel_aspect_ratio_PAR"), ("7", "Hight_definition_TV"), ("8", "Pay_per_view_PPV"), ("9", "Package_Option"), ("10", "id"), ("11", "Episode"), ("12", "Air_Date"), ("13", "Rating"), ("14", "Share"), ("15", "18_49_Rating_Share"), ("16", "Viewers_m"), ("17", "Weekly_Rank"), ("18", "Channel"), ("19", "id"), ("20", "Title"), ("21", "Directed_by"), ("22", "Written_by"), ("23", "Original_air_date"), ("24", "Production_code"), ("25", "Channel")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "0"), ("8", "0"), ("9", "0"), ("10", "1"), ("11", "1"), ("12", "1"), ("13", "1"), ("14", "1"), ("15", "1"), ("16", "1"), ("17", "1"), ("18", "1"), ("19", "2"), ("20", "2"), ("21", "2"), ("22", "2"), ("23", "2"), ("24", "2"), ("25", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]), ("1", ["10", "11", "12", "13", "14", "15", "16", "17", "18"]), ("2", ["19", "20", "21", "22", "23", "24", "25"])]
        }

flight2 :: SqlSchema
flight2 =
    SqlSchema
        { peDbId = "flight_2"
        , peTableNames = HashMap.fromList [("0", "airlines"), ("1", "airports"), ("2", "flights")]
        , peColumnNames = HashMap.fromList [("1", "uid"), ("2", "Airline"), ("3", "Abbreviation"), ("4", "Country"), ("5", "City"), ("6", "AirportCode"), ("7", "AirportName"), ("8", "Country"), ("9", "CountryAbbrev"), ("10", "Airline"), ("11", "FlightNo"), ("12", "SourceAirport"), ("13", "DestAirport")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "1"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "2"), ("11", "2"), ("12", "2"), ("13", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4"]), ("1", ["5", "6", "7", "8", "9"]), ("2", ["10", "11", "12", "13"])]
        }

studentTranscriptsTracking :: SqlSchema
studentTranscriptsTracking =
    SqlSchema
        { peDbId = "student_transcripts_tracking"
        , peTableNames = HashMap.fromList [("0", "Addresses"), ("1", "Courses"), ("2", "Departments"), ("3", "Degree_Programs"), ("4", "Sections"), ("5", "Semesters"), ("6", "Students"), ("7", "Student_Enrolment"), ("8", "Student_Enrolment_Courses"), ("9", "Transcripts"), ("10", "Transcript_Contents")]
        , peColumnNames = HashMap.fromList [("1", "address_id"), ("2", "line_1"), ("3", "line_2"), ("4", "line_3"), ("5", "city"), ("6", "zip_postcode"), ("7", "state_province_county"), ("8", "country"), ("9", "other_address_details"), ("10", "course_id"), ("11", "course_name"), ("12", "course_description"), ("13", "other_details"), ("14", "department_id"), ("15", "department_name"), ("16", "department_description"), ("17", "other_details"), ("18", "degree_program_id"), ("19", "department_id"), ("20", "degree_summary_name"), ("21", "degree_summary_description"), ("22", "other_details"), ("23", "section_id"), ("24", "course_id"), ("25", "section_name"), ("26", "section_description"), ("27", "other_details"), ("28", "semester_id"), ("29", "semester_name"), ("30", "semester_description"), ("31", "other_details"), ("32", "student_id"), ("33", "current_address_id"), ("34", "permanent_address_id"), ("35", "first_name"), ("36", "middle_name"), ("37", "last_name"), ("38", "cell_mobile_number"), ("39", "email_address"), ("40", "ssn"), ("41", "date_first_registered"), ("42", "date_left"), ("43", "other_student_details"), ("44", "student_enrolment_id"), ("45", "degree_program_id"), ("46", "semester_id"), ("47", "student_id"), ("48", "other_details"), ("49", "student_course_id"), ("50", "course_id"), ("51", "student_enrolment_id"), ("52", "transcript_id"), ("53", "transcript_date"), ("54", "other_details"), ("55", "student_course_id"), ("56", "transcript_id")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "0"), ("8", "0"), ("9", "0"), ("10", "1"), ("11", "1"), ("12", "1"), ("13", "1"), ("14", "2"), ("15", "2"), ("16", "2"), ("17", "2"), ("18", "3"), ("19", "3"), ("20", "3"), ("21", "3"), ("22", "3"), ("23", "4"), ("24", "4"), ("25", "4"), ("26", "4"), ("27", "4"), ("28", "5"), ("29", "5"), ("30", "5"), ("31", "5"), ("32", "6"), ("33", "6"), ("34", "6"), ("35", "6"), ("36", "6"), ("37", "6"), ("38", "6"), ("39", "6"), ("40", "6"), ("41", "6"), ("42", "6"), ("43", "6"), ("44", "7"), ("45", "7"), ("46", "7"), ("47", "7"), ("48", "7"), ("49", "8"), ("50", "8"), ("51", "8"), ("52", "9"), ("53", "9"), ("54", "9"), ("55", "10"), ("56", "10")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]), ("1", ["10", "11", "12", "13"]), ("2", ["14", "15", "16", "17"]), ("3", ["18", "19", "20", "21", "22"]), ("4", ["23", "24", "25", "26", "27"]), ("5", ["28", "29", "30", "31"]), ("6", ["32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43"]), ("7", ["44", "45", "46", "47", "48"]), ("8", ["49", "50", "51"]), ("9", ["52", "53", "54"]), ("10", ["55", "56"])]
        }

employeeHireEvaluation :: SqlSchema
employeeHireEvaluation =
    SqlSchema
        { peDbId = "employee_hire_evaluation"
        , peTableNames = HashMap.fromList [("0", "employee"), ("1", "shop"), ("2", "hiring"), ("3", "evaluation")]
        , peColumnNames = HashMap.fromList [("1", "Employee_ID"), ("2", "Name"), ("3", "Age"), ("4", "City"), ("5", "Shop_ID"), ("6", "Name"), ("7", "Location"), ("8", "District"), ("9", "Number_products"), ("10", "Manager_name"), ("11", "Shop_ID"), ("12", "Employee_ID"), ("13", "Start_from"), ("14", "Is_full_time"), ("15", "Employee_ID"), ("16", "Year_awarded"), ("17", "Bonus")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "1"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "2"), ("12", "2"), ("13", "2"), ("14", "2"), ("15", "3"), ("16", "3"), ("17", "3")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4"]), ("1", ["5", "6", "7", "8", "9", "10"]), ("2", ["11", "12", "13", "14"]), ("3", ["15", "16", "17"])]
        }

battleDeath :: SqlSchema
battleDeath =
    SqlSchema
        { peDbId = "battle_death"
        , peTableNames = HashMap.fromList [("0", "battle"), ("1", "ship"), ("2", "death")]
        , peColumnNames = HashMap.fromList [("1", "id"), ("2", "name"), ("3", "date"), ("4", "bulgarian_commander"), ("5", "latin_commander"), ("6", "result"), ("7", "lost_in_battle"), ("8", "id"), ("9", "name"), ("10", "tonnage"), ("11", "ship_type"), ("12", "location"), ("13", "disposition_of_ship"), ("14", "caused_by_ship_id"), ("15", "id"), ("16", "note"), ("17", "killed"), ("18", "injured")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "1"), ("12", "1"), ("13", "1"), ("14", "2"), ("15", "2"), ("16", "2"), ("17", "2"), ("18", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6"]), ("1", ["7", "8", "9", "10", "11", "12", "13"]), ("2", ["14", "15", "16", "17", "18"])]
        }

wta1 :: SqlSchema
wta1 =
    SqlSchema
        { peDbId = "wta_1"
        , peTableNames = HashMap.fromList [("0", "players"), ("1", "matches"), ("2", "rankings")]
        , peColumnNames = HashMap.fromList [("1", "player_id"), ("2", "first_name"), ("3", "last_name"), ("4", "hand"), ("5", "birth_date"), ("6", "country_code"), ("7", "best_of"), ("8", "draw_size"), ("9", "loser_age"), ("10", "loser_entry"), ("11", "loser_hand"), ("12", "loser_ht"), ("13", "loser_id"), ("14", "loser_ioc"), ("15", "loser_name"), ("16", "loser_rank"), ("17", "loser_rank_points"), ("18", "loser_seed"), ("19", "match_num"), ("20", "minutes"), ("21", "round"), ("22", "score"), ("23", "surface"), ("24", "tourney_date"), ("25", "tourney_id"), ("26", "tourney_level"), ("27", "tourney_name"), ("28", "winner_age"), ("29", "winner_entry"), ("30", "winner_hand"), ("31", "winner_ht"), ("32", "winner_id"), ("33", "winner_ioc"), ("34", "winner_name"), ("35", "winner_rank"), ("36", "winner_rank_points"), ("37", "winner_seed"), ("38", "year"), ("39", "ranking_date"), ("40", "ranking"), ("41", "player_id"), ("42", "ranking_points"), ("43", "tours")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "1"), ("12", "1"), ("13", "1"), ("14", "1"), ("15", "1"), ("16", "1"), ("17", "1"), ("18", "1"), ("19", "1"), ("20", "1"), ("21", "1"), ("22", "1"), ("23", "1"), ("24", "1"), ("25", "1"), ("26", "1"), ("27", "1"), ("28", "1"), ("29", "1"), ("30", "1"), ("31", "1"), ("32", "1"), ("33", "1"), ("34", "1"), ("35", "1"), ("36", "1"), ("37", "1"), ("38", "1"), ("39", "2"), ("40", "2"), ("41", "2"), ("42", "2"), ("43", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6"]), ("1", ["7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38"]), ("2", ["39", "40", "41", "42", "43"])]
        }

world1 :: SqlSchema
world1 =
    SqlSchema
        { peDbId = "world_1"
        , peTableNames = HashMap.fromList [("0", "city"), ("1", "sqlite_sequence"), ("2", "country"), ("3", "countrylanguage")]
        , peColumnNames = HashMap.fromList [("1", "ID"), ("2", "Name"), ("3", "CountryCode"), ("4", "District"), ("5", "Population"), ("6", "name"), ("7", "seq"), ("8", "Code"), ("9", "Name"), ("10", "Continent"), ("11", "Region"), ("12", "SurfaceArea"), ("13", "IndepYear"), ("14", "Population"), ("15", "LifeExpectancy"), ("16", "GNP"), ("17", "GNPOld"), ("18", "LocalName"), ("19", "GovernmentForm"), ("20", "HeadOfState"), ("21", "Capital"), ("22", "Code2"), ("23", "CountryCode"), ("24", "Language"), ("25", "IsOfficial"), ("26", "Percentage")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "1"), ("7", "1"), ("8", "2"), ("9", "2"), ("10", "2"), ("11", "2"), ("12", "2"), ("13", "2"), ("14", "2"), ("15", "2"), ("16", "2"), ("17", "2"), ("18", "2"), ("19", "2"), ("20", "2"), ("21", "2"), ("22", "2"), ("23", "3"), ("24", "3"), ("25", "3"), ("26", "3")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5"]), ("1", ["6", "7"]), ("2", ["8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"]), ("3", ["23", "24", "25", "26"])]
        }

concertSinger :: SqlSchema
concertSinger =
    SqlSchema
        { peDbId = "concert_singer"
        , peTableNames = HashMap.fromList [("0", "stadium"), ("1", "singer"), ("2", "concert"), ("3", "singer_in_concert")]
        , peColumnNames = HashMap.fromList [("1", "Stadium_ID"), ("2", "Location"), ("3", "Name"), ("4", "Capacity"), ("5", "Highest"), ("6", "Lowest"), ("7", "Average"), ("8", "Singer_ID"), ("9", "Name"), ("10", "Country"), ("11", "Song_Name"), ("12", "Song_release_year"), ("13", "Age"), ("14", "Is_male"), ("15", "concert_ID"), ("16", "concert_Name"), ("17", "Theme"), ("18", "Stadium_ID"), ("19", "Year"), ("20", "concert_ID"), ("21", "Singer_ID")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "0"), ("7", "0"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "1"), ("12", "1"), ("13", "1"), ("14", "1"), ("15", "2"), ("16", "2"), ("17", "2"), ("18", "2"), ("19", "2"), ("20", "3"), ("21", "3")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5", "6", "7"]), ("1", ["8", "9", "10", "11", "12", "13", "14"]), ("2", ["15", "16", "17", "18", "19"]), ("3", ["20", "21"])]
        }

network1 :: SqlSchema
network1 =
    SqlSchema
        { peDbId = "network_1"
        , peTableNames = HashMap.fromList [("0", "Highschooler"), ("1", "Friend"), ("2", "Likes")]
        , peColumnNames = HashMap.fromList [("1", "ID"), ("2", "name"), ("3", "grade"), ("4", "student_id"), ("5", "friend_id"), ("6", "student_id"), ("7", "liked_id")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "1"), ("5", "1"), ("6", "2"), ("7", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3"]), ("1", ["4", "5"]), ("2", ["6", "7"])]
        }

orchestra :: SqlSchema
orchestra =
    SqlSchema
        { peDbId = "orchestra"
        , peTableNames = HashMap.fromList [("0", "conductor"), ("1", "orchestra"), ("2", "performance"), ("3", "show")]
        , peColumnNames = HashMap.fromList [("1", "Conductor_ID"), ("2", "Name"), ("3", "Age"), ("4", "Nationality"), ("5", "Year_of_Work"), ("6", "Orchestra_ID"), ("7", "Orchestra"), ("8", "Conductor_ID"), ("9", "Record_Company"), ("10", "Year_of_Founded"), ("11", "Major_Record_Format"), ("12", "Performance_ID"), ("13", "Orchestra_ID"), ("14", "Type"), ("15", "Date"), ("16", "Official_ratings_(millions)"), ("17", "Weekly_rank"), ("18", "Share"), ("19", "Show_ID"), ("20", "Performance_ID"), ("21", "If_first_show"), ("22", "Result"), ("23", "Attendance")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "0"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "1"), ("10", "1"), ("11", "1"), ("12", "2"), ("13", "2"), ("14", "2"), ("15", "2"), ("16", "2"), ("17", "2"), ("18", "2"), ("19", "3"), ("20", "3"), ("21", "3"), ("22", "3"), ("23", "3")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4", "5"]), ("1", ["6", "7", "8", "9", "10", "11"]), ("2", ["12", "13", "14", "15", "16", "17", "18"]), ("3", ["19", "20", "21", "22", "23"])]
        }

museumVisit :: SqlSchema
museumVisit =
    SqlSchema
        { peDbId = "museum_visit"
        , peTableNames = HashMap.fromList [("0", "museum"), ("1", "visitor"), ("2", "visit")]
        , peColumnNames = HashMap.fromList [("1", "Museum_ID"), ("2", "Name"), ("3", "Num_of_Staff"), ("4", "Open_Year"), ("5", "ID"), ("6", "Name"), ("7", "Level_of_membership"), ("8", "Age"), ("9", "Museum_ID"), ("10", "visitor_ID"), ("11", "Num_of_Ticket"), ("12", "Total_spent")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "0"), ("4", "0"), ("5", "1"), ("6", "1"), ("7", "1"), ("8", "1"), ("9", "2"), ("10", "2"), ("11", "2"), ("12", "2")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2", "3", "4"]), ("1", ["5", "6", "7", "8"]), ("2", ["9", "10", "11", "12"])]
        }

realEstateProperties :: SqlSchema
realEstateProperties =
    SqlSchema
        { peDbId = "real_estate_properties"
        , peTableNames = HashMap.fromList [("0", "Ref_Feature_Types"), ("1", "Ref_Property_Types"), ("2", "Other_Available_Features"), ("3", "Properties"), ("4", "Other_Property_Features")]
        , peColumnNames = HashMap.fromList [("1", "feature_type_code"), ("2", "feature_type_name"), ("3", "property_type_code"), ("4", "property_type_description"), ("5", "feature_id"), ("6", "feature_type_code"), ("7", "feature_name"), ("8", "feature_description"), ("9", "property_id"), ("10", "property_type_code"), ("11", "date_on_market"), ("12", "date_sold"), ("13", "property_name"), ("14", "property_address"), ("15", "room_count"), ("16", "vendor_requested_price"), ("17", "buyer_offered_price"), ("18", "agreed_selling_price"), ("19", "apt_feature_1"), ("20", "apt_feature_2"), ("21", "apt_feature_3"), ("22", "fld_feature_1"), ("23", "fld_feature_2"), ("24", "fld_feature_3"), ("25", "hse_feature_1"), ("26", "hse_feature_2"), ("27", "hse_feature_3"), ("28", "oth_feature_1"), ("29", "oth_feature_2"), ("30", "oth_feature_3"), ("31", "shp_feature_1"), ("32", "shp_feature_2"), ("33", "shp_feature_3"), ("34", "other_property_details"), ("35", "property_id"), ("36", "feature_id"), ("37", "property_feature_description")]
        , peColumnToTable = HashMap.fromList [("1", "0"), ("2", "0"), ("3", "1"), ("4", "1"), ("5", "2"), ("6", "2"), ("7", "2"), ("8", "2"), ("9", "3"), ("10", "3"), ("11", "3"), ("12", "3"), ("13", "3"), ("14", "3"), ("15", "3"), ("16", "3"), ("17", "3"), ("18", "3"), ("19", "3"), ("20", "3"), ("21", "3"), ("22", "3"), ("23", "3"), ("24", "3"), ("25", "3"), ("26", "3"), ("27", "3"), ("28", "3"), ("29", "3"), ("30", "3"), ("31", "3"), ("32", "3"), ("33", "3"), ("34", "3"), ("35", "4"), ("36", "4"), ("37", "4")]
        , peTableToColumns = HashMap.fromList [("0", ["1", "2"]), ("1", ["3", "4"]), ("2", ["5", "6", "7", "8"]), ("3", ["9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34"]), ("4", ["35", "36", "37"])]
        }

testPlans :: [(SqlSchema, Text)]
testPlans =
    [ -- edd55d4ed905a820d6ca16947655a80dec3a03568e863d01d3c67c42ddaac344
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Predicate [ department_name like '% computer %' ] Output [ department_description , department_name ]")
    , -- 180b86428841fc7e75e3b1a8d8a95e2bf8b8b3b4b445be82d19fc0c34bf51e2f
      (wta1, "#1 = Scan Table [ matches ] Distinct [ true ] Output [ loser_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT loser_name) AS Count_Dist_loser_name ]")
    , -- c6bc5150c9983a750e71d9667f462c05d034560988d775220ae3b526e8e64abd
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ]")
    , -- a5a6fef561cf350fc2c0f61225c80048d3e41977999c3e030b470ed1c19485e9
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ Percentage , CountryCode , Language ]")
    , -- 26edc7b34917846dc6fb176c89ec97752e591daa31f3fadc5e0bcb84f4b56b2c
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #2 = Scan Table [ city ] Output [ Population , CountryCode , Name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #2.Population , #2.Name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Population DESC ] Output [ Population , Name ]")
    , -- 72e0cde1414ecaa5cdc66b35b9cd074f48422ec83080c25ee226bf95fe4a35d4
      (wta1, "#1 = Scan Table [ matches ] Output [ year ] ; #2 = Aggregate [ #1 ] GroupBy [ year ] Output [ countstar AS Count_Star , year ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ year , Count_Star ]")
    , -- 4f42fde37cbd059904929409566173c2576d719495a3d5923a4e396355823e91
      (singer, "#1 = Scan Table [ singer ] Output [ Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ countstar AS Count_Star , Citizenship ]")
    , -- e3cddc01a42e6e4c8742e8b32c7081491e9ad65503bb886b0e38660e5c8f9e59
      (orchestra, "#1 = Scan Table [ conductor ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- dc9fa93cafe7bbc0200c3ea1a4db537478df1395d50ebeb37cca2c2cf91f79c6
      (tvshow, "#1 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ Country ] ; #2 = Scan Table [ TV_Channel ] Output [ Country , id ] ; #3 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by , Channel ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Channel = #2.id ] Distinct [ true ] Output [ #2.Country ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Country = #4.Country ] Output [ #1.Country ]")
    , -- b792df4f0b5acb59b2cc8ad354f46c20b196000a4a1ee857ec47b5beef92fe3f
      (voter1, "#1 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ]")
    , -- 2836ab9eeb271d2e43877d422f9139f14d6978de0709568fc8068b36b8212e6f
      (flight2, "#1 = Scan Table [ airports ] Output [ AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.AirportCode = #2.DestAirport OR #1.AirportCode = #2.SourceAirport ] Output [ #1.AirportCode ] ; #4 = Aggregate [ #3 ] GroupBy [ AirportCode ] Output [ countstar AS Count_Star , AirportCode ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , AirportCode ]")
    , -- 33d486052fda33a467d56045245ac5652e2c7e0abde302e86bd834c64c63b41b
      (network1, "#1 = Scan Table [ Highschooler ] Distinct [ true ] Output [ name ] ; #2 = Scan Table [ Highschooler ] Output [ name , ID ] ; #3 = Scan Table [ Friend ] Output [ student_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.student_id = #2.ID ] Distinct [ true ] Output [ #2.name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.name = #4.name ] Output [ #1.name ]")
    , -- c08c23e7cc708242ee88a3d2b2b77fcc6eba87f51093769a204df2c410d443ae
      (battleDeath, "#1 = Scan Table [ battle ] Output [ name , id ] ; #2 = Scan Table [ ship ] Output [ id , lost_in_battle ] ; #3 = Scan Table [ death ] Output [ killed , caused_by_ship_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.caused_by_ship_id = #2.id ] Output [ #3.killed , #2.lost_in_battle ] ; #5 = Aggregate [ #4 ] GroupBy [ lost_in_battle ] Output [ SUM(killed) AS Sum_killed , lost_in_battle ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.lost_in_battle = #1.id ] Output [ #5.Sum_killed , #1.name , #1.id ] ; #7 = Filter [ #6 ] Predicate [ Sum_killed > 10 ] Output [ name , id ]")
    , -- 3ea56ea638859870f74c819e5d8def86954d9136b038c68200c5e910b918ea0b
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name , #2.Earnings ]")
    , -- ad1402fa95fd3fadae44e208dbad1503f63f97dff7c87df4e4ad632bf12f911b
      (world1, "#1 = Scan Table [ country ] Output [ GNP , Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ GNP , Population ] ; #3 = Aggregate [ #2 ] Output [ MAX(GNP) AS Max_GNP , SUM(Population) AS Sum_Population ]")
    , -- 9891f13461359514e80f559cbff62c2204692fb32e2b850d48f587e0a2f068b0
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Stadium_ID IS NULL OR #1.Stadium_ID = #2.Stadium_ID ] Output [ #1.Name ]")
    , -- 92f7870d8e544dec954c41ef4da65daa4fb2cba5f0706f1d73c2442f423a6dd8
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Top [ #4 ] Rows [ 1 ] Output [ name ]")
    , -- 6ea998f796ec30bffa8e18b93df295017492f935422901936d3cd25d3d8cb4b4
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_products ] ; #2 = Aggregate [ #1 ] Output [ AVG(Number_products) AS Avg_Number_products ] ; #3 = Scan Table [ shop ] Output [ Number_products , Name ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Number_products > #2.Avg_Number_products ] Output [ #3.Name ]")
    , -- 71de702627518d63a910bbd9bb7f366eddb8c5bd2464b78e4637839084874c71
      (dogKennels, "#1 = Scan Table [ Charges ] Output [ charge_type , charge_amount ]")
    , -- 5cf1353ac1891a373d83fb718050a23c6c0ec5d44a08d41958a4d89149fef383
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ]")
    , -- 4d616fdb35747a6d6392a417df2d25850f46e59e5970a943e380befec0675e3a
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 898c347eb5c12469a2246087c9e41c6d25d26c018c7d1456e41bcc557448867e
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Distinct [ true ] Output [ degree_summary_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT degree_summary_name) AS Count_Dist_degree_summary_name ]")
    , -- adf96d93299f5428237c3f5812145f2761590bac2baec91d082aa82d0d2b0b84
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_Description , Document_ID ]")
    , -- 4f5e7016459adb9ad44e4ca87c1111a03cc59859b725f473faf61852f6d447b4
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings , Money_Rank ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Earnings DESC ] Output [ Earnings , Money_Rank ]")
    , -- 9e169afed9298dcaf606f723081977a0d33d4f22d10fc326ab83da4d35bc80d6
      (world1, "#1 = Scan Table [ country ] Output [ LifeExpectancy , Name ] ; #2 = Scan Table [ country ] Output [ Code , Name ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #4 = Filter [ #3 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.CountryCode = #2.Code ] Distinct [ true ] Output [ #2.Name ] ; #6 = Except [ #1 , #5 ] Predicate [ #1.Name = #5.Name ] Output [ #1.LifeExpectancy ] ; #7 = Aggregate [ #6 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 6a735b312c65119564c18fa7ea1b10ecb2e74b7449a429e88e93ecf303f8eeb5
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Shop_ID ] Output [ countstar AS Count_Star , Shop_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Shop_ID = #1.Shop_ID ] Output [ #1.Name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- 1b4ff28beddb2e20b5b98772dc08dc31b033b25d3bb666da28b6bfc81b517174
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Capacity , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year >= 2014 ] Output [ Stadium_ID , Year ] ; #3 = Aggregate [ #2 ] GroupBy [ Stadium_ID ] Output [ Stadium_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name , #3.Count_Star , #1.Capacity ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Capacity , Count_Star , Name ]")
    , -- 6b56664c45bbe45ade08c28a7892035d10283d0f493698f906bdc3a78a9ca431
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Output [ Teacher_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ]")
    , -- 9561b97b13a187930d20fc2c295e7c02162337366bbcd10dbbf6095d1bfd95ce
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ MAX(Net_Worth_Millions) AS Max_Net_Worth_Millions , Citizenship ]")
    , -- 2ae88df2c4162c1fe98dc4ae1452e2b0dfd06263c9a682b94df0f969d32a241f
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Student ] Output [ StuID ] ; #3 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #4 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.PetID = #3.PetID ] Output [ #4.StuID ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.StuID = #2.StuID ] Output [ #2.StuID ] ; #7 = Except [ #1 , #6 ] Predicate [ #1.StuID = #6.StuID ] Output [ #1.StuID ]")
    , -- 61f7da4b5c699fa47aef91b666d0b11804b094b4fb440fc88764c661cc7fb277
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings ]")
    , -- 697dfd5ef5b2393132d9a7c62561764004455e1c985cc95ce70a0ccc10fa9cd6
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ MAX(Net_Worth_Millions) AS Max_Net_Worth_Millions , Citizenship ]")
    , -- a2cf4e35c9235fe7fe8b7f23cd46ecbf8798764d9afd5799468de4112f0a8b3d
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ]")
    , -- e630d361fd786cda956fb2025a82fdc0fa6c5815f9737403f9f381688f2661c1
      (car1, "#1 = Scan Table [ car_names ] Output [ Model ] ; #2 = Aggregate [ #1 ] GroupBy [ Model ] Output [ countstar AS Count_Star , Model ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Model , Count_Star ]")
    , -- 18f17add3885280a0a30c8986a4b02372b3efe4cc11524ebcf759748834e7f3f
      (world1, "#1 = Scan Table [ country ] Predicate [ SurfaceArea > 3000.0 ] Output [ Continent , SurfaceArea , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'north america' ] Output [ SurfaceArea , Population ] ; #3 = Aggregate [ #2 ] Output [ AVG(SurfaceArea) AS Avg_SurfaceArea , SUM(Population) AS Sum_Population ]")
    , -- 2c9124545e4b80beca6be6f312295f8cefc9dacdef86c65bcb177ccb138f723b
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Country = 'france' ] Output [ Age , Country ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age , MAX(Age) AS Max_Age , MIN(Age) AS Min_Age ]")
    , -- 4ab4d8bcc47a07a29ea3496adc3b48879e72fe4cfc5f8a0a2d496c8918645efc
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Directed_by ] ; #2 = Aggregate [ #1 ] GroupBy [ Directed_by ] Output [ countstar AS Count_Star , Directed_by ]")
    , -- 4e761a9127f36296f20021c44a8cadca031a57c3bb317ef82e3f9b28cfc2fee5
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #2 = Scan Table [ matches ] Predicate [ tourney_name = 'wta championships' ] Output [ tourney_name , winner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.winner_id = #1.player_id ] Distinct [ true ] Output [ #1.country_code , #1.first_name ] ; #4 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #5 = Scan Table [ matches ] Predicate [ tourney_name = 'australian open' ] Output [ tourney_name , winner_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.winner_id = #4.player_id ] Distinct [ true ] Output [ #4.first_name , #4.country_code ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.country_code = #6.country_code ] Distinct [ true ] Output [ #3.first_name , #3.country_code ]")
    , -- 2d9d0cf37702e5dc6bca104899f8e9e4118cca15f96b64c53fa9158e1aec75f7
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 867cde5170a26741ae4655d22fca0ab3bb8617a3498fc46fe257463dea794d20
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id , birth_date ] ; #2 = Scan Table [ matches ] Output [ winner_rank_points , winner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.winner_id = #1.player_id ] Output [ #2.winner_rank_points , #1.country_code , #1.birth_date , #1.first_name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ winner_rank_points , country_code , first_name , birth_date ]")
    , -- 2a1d61f34fe5ad0f7a58c53d75caa500a2803b2c6147c10377c44408591e4e43
      (network1, "#1 = Scan Table [ Highschooler ] Output [ ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.ID ]")
    , -- 473d7b41fadce5025b641f1cbfabfb4e0142a9cf4a859267322201b8fc5f9040
      (car1, "#1 = Scan Table [ continents ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 3682b3829c0ef3cdd72b77929881f34ffb80f004698e5f6de20618175c13a2b2
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 0ee950e67cdbf2bef9cf54225445cebf182b136e6592005c3991f6b2a08a2d9e
      (battleDeath, "#1 = Scan Table [ death ] Output [ injured ] ; #2 = Aggregate [ #1 ] Output [ AVG(injured) AS Avg_injured ]")
    , -- 8376e9086290a914bac06f17b3d831a833daedaa3449dbcbb5c6881a573673e1
      (wta1, "#1 = Scan Table [ players ] Distinct [ true ] Output [ country_code ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT country_code) AS Count_Dist_country_code ]")
    , -- d63af966914473b096de571cad64b5b43edd5043e710afc66f28430d0095ca9b
      (world1, "#1 = Scan Table [ city ] Predicate [ District = 'gelderland' ] Output [ District , Population ] ; #2 = Aggregate [ #1 ] Output [ SUM(Population) AS Sum_Population ]")
    , -- deabaedeb3981927bf1f396a795b435a3035bd61ca255b76038121b2dbae91d2
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language <> 'english' ] Output [ CountryCode , Language ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ CountryCode ]")
    , -- 6aa937ac96aa0f82051b2f20f694460c36d303d0182fbfdc794547f31f98e84d
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Year_of_Work , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Year_of_Work DESC ] Output [ Year_of_Work , Name ]")
    , -- 9f6ea46405112628df6ab798bc562f0bebb75f5ea0d962a455271e949a879db5
      (car1, "#1 = Scan Table [ cars_data ] Output [ Id , Accelerate ] ; #2 = Scan Table [ car_names ] Predicate [ Make = 'amc hornet sportabout ( sw )' ] Output [ MakeId , Make ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.MakeId = #1.Id ] Output [ #1.Accelerate ]")
    , -- 3b794e094e7479a816e8818a7514d0e91bc737440da6b6c76c26a0f6041aab68
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ singer_in_concert ] Output [ Singer_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Singer_ID ] Output [ Singer_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #3.Count_Star ]")
    , -- 1da527580c9c855544ac3513a1908359742acd8cd9962f04b70bd6599508a14b
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders > 4 ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- ab86e3891f95a394dbe0237a414d25eb65194fc3e353b440873e332010727c71
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ]")
    , -- e835c56211f4c9c6c4b47bb293e2ebc043d28551a4456f405a8473f234ffbbfa
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Directed_by ] ; #2 = Aggregate [ #1 ] GroupBy [ Directed_by ] Output [ countstar AS Count_Star , Directed_by ]")
    , -- fce8efd12aefcfdc3f2e9ca07f4444e7f1865fffdd2bc1fc7ec53c0727a02f6a
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_Description , Document_ID ]")
    , -- fefb38b1e47ce56411e8d791f7aff3e81d9c58f99f39beffa4c2b2146f8950a6
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ car_names ] Output [ Model ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Model = #2.Model ] Output [ #2.Maker ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Maker = #1.Id ] Output [ #1.Maker , #1.Id ] ; #6 = Aggregate [ #5 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , Maker ] ; #7 = Filter [ #6 ] Predicate [ Count_Star > 3 ] Output [ Id , Maker ] ; #8 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #9 = Scan Table [ model_list ] Output [ Maker ] ; #10 = Join [ #8 , #9 ] Predicate [ #9.Maker = #8.Id ] Output [ #8.Maker , #8.Id ] ; #11 = Join [ #7 , #10 ] Predicate [ #7.Id = #10.Id ] Output [ #7.Id , #7.Maker ] ; #12 = Aggregate [ #11 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , Maker ] ; #13 = Filter [ #12 ] Predicate [ Count_Star >= 2 ] Output [ Id , Maker ]")
    , -- 298d870bec392fa19b20b8832552e950629a8a216a48964ca01db204efba7167
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'bk' ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Document_Name , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #2.Document_Name ]")
    , -- 554a0b7814c3f16586c821c590d72c85fb6cd567bdaed14279d59e072644ed1f
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- b67ff822c24588338ffb03a8d5dfa10d171e0b5e7187fc901ceb178b9e60260e
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age , Country , Name ]")
    , -- caf62133487d41ae6c81bff1ac1282aecfff3503c87cfb30cb05002b66459a4f
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'chinese' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Continent ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 6461e8c73ff28757df50984fd488bc500623f7b97be11073ca02266be64c7ea5
      (concertSinger, "#1 = Scan Table [ stadium ] Distinct [ true ] Output [ Name ] ; #2 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #3 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Stadium_ID , Year ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Stadium_ID = #2.Stadium_ID ] Distinct [ true ] Output [ #2.Name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Name = #4.Name ] Output [ #1.Name ]")
    , -- 03d124ae45b4ce58b2dcbf28e5bd3e207107ab62ee5a796cf67d278f03da5991
      (concertSinger, "#1 = Scan Table [ stadium ] Predicate [ Capacity >= 5000 AND Capacity <= 10000 ] Output [ Location , Capacity , Name ]")
    , -- 1c36e57f9f01e92d2e032a36e5bd1662f81d141e75079ff1d91e1611247d3278
      (world1, "#1 = Scan Table [ country ] Predicate [ IndepYear > 1950 ] Output [ IndepYear , Name ]")
    , -- 702b793672d277ed4c482f92123e570d1e078e384702f2391b7b7bde241442cd
      (concertSinger, "#1 = Scan Table [ stadium ] Predicate [ Capacity >= 5000 AND Capacity <= 10000 ] Output [ Location , Capacity , Name ]")
    , -- 979d85d193f3882cf9f01bfff9c1151c9ab871fd99ba917b143d4970cf33cc05
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID , Sales ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #2.Sales ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ SUM(Sales) AS Sum_Sales , Name ]")
    , -- 16a6e522cfd501f609c46856f658cfd95b8ef2517b7ad60ecc032807076c99ac
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryId , #1.CountryName , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ CountryId , CountryName ] ; #6 = Scan Table [ model_list ] Predicate [ Model = 'fiat' ] Output [ Model , Maker ] ; #7 = Scan Table [ car_makers ] Output [ Id , Country ] ; #8 = Join [ #6 , #7 ] Predicate [ #7.Id = #6.Maker ] Output [ #7.Country ] ; #9 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #10 = Join [ #8 , #9 ] Predicate [ #9.CountryId = #8.Country ] Output [ #9.CountryId , #9.CountryName ] ; #11 = Union [ #5 , #10 ] Output [ #5.CountryName , #5.CountryId ]")
    , -- 4f5fe3262a45fa6129aae57814c7c9a3f1a980933296e4d19dd4e2edd73f005d
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders > 6 ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 5cce379b4051e866afaec01797e5a9818e966ef70d3e2d375c35ce632f044540
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name , professional_id ] ; #2 = Scan Table [ Treatments ] Output [ professional_id , date_of_treatment ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #2.date_of_treatment , #1.first_name ]")
    , -- 40bb6ce78af5916e027bb54942e97bb6cf361c0fd77103510be85af50772caa2
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Distinct [ true ] Output [ degree_summary_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT degree_summary_name) AS Count_Dist_degree_summary_name ]")
    , -- 298a9f020337263ed5acf9bcfad40d6801fc573097ccc09cf57b97caf658b304
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Document_ID = #1.Document_ID ] Output [ #1.Document_Name , #3.Count_Star , #3.Document_ID ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Document_Name , Document_ID , Count_Star ]")
    , -- f2835d4663242f441aa3f03c81b9ec20269ac042793a9eca922c9cca3f737d5a
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Description = 'book' ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- 1f4b6b8fe58168e372e3265b1dd9ea23b4530538ad134a2ffba2567cc80d9b8e
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , FullName ]")
    , -- 50c40e6bc28069c3bcc0382be99a457edbe8ea4d10caa0cd645599f8e47f6379
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'ahd' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ]")
    , -- c1517697f4905f2a0efa5559d00932403e977d6eed11d9b1a5ddadf709b72f34
      (voter1, "#1 = Scan Table [ votes ] Distinct [ true ] Output [ state , created ]")
    , -- 37f9a40298fb04b95b25179baa94b661d7fd499541ebb2c201308c9abf2387cf
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm <> 'republic' ] Output [ Code , GovernmentForm ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Code ]")
    , -- 83bd88f309e485989759ac4a128180397925d2a7c8d9281b6ea2185f18b060b7
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , grade ]")
    , -- 179c60a2a7a0834d0afcd9c0c07b9051c8adb59bea2837c5aef588b199ee14dd
      (museumVisit, "#1 = Scan Table [ museum ] Predicate [ Open_Year > 2010 ] Output [ Open_Year , Num_of_Staff ] ; #2 = Aggregate [ #1 ] Output [ MIN(Num_of_Staff) AS Min_Num_of_Staff ] ; #3 = Scan Table [ museum ] Output [ Num_of_Staff , Name ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Num_of_Staff > #2.Min_Num_of_Staff ] Output [ #3.Name ]")
    , -- 90709a58f713a9b610f22a044e73dd9540902fee65a49244b062b9344b9e1493
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_ID ] ; #2 = Scan Table [ Documents ] Distinct [ true ] Output [ Template_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_ID ]")
    , -- cf1777ff01be53121ea57ad7746f882c2f961f98fea981a64849e65d84fc5d67
      (world1, "#1 = Scan Table [ country ] Output [ Name , Continent , LifeExpectancy , Population , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Population , SurfaceArea , LifeExpectancy , Name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ SurfaceArea DESC ] Output [ Population , SurfaceArea , LifeExpectancy , Name ]")
    , -- 293ca51746fc9d32a1dd66c427eca16fb5c854a5a331c121a91808f0c9fb49a7
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- 2cccadad4927cf8f0d910ca98ba5bd58effcdffa734554dc162d4da321a9f158
      (wta1, "#1 = Scan Table [ players ] Output [ birth_date , first_name , last_name ]")
    , -- 4fc046eaa05a69a8810508b57112267cd85a6423220b08115f978f1ece9484c9
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Written_by = 'joseph kuhr' ] Output [ Written_by ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f00fb87bd37e2b2945ed497ba5ea69eac0f7d33f744a55657896bdbfc31dd036
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ Name , Age , ID ] ; #2 = Scan Table [ visit ] Output [ Num_of_Ticket , visitor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.visitor_ID = #1.ID ] Output [ #1.Age , #2.Num_of_Ticket , #1.Name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Num_of_Ticket DESC ] Output [ Age , Num_of_Ticket , Name ]")
    , -- eaf31b9958df56510060b3166c48aad13728255fcd5fe25e6770bd3b14055dc6
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'brazil' ] Output [ Name , LifeExpectancy , Population ]")
    , -- 47a6d2e06009bae4ce2b0899e83998340dd9d23146d200cab07b8592300f8254
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Year < 1980 ] Output [ Horsepower , Year ] ; #2 = Aggregate [ #1 ] Output [ AVG(Horsepower) AS Avg_Horsepower ]")
    , -- 064cdc0cdd3190421bd5ff7a37e51119776ea589c73a6415f867acf56fce848d
      (dogKennels, "#1 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- fd3ab86c1726ff82dfae3f950d230250d8b8d89f8ebb0146cad28b2fb7ba5ecb
      (studentTranscriptsTracking, "#1 = Scan Table [ Semesters ] Output [ semester_name , semester_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ semester_id ] ; #3 = Aggregate [ #2 ] GroupBy [ semester_id ] Output [ countstar AS Count_Star , semester_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.semester_id = #1.semester_id ] Output [ #1.semester_id , #1.semester_name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ semester_name , semester_id , Count_Star ]")
    , -- 3fad8c40ea6e872d9085dc84fbff9347ef1135d054e5f0ce599cb367400f65e7
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ]")
    , -- 261b8f31c3472cd304eb89de390eab8847db8e7264ae2f27808562dbb6c75d24
      (dogKennels, "#1 = Scan Table [ Treatments ] Output [ cost_of_treatment , date_of_treatment ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_of_treatment DESC ] Output [ cost_of_treatment , date_of_treatment ]")
    , -- 91bee6c64b55ed007541ee7bc3edc5cd2ac530d2f8aa720ebe0a6ac76f71ac0e
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Birth_Date , Name ]")
    , -- 60e9a83821454bd3ff7a90d11440f1e090c22d5ce2e40674a210dd1189f47522
      (museumVisit, "#1 = Scan Table [ museum ] Output [ Num_of_Staff , Museum_ID , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Num_of_Staff DESC ] Output [ Num_of_Staff , Museum_ID , Name ]")
    , -- 38149da0bf176f61c70db72f6915039e6dee7a9e184475459d86407d032bdf3d
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'us territory' ] Output [ GNP , GovernmentForm , Population ] ; #2 = Aggregate [ #1 ] Output [ AVG(GNP) AS Avg_GNP , SUM(Population) AS Sum_Population ]")
    , -- 7c03fdfb4bdd1f01de1be9c484bed41e27e47fc1fbfbf8b8c8258bc22293fd9e
      (car1, "#1 = Scan Table [ countries ] Predicate [ CountryName = 'france' ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Country = #1.CountryId ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 369b5b7dbc8e97b2da310dc1ef97a060a3abec21242176afd9b5b8dcbcad5ff7
      (flight2, "#1 = Scan Table [ airlines ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8b218ce8c7ce351dc037f9bf3d576f76412eeef674548ace0b382309f73f1fbe
      (car1, "#1 = Scan Table [ cars_data ] Output [ Horsepower , Accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Accelerate DESC ] Output [ Horsepower , Accelerate ]")
    , -- e0677381f837d83064d2983f6482252b89c6d6f8f0f60cad1d6fabe5917d5ec1
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Predicate [ Number_products < 3000 ] Distinct [ true ] Output [ District ] ; #2 = Scan Table [ shop ] Predicate [ Number_products > 10000 ] Distinct [ true ] Output [ District ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.District = #2.District ] Distinct [ true ] Output [ #1.District ]")
    , -- 0958c0b2d43af122aef2fbe2e3aa770ae881b8f5b43febf6c3f9a3b5cf13e025
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade > 5 ] Output [ grade , name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ name ]")
    , -- 8fee41930419ed1b60bc8a03182d24c4aef408f9fe3d3042d5197c827080bfb9
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'anthony' ] Output [ City , AirportName , AirportCode ]")
    , -- 5c3c8a98e8d4b701ff4536883ed85090028f3f9d26cd21f026fd0d2664bc61c8
      (museumVisit, "#1 = Scan Table [ museum ] Predicate [ Open_Year < 2009 ] Output [ Open_Year , Num_of_Staff ] ; #2 = Aggregate [ #1 ] Output [ AVG(Num_of_Staff) AS Avg_Num_of_Staff ]")
    , -- 32e1d3180f2d4a1423db0aafca0f239d324b1efe137c80c4c83049c8a3525e55
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Singer_ID IS NULL OR #1.Singer_ID = #2.Singer_ID ] Output [ #1.Name ]")
    , -- 154ade6ec7a46682d047b9181ae3c0a84374232035fcf506874a2219cdd09599
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'bachelor' ] Output [ degree_summary_name , degree_program_id ] ; #3 = Scan Table [ Student_Enrolment ] Output [ student_id , degree_program_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.degree_program_id = #2.degree_program_id ] Output [ #3.student_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.student_id = #1.student_id ] Distinct [ true ] Output [ #1.last_name , #1.middle_name , #1.first_name ]")
    , -- fbc04bab781dade7000cb80dc5e8d4b3dfa2941ca1a1e387497976c05365209d
      (pokerPlayer, "#1 = Scan Table [ people ] Distinct [ true ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Nationality) AS Count_Dist_Nationality ]")
    , -- 66b83582e021b8db08e2b4d08c135401f2b5f33950791e8cd6590d2f7ead0857
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Country = 'usa' ] Output [ Country ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- ab348f161bbbba695ed592adb3a2971ae4a97acac0250ed0130c2c730c9403f5
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'master' ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id , semester_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.degree_program_id = #1.degree_program_id ] Distinct [ true ] Output [ #2.semester_id ] ; #4 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'bachelor' ] Output [ degree_summary_name , degree_program_id ] ; #5 = Scan Table [ Student_Enrolment ] Output [ degree_program_id , semester_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.degree_program_id = #4.degree_program_id ] Distinct [ true ] Output [ #5.semester_id ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.semester_id = #6.semester_id ] Distinct [ true ] Output [ #3.semester_id ]")
    , -- b8c847904e750fe4416bc380d732457def4ae381a28aa719d6a951f5fc9d7fad
      (concertSinger, "#1 = Scan Table [ concert ] Predicate [ Year = 2014 OR Year = 2015 ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 35116c37e2ee06bd187013cda7d51a7b1c1c96f3da8bba25d01a181000644bbc
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Version_Number > 5 ] Output [ Template_Type_Code , Version_Number ]")
    , -- 2ac1015ed0642af90685a98b50fb7c5ab2fd9c6dc918f84b974bfc879d519cfe
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ line_1 , line_2 ]")
    , -- 614838cd0b6d31a3440afa4fe30f7f7cbcdde3207859e06a773f1369c608adda
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Abbreviation , Country , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline , #1.Abbreviation , #1.Country ] ; #4 = Aggregate [ #3 ] GroupBy [ Abbreviation , Country , Airline ] Output [ countstar AS Count_Star , Abbreviation , Country ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Abbreviation , Country , Count_Star ]")
    , -- d8a40ee798a91a25e6fb481a445890439fc51d9a7674fac4b8bba65179b56c41
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ pet_age > 1 ] Output [ PetID , weight , pet_age ]")
    , -- 13402275c28ea205994823c1db8e3dc7acb229431deaad3cb2954b8df3778978
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name , date_first_registered , middle_name , last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_first_registered ASC ] Output [ first_name , date_first_registered , middle_name , last_name ]")
    , -- 869d090908c20d389878b3c1a8c760b86d77771817c2396a1fe57ce4f1537348
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #4 = Scan Table [ cars_data ] Output [ Id , Weight ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Id = #3.MakeId ] Output [ #4.Weight , #3.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #5.Weight , #2.Model , #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #6.Model ]")
    , -- eab7bb94e7abc6a9e24b9ce9ebd085bd7718b6149dae5227d4158b83dc38b80a
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6df74d6511b3ad4d9033a1211957b3e5a2d11dba71e49fa907fd46472495da9e
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , grade ]")
    , -- f32f921b7e1bb2c2a6a65e5e2c8979d5327e1a196ff0365c2e9f2547a5766f1b
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Year_of_Work , Name ]")
    , -- 52e8fb837195616b49756027ccc6ca0ce0a8345e015fb0650c436258d6d84414
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_arrived , date_departed , dog_id ] ; #2 = Scan Table [ Treatments ] Output [ dog_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Distinct [ true ] Output [ #1.date_departed , #1.date_arrived ]")
    , -- 0b041ebce208085bea5e35531b4a6cdbde7156f9c58a9b2bd26415a0ebd102b1
      (dogKennels, "#1 = Scan Table [ Charges ] Output [ charge_amount ] ; #2 = Aggregate [ #1 ] Output [ MAX(charge_amount) AS Max_charge_amount ]")
    , -- aead834686e53b5a28f6330568c6b82b64797de7cded35cbc5b1feab82bda05c
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = Scan Table [ country ] Output [ Code , Name ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.CountryCode = #2.Code ] Distinct [ true ] Output [ #2.Name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Name = #4.Name ] Output [ #1.Population ] ; #6 = Aggregate [ #5 ] Output [ SUM(Population) AS Sum_Population ]")
    , -- 594047a3f87d0aa4e97ebf98f5d3e84a42a74422b787725d5ca6a6f0d75c94fb
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Output [ department_name , department_id ] ; #2 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #3 = Aggregate [ #2 ] GroupBy [ department_id ] Output [ countstar AS Count_Star , department_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.department_id = #1.department_id ] Output [ #1.department_name , #3.department_id , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ department_name , Count_Star , department_id ]")
    , -- 1c3db4eb8cdcb620190283407819418853749cad50efe83d47189b48e2ecdde4
      (world1, "#1 = Scan Table [ country ] Output [ Continent , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ SurfaceArea ] ; #3 = Aggregate [ #2 ] Output [ MIN(SurfaceArea) AS Min_SurfaceArea ] ; #4 = Scan Table [ country ] Output [ SurfaceArea , Name ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.SurfaceArea > #3.Min_SurfaceArea ] Output [ #4.Name ]")
    , -- f5e097f81472a5f1334b7da4a4ef498e2d1370ef2466d6fe70ffd87c12059458
      (world1, "#1 = Scan Table [ city ] Output [ Population ] ; #2 = Aggregate [ #1 ] Output [ AVG(Population) AS Avg_Population ] ; #3 = Scan Table [ city ] Output [ District , Population ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Population > #2.Avg_Population ] Output [ #3.District ] ; #5 = Aggregate [ #4 ] GroupBy [ District ] Output [ District , countstar AS Count_Star ]")
    , -- 6b47ad0390ba5a23811643ceb795c832310e9b535c05f9d935d83a9fe79d8f85
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Hometown , Count_Star ]")
    , -- 7f4d3002391a94f1350386c3c530f9f41872958aaab723ea73a778c124284968
      (voter1, "#1 = Scan Table [ area_code_state ] Output [ area_code , state ] ; #2 = Scan Table [ votes ] Output [ state ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.state = #1.state ] Output [ #1.area_code ] ; #4 = Aggregate [ #3 ] GroupBy [ area_code ] Output [ area_code , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ area_code , Count_Star ]")
    , -- f354038a754fe4726aab53423b47fd7259de7b16d4e90b949c9f3f0fe7c097a5
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , transcript_id ] ; #2 = Scan Table [ Transcript_Contents ] Output [ transcript_id ] ; #3 = Aggregate [ #2 ] GroupBy [ transcript_id ] Output [ countstar AS Count_Star , transcript_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.transcript_id = #1.transcript_id ] Output [ #1.transcript_date , #3.transcript_id , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ transcript_date , transcript_id ]")
    , -- c3e439034b6fe1bfae33907fecac07de08ca1c6e4692dd9426bffe18b4777f26
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Aggregate [ #2 ] GroupBy [ StuID ] Output [ StuID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.StuID = #1.StuID ] Output [ #1.StuID , #3.Count_Star ]")
    , -- 011a772567169c804c61ebdecf6dcc9f19f77788577f9b41c55d6f917bd638fc
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Name ]")
    , -- 021957d7439054583c88614742c82045301c5c4676dc72aef66e2b98ed986b63
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ] ; #4 = Aggregate [ #3 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ]")
    , -- 0d0142deb8de8f5219172ede8c642c91ddae82dd31bf4d779468a6fd3c876d10
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Share ] ; #2 = Aggregate [ #1 ] Output [ MIN(Share) AS Min_Share , MAX(Share) AS Max_Share ]")
    , -- c501736c887bf86ce56b90e4db34439faacb5416059971b688fd5830afa86a07
      (wta1, "#1 = Scan Table [ matches ] Predicate [ tourney_name = 'australian open' ] Output [ winner_rank_points , tourney_name , winner_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ winner_rank_points , winner_name ]")
    , -- f7f4826cde3d4d2d0ff201160a9274986c4dc75f8346cba26e99e80fd3ccc0b4
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = Scan Table [ country ] Output [ Code , Name ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.CountryCode = #2.Code ] Distinct [ true ] Output [ #2.Name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Name = #4.Name ] Output [ #1.Population ] ; #6 = Aggregate [ #5 ] Output [ SUM(Population) AS Sum_Population ]")
    , -- 25e6219ead2bf27a2598b9113dc3d3af8c1960671ba08542f364e3d1cf519404
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.student_id ] Output [ #1.student_id , #1.first_name , #1.last_name , #3.Count_Star , #1.middle_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ student_id , last_name , first_name , middle_name , Count_Star ]")
    , -- e4f3f3933094ccad96397a211a67ef8bd7f0009aa568a942929d5e84304ff8e5
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Document_ID , Count_Star ]")
    , -- 39ceb08b1483abd2fc6eb7e0c6288d9443225a383f6d319256bd830cc714cebc
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'cvo' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Distinct [ true ] Output [ #1.Airline ] ; #4 = Scan Table [ airlines ] Output [ uid , Airline ] ; #5 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , Airline ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Airline = #4.uid ] Output [ #4.Airline ] ; #7 = Except [ #3 , #6 ] Predicate [ #3.Airline = #6.Airline ] Output [ #3.Airline ]")
    , -- 111b103537318355b92ca659ac7eb2d1145d8a72756a47d2355826c9c51c0998
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 1 AND Count_Star <= 2 ] Output [ Document_ID ]")
    , -- 0185d5551797ce6214ec07f1a2a8d2791d103019f6b83bb6fe52fc6322a0807b
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ Name ]")
    , -- 141841cbe0cbd647aee9c2aafc35639203dbf2df3604e6c80a0c387bb04ceae0
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_rank_points , winner_name ] ; #2 = Aggregate [ #1 ] GroupBy [ winner_rank_points , winner_name ] Output [ winner_rank_points , countstar AS Count_Star , winner_name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ winner_rank_points , winner_name , Count_Star ]")
    , -- d612319015bf64e8590a72838cdd91e35aaaaaa0b6c436634cc43acf73848f15
      (wta1, "#1 = Scan Table [ players ] Predicate [ country_code = 'usa' ] Output [ country_code , first_name , birth_date ]")
    , -- 3102cd9aae10b96ebbf6c9abc056927ab9dbbab64da7a97f17bb5757b07eb70f
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Predicate [ Earnings < 200000.0 ] Output [ Final_Table_Made , Earnings ] ; #2 = Aggregate [ #1 ] Output [ MAX(Final_Table_Made) AS Max_Final_Table_Made ]")
    , -- ec825644def6d351087212ad83bc285b307c370ff3598206227c45b0b4188c7f
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Code ] ; #3 = Scan Table [ countrylanguage ] Output [ CountryCode , Language ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.CountryCode = #2.Code ] Output [ #3.Language ] ; #5 = Aggregate [ #4 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #6 = TopSort [ #5 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language , Count_Star ]")
    , -- 28003ee356dcce5bec7b0a6b0ac8b51f30bc4cfa2b0b8310e8dd3fb0007706b7
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Output [ #1.Age , #1.StuID , #1.Fname ] ; #6 = Scan Table [ Student ] Output [ StuID ] ; #7 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #8 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.PetID = #7.PetID ] Output [ #8.StuID ] ; #10 = Join [ #6 , #9 ] Predicate [ #9.StuID = #6.StuID ] Output [ #6.StuID ] ; #11 = Except [ #5 , #10 ] Predicate [ #5.StuID = #10.StuID ] Output [ #5.Age , #5.Fname ]")
    , -- e7e55a8fa3c545c49218fac804bb17a8f183588046d59a33f56a1e69d025ff83
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name , date_left , middle_name , last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_left ASC ] Output [ first_name , date_left , middle_name , last_name ]")
    , -- d007f7e960ee7114376f5b06337325a6a3415ddde9d9fc135cad7075ac451bb9
      (car1, "#1 = Scan Table [ cars_data ] Output [ Weight , Year ] ; #2 = Aggregate [ #1 ] GroupBy [ Year ] Output [ Year , AVG(Weight) AS Avg_Weight ]")
    , -- efc3d6b583061fdac5b1192e6644f9c76d5ae824ba2e041fabcadee05b13cb63
      (battleDeath, "#1 = Scan Table [ death ] Output [ killed ] ; #2 = Aggregate [ #1 ] Output [ MIN(killed) AS Min_killed , MAX(killed) AS Max_killed ]")
    , -- 335feb174905f95c58ecd6591d17c573f3b40baf343333f6bbeed83c02516e79
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Predicate [ Age < 30 ] Output [ City , Age ] ; #2 = Aggregate [ #1 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 1 ] Output [ City ]")
    , -- 447bf0c569ae8d2fdba890134e396060901e148955b831579e829629ea319d33
      (world1, "#1 = Scan Table [ country ] Predicate [ Region = 'central africa' ] Output [ LifeExpectancy , Region ] ; #2 = Aggregate [ #1 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- d86ceaccd1552a8dec247eb8118198684cfdf5be0ab450b672774656c4ac72a2
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport , FlightNo ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ #2.FlightNo ]")
    , -- ad8d6ae8b20c0d4474d54cfe992634403c35dd7cd7909986e366c0e742b93105
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- d011124ee39b8a8168783bbde992cc343aa3b925ea416d5262d1d21b8276ec93
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #2.Stadium_ID , #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Stadium_ID ] Output [ countstar AS Count_Star , Name ]")
    , -- 55ed9a583e8099eef15899b28809eab0db5d06e127a724e4cc65ad722df4beed
      (battleDeath, "#1 = Scan Table [ battle ] Predicate [ bulgarian_commander <> 'boril' ] Output [ result , bulgarian_commander , name ]")
    , -- 12d76df65c31c361eba089ea8e44faefd069c74214a2ba2d4a8b0f5dc7ed7e26
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text = 'brazil' ] Distinct [ true ] Output [ Document_ID ] ; #2 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text = 'ireland' ] Distinct [ true ] Output [ Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Document_ID = #2.Document_ID ] Distinct [ true ] Output [ #1.Document_ID ]")
    , -- ff3b230011a43e158f188c66978cc47d9dafc64bc34fcc368317639768ba0419
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Conductor_ID , Name ] ; #2 = Scan Table [ orchestra ] Output [ Orchestra , Conductor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Conductor_ID = #1.Conductor_ID ] Output [ #1.Name , #2.Orchestra ]")
    , -- 341f8b90b4223634d3f86dfbdbdb6e798b7ae3bffe8641e55dafa4f3b7536d88
      (singer, "#1 = Scan Table [ singer ] Predicate [ Birth_Year < 1945.0 ] Distinct [ true ] Output [ Citizenship ] ; #2 = Scan Table [ singer ] Predicate [ Birth_Year > 1955.0 ] Distinct [ true ] Output [ Citizenship ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Citizenship = #2.Citizenship ] Distinct [ true ] Output [ #1.Citizenship ]")
    , -- b5a4050650d175c17ca4a9ec4d0c3a55e0950b773d6cd0d07c3d7f1204ea44e5
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ AVG(age) AS Avg_age ]")
    , -- b6618cc926b5b8cc6e09139cb718b03092808549394e8287aafb2b9044c491bf
      (concertSinger, "#1 = Scan Table [ concert ] Output [ concert_Name , Theme , concert_ID ] ; #2 = Scan Table [ singer_in_concert ] Output [ concert_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ concert_ID ] Output [ countstar AS Count_Star , concert_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.concert_ID = #1.concert_ID ] Output [ #1.concert_Name , #3.Count_Star , #1.Theme ]")
    , -- 79abb4aa8ede602463ad0c23ef7d323059fd0942a2c077791c8902fa8a6b3c84
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- becf4ca70f8cd646140303dd9052c30e59cd6a3ef9f406a2c78bcfcddbac61ed
      (car1, "#1 = Scan Table [ cars_data ] Output [ Weight , Year ] ; #2 = Aggregate [ #1 ] GroupBy [ Year ] Output [ Year , AVG(Weight) AS Avg_Weight ]")
    , -- e627d88639a10d9d3ab45b0ed4ded75eb7a6be53aa1884abb1b57143a09899af
      (pets1, "#1 = Scan Table [ Pets ] Output [ pet_age , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ MAX(pet_age) AS Max_pet_age , AVG(pet_age) AS Avg_pet_age , PetType ]")
    , -- 7150c07fb04ec364ebd00863c0abea6344eefeff62b6937753626258890e1907
      (car1, "#1 = Scan Table [ car_names ] Predicate [ Model = 'volvo' ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , Edispl ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Edispl ] ; #4 = Aggregate [ #3 ] Output [ AVG(Edispl) AS Avg_Edispl ]")
    , -- 874d7f27668df1183762770b3c6571180db780700251069053ba4401174165ef
      (courseTeach, "#1 = Scan Table [ teacher ] Predicate [ Age = 32 OR Age = 33 ] Output [ Age , Name ]")
    , -- 22fcbb5f6a1777be8b833f8a2bc392d1c77031be64764d8c10e70ae9a4d5e94b
      (world1, "#1 = Scan Table [ country ] Output [ SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 5 ] OrderBy [ SurfaceArea DESC ] Output [ SurfaceArea , Name ]")
    , -- 0fafa609fb687bd11e39aafb14e0ffb70a27929a9b591f3c196cc875ede3ebf9
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ MAX(age) AS Max_age ]")
    , -- 73eb7b4c3f37bf11cedc8f329393c4d8a8e8cfe20fd3345a5a445897b86fa329
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcript_Contents ] Output [ student_course_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_course_id ] Output [ countstar AS Count_Star , student_course_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ student_course_id , Count_Star ]")
    , -- d25d036afc69baf9a3904e24917c7343ef491033d06727dec986ad7c1acc8f97
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.degree_program_id = #1.degree_program_id ] Output [ #1.degree_summary_name ] ; #4 = Aggregate [ #3 ] GroupBy [ degree_summary_name ] Output [ degree_summary_name , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_summary_name , Count_Star ]")
    , -- 5c0de2f93c0a4a04d5e485de311035b20abd380bf6580f29e898c84ac4a90fc1
      (employeeHireEvaluation, "#1 = Scan Table [ hiring ] Output [ Employee_ID , Start_from , Shop_ID , Is_full_time ]")
    , -- 96e58374f4e8995981abdae0add2d49bb797fb8e70ebe07715e6906b533c1775
      (world1, "#1 = Scan Table [ country ] Predicate [ Population = 80000 ] Output [ Continent , Population , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ Name ]")
    , -- 6269b3c79bb884695b183d76877a2391ef7ff843fd60ae69ef86d1a04074438f
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Distinct [ true ] Output [ current_address_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- c806b535829c219151ad9a84fea53ee58667be3b934659c7d28adde55c6b46f0
      (world1, "#1 = Scan Table [ country ] Output [ Continent , GovernmentForm ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Distinct [ true ] Output [ GovernmentForm ] ; #3 = Aggregate [ #2 ] Output [ countstar AS Count_Star ]")
    , -- 0d5508ac8b087357c9f03f1531347cce564d823440b751d59a250ecf04a7a379
      (car1, "#1 = Scan Table [ continents ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 90fe37982799391287e4f0d346699f1b44e07bfa60c82d7570607cd1983a3094
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ state_province_county = 'northcarolina' ] Output [ address_id , state_province_county ] ; #2 = Scan Table [ Students ] Output [ current_address_id , last_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.current_address_id = #1.address_id ] Distinct [ true ] Output [ #2.last_name ] ; #4 = Scan Table [ Students ] Output [ student_id , last_name ] ; #5 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.student_id = #4.student_id ] Distinct [ true ] Output [ #4.last_name ] ; #7 = Except [ #3 , #6 ] Predicate [ #3.last_name = #6.last_name ] Output [ #3.last_name ]")
    , -- c54e9172bd8c8469719531b90d2bcd9a3ae3a106a373164fcaa4f4b968821e42
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f13a210a276fb5976c3336f04458fd9194497a3627777813ef7e4bed4ddb8d7c
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ cars_data ] Predicate [ Year = 1970 ] Output [ Id , Year ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #4.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #1.Maker ]")
    , -- a07879731338a04cef67baf9770bf287adb98fcd9c64d0ac6e36ecd3427e69ad
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- fe5adb59a95ba76edd9fc8f6822e8954695aa539cb3d1facb8be2529f01ddacf
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Package_Option , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Channel , Directed_by ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Channel IS NULL OR #1.id = #2.Channel ] Output [ #1.Package_Option ]")
    , -- e2b8750d45f4e92cca02f5e87e2becaf9a4b4744049c22ccedd4cfd3a3d0dfd7
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ]")
    , -- b89f7b5db1f8857f0713223621e84ae4f40ed97b45e2b2ba79a26641c096d8ed
      (wta1, "#1 = Scan Table [ players ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 3bd79e8079339ca598e74c333c4128f10638b4de9de645b52185fcd23d3115a4
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Predicate [ Course = 'math' ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- fe44aae95327f765fe37a47604e56e4242c7f5a1ebc738c17d59cda92f4e9cc5
      (dogKennels, "#1 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 9fd7819b14bde9ee74ec0e3209b223ce84e293f99d29e2ac8a51f4ac4e6a787c
      (studentTranscriptsTracking, "#1 = Scan Table [ Semesters ] Output [ semester_name , semester_id ] ; #2 = Scan Table [ Student_Enrolment ] Distinct [ true ] Output [ semester_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.semester_id = #1.semester_id ] Output [ #1.semester_name ]")
    , -- 076c9d19590b6ed576e8cbc4b87736164794b7f67abce410318e4a5a36166a83
      (world1, "#1 = Scan Table [ country ] Output [ Name , Continent , LifeExpectancy , Population , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Population , SurfaceArea , LifeExpectancy , Name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ SurfaceArea DESC ] Output [ Population , SurfaceArea , LifeExpectancy , Name ]")
    , -- 819c2643bf90842bf8740422b759e856df9364f70dfae3b568f5dac7506e4c90
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Distinct [ true ] Output [ Location ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Location) AS Count_Dist_Location ]")
    , -- 507830019925b62844542338e9b6778272fc8cc3a8c55222862e45e5cc10eec6
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ]")
    , -- 577492e72abb4721384a009437ef90d0efd51c4d0a2fac6c92e9cceed7781094
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'ppt' ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- f30af95f9ee63fc7e4a5af67b0549b85c2b14a445a84b52ce75454c22eaaed7a
      (car1, "#1 = Scan Table [ car_makers ] Predicate [ FullName = 'american motor company' ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 7d60a9326e8a1da50b5701c2e6673c4f854992058ca200c3a5559c18d5021645
      (orchestra, "#1 = Scan Table [ orchestra ] Predicate [ Major_Record_Format = 'cd' OR Major_Record_Format = 'dvd' ] Output [ Major_Record_Format ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 9904b062c563102b86314357314958e0648753b448df996620cdf9be065e0f0e
      (museumVisit, "#1 = Scan Table [ museum ] Output [ Museum_ID , Name ] ; #2 = Scan Table [ visit ] Output [ Museum_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Museum_ID ] Output [ countstar AS Count_Star , Museum_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Museum_ID = #1.Museum_ID ] Output [ #3.Museum_ID , #1.Name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Museum_ID , Name ]")
    , -- 02c89bd982dfca591b480780bb255fb46d9d7c0a268f6bb76ecdce5f1f7f6bf2
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #2.Course , #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name , #4.Course ]")
    , -- eb81b335df82730a2915851df1bd7d6ce9dd0e5aab61ca14535b1f22398ebb9f
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Conductor_ID , Name ] ; #2 = Scan Table [ orchestra ] Predicate [ Year_of_Founded > 2008.0 ] Output [ Year_of_Founded , Conductor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Conductor_ID = #1.Conductor_ID ] Output [ #1.Name ]")
    , -- 681cf03b6d36068143ee1116a534b9ea3ea9ab0b38428280e350f80987598ba7
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , transcript_id ] ; #2 = Scan Table [ Transcript_Contents ] Output [ transcript_id ] ; #3 = Aggregate [ #2 ] GroupBy [ transcript_id ] Output [ countstar AS Count_Star , transcript_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.transcript_id = #1.transcript_id ] Output [ #1.transcript_date , #3.transcript_id , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ transcript_date , transcript_id ]")
    , -- db21dc13f516c2d21d6b03dd40a463b7e9d28a54dd4951c763ef689c9ac77fb9
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Description = 'presentation' ] Output [ Template_Type_Code , Template_Type_Description ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_Type_Code = #1.Template_Type_Code ] Output [ #2.Template_ID ]")
    , -- f94680095338fe6d4fa0872710695fc16a03ebdefc4828a7282775e6eb1b5a6d
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Count_Star ]")
    , -- 769c4f1348155baa4d093eb503db38362725a9c83d68fe615b476ac3e3c2d803
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ treatment_type_code , cost_of_treatment ] ; #3 = Aggregate [ #2 ] GroupBy [ treatment_type_code ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , treatment_type_code ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.treatment_type_code = #1.treatment_type_code ] Output [ #1.treatment_type_description , #3.Sum_cost_of_treatment ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Sum_cost_of_treatment ASC ] Output [ Sum_cost_of_treatment , treatment_type_description ]")
    , -- 48aba4e97ed55fd23a7b7f378e185c1043acaaacc7cc04191774930eac1a2559
      (tvshow, "#1 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ series_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT series_name) AS Count_Dist_series_name ] ; #3 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ Content ] ; #4 = Aggregate [ #3 ] Output [ COUNT(DISTINCT Content) AS Count_Dist_Content ] ; #5 = Join [ #2 , #4 ] Output [ #4.Count_Dist_Content , #2.Count_Dist_series_name ]")
    , -- a10ef1dc84070e92c63477211ea1738d364aca09cd140fdcb5d8d7685285a26d
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.degree_program_id = #1.degree_program_id ] Output [ #1.degree_summary_name ] ; #4 = Aggregate [ #3 ] GroupBy [ degree_summary_name ] Output [ degree_summary_name , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_summary_name , Count_Star ]")
    , -- 78201a51f6489492d9712ea0074012d00b05eae33689bd9392a73b71b99c588a
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , zip_code ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , dog_id ] ; #3 = Scan Table [ Treatments ] Output [ dog_id , cost_of_treatment ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.dog_id = #2.dog_id ] Output [ #3.cost_of_treatment , #2.owner_id ] ; #5 = Aggregate [ #4 ] GroupBy [ owner_id ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , owner_id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.owner_id = #1.owner_id ] Output [ #1.zip_code , #5.Sum_cost_of_treatment , #1.owner_id ] ; #7 = TopSort [ #6 ] Rows [ 1 ] OrderBy [ Sum_cost_of_treatment DESC ] Output [ Sum_cost_of_treatment , owner_id , zip_code ]")
    , -- 4d65558cfbe559672e157d5e7ec80e6e78aebc27437ce33f926d48eb593f03c9
      (flight2, "#1 = Scan Table [ airports ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 3d42cc6f33bbde3a7435930ec8087870981f004e3da7c98cf437a6de0a7d8d7a
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'ppt' ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 79cef8a73b2fd8b66f165d4c4c9e563cfeea07472ea739d817c32c35983b8c2f
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name ] ; #2 = Scan Table [ Owners ] Output [ first_name ] ; #3 = Union [ #1 , #2 ] Output [ #1.first_name ] ; #4 = Scan Table [ Dogs ] Output [ name ] ; #5 = Except [ #3 , #4 ] Predicate [ #4.name = #3.first_name ] Output [ #3.first_name ]")
    , -- e394ac9df4f6eff3fff54c2cd85d37190b1ae1f4e30dd63e1577150115b277d3
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age , Country , Name ]")
    , -- 5bb4eec216228c8f823b9444d1035d1d7f90937c23381a3a303840923469d256
      (car1, "#1 = Scan Table [ continents ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent , CountryId ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Output [ #2.Continent ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Continent = #1.ContId ] Output [ #1.Continent ] ; #6 = Aggregate [ #5 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ]")
    , -- 71b8e3eee7e7618b7730a3dc215c5d838411a0a424df17b4823a8f1ed6b56062
      (car1, "#1 = Scan Table [ cars_data ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ MIN(Year) AS Min_Year ] ; #3 = Scan Table [ cars_data ] Output [ Id , Year ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #3.Year , #4.Make ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Year = #2.Min_Year ] Output [ #5.Year , #5.Make ]")
    , -- 5f82ac520562e0e693c6f75f18091b5e35fc74ee85c8bff66446e0bc61cdf85c
      (flight2, "#1 = Scan Table [ airports ] Predicate [ AirportName = 'alton' ] Output [ City , AirportName , Country ]")
    , -- 40e1f4c8aa7834d57bb2f331fb09534635a3c5fdb5ad6f142eec15b1f995b7ea
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportName ]")
    , -- a4b73ee60e1ed8de6d08edba00c1d94f1aed84d6660302a5970865956fdbdf1c
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Location ] ; #2 = Aggregate [ #1 ] GroupBy [ Location ] Output [ Location , countstar AS Count_Star ]")
    , -- 4776864cae0889340c0a3b3d4cf577b53714a560aac3a5e0b584b2fad0fede8f
      (dogKennels, "#1 = Scan Table [ Dogs ] Distinct [ true ] Output [ size_code , breed_code ]")
    , -- 41ac9ea02212af7c1d4afef475a1a3e7678709ec843720d39156c36445ceb7ae
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Predicate [ Number_products < 3000 ] Distinct [ true ] Output [ District ] ; #2 = Scan Table [ shop ] Predicate [ Number_products > 10000 ] Distinct [ true ] Output [ District ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.District = #2.District ] Distinct [ true ] Output [ #1.District ]")
    , -- bf9ddbd285a985059dab1d4b5e14d0f1eb5b056a7d8547bf2194f977af1ee913
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Hight_definition_TV = 'yes' ] Output [ Package_Option , series_name , Hight_definition_TV ]")
    , -- 00a3390111217a03d10cdfb556125b947a46a55fc5ea5458e593007a8cfc1702
      (flight2, "#1 = Scan Table [ airports ] Output [ AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.AirportCode = #2.DestAirport OR #1.AirportCode = #2.SourceAirport ] Output [ #1.AirportCode ] ; #4 = Aggregate [ #3 ] GroupBy [ AirportCode ] Output [ countstar AS Count_Star , AirportCode ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Count_Star , AirportCode ]")
    , -- 59be649e519f17773648586a228606126215c8567bd97545d66fc8e90ecb75d5
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Horsepower > 150.0 ] Output [ Horsepower ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- ec3405477794812934b51e5ea9d4aab5a905af1006960ad3d39101b5ccc2a6d4
      (flight2, "#1 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 2914754a1a51a5b100d4ff75aff0952ddcad058096534f9be42de91ed54669db
      (car1, "#1 = Scan Table [ continents ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent ] ; #3 = Aggregate [ #2 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Continent = #1.ContId ] Output [ #1.Continent , #1.ContId , #3.Count_Star ]")
    , -- 16efa1d00b88ef4622bb7345796502ef8e42ddb5fdc95f2e66d3ed8ca53f44cf
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language = 'Spanish' ] Output [ Percentage , CountryCode , Language ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ countstar AS Count_Star , MAX(Percentage) AS Max_Percentage ]")
    , -- 8459b8d82356291d3db2f69ff1945ee3befbb954a1417532e973e93e6b13ad59
      (orchestra, "#1 = Scan Table [ orchestra ] Predicate [ Year_of_Founded < 2003.0 ] Distinct [ true ] Output [ Record_Company ] ; #2 = Scan Table [ orchestra ] Predicate [ Year_of_Founded > 2003.0 ] Distinct [ true ] Output [ Record_Company ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Record_Company = #2.Record_Company ] Distinct [ true ] Output [ #1.Record_Company ]")
    , -- bd6c48013f2fe3554e4971954f587f19ac143f32bfc43bc64107385601892a7f
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Code ] ; #3 = Scan Table [ countrylanguage ] Output [ CountryCode , Language ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.CountryCode = #2.Code ] Output [ #3.Language ] ; #5 = Aggregate [ #4 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #6 = TopSort [ #5 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language , Count_Star ]")
    , -- 01647ae7e0cf6d752409dfd6fdd41d79bc9a878d51fe2a086123887c87b38554
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ country_code , Count_Star ]")
    , -- 5481005a8259bb52b06468461cad920f76cbbd9d0c5d8f0b587715fe6a11b912
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ AVG(weight) AS Avg_weight , PetType ]")
    , -- d99c040d6524f2a05b4ba4f4ffe1aebca0489bba1ed41e3d2f14264a23dcaab2
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ AVG(age) AS Avg_age ] ; #3 = Scan Table [ Dogs ] Output [ age ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.age < #2.Avg_age ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 5e6dcd4f1c2e3953b79fdcda1cbd89c2bb9db999951cce84429b3be188edd3ba
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ AVG(age) AS Avg_age ] ; #3 = Scan Table [ Dogs ] Output [ age ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.age < #2.Avg_age ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 6b6e1c6478e1e38f5482e86be34aee7b06e9b39a193ea87dfdd42bee7e5d3092
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name , professional_id ] ; #2 = Scan Table [ Treatments ] Output [ professional_id , date_of_treatment ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #2.date_of_treatment , #1.first_name ]")
    , -- 7b30574d1ca66d7665e969229dd704a800f08994530b06fe62e3eb4fb57a6ab5
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ]")
    , -- 542cbe30d5c93dbde2e5d22089c6766789949c24e1098ec81ef7fb28853ae1ff
      (employeeHireEvaluation, "#1 = Scan Table [ evaluation ] Output [ Bonus ] ; #2 = Aggregate [ #1 ] Output [ SUM(Bonus) AS Sum_Bonus ]")
    , -- 7677207c536eff1811ff521af6a0b89899e3c67b81b8c0af18b1a7ded10277b8
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'cv' ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- de71b4f79c1ad3c71f523f6436acef9f69f5ca098b441f5055416ac23bf9bb75
      (concertSinger, "#1 = Scan Table [ singer ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 50b5150d0be2fb25fb3c75ba5f9efedab022b25ddecc1718f39ef2cd8d319782
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'chinese' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Continent ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 532d1e15f99ebc54005a555098c494296d44412ee0fd0a417574833f09b82c13
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , FullName ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ Id , FullName ]")
    , -- ac7e3e3adfb4715eccfa332d41fb30d7348936c72be0b770bd95702e9377cd8e
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , MPG ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.MPG , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ MPG DESC ] Output [ MPG , Model ]")
    , -- 50dd67121490bcdaef67b0fa8e7b7c482ff5154f3c6dd54446ce3ba29ec3e40f
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Nationality ]")
    , -- 0ab456f2fbc7de30a54a57287745b5f8e8c5e3b734a5144f44b1265e347fc73e
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Abbreviation , Country , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline , #1.Abbreviation , #1.Country ] ; #4 = Aggregate [ #3 ] GroupBy [ Abbreviation , Country , Airline ] Output [ countstar AS Count_Star , Abbreviation , Country ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Abbreviation , Country , Count_Star ]")
    , -- 7094eb8f4f43e802578dfb2597cdb2cf41222e5ebbf4ff0686bba8aa79a0b702
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade = 10 ] Output [ grade , name ]")
    , -- 86c55881b46a5a574126c33dc389f48f0015abfa067f0bf84d197424dcfeab3f
      (world1, "#1 = Scan Table [ country ] Output [ Continent , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' OR Continent = 'europe' ] Output [ SurfaceArea ] ; #3 = Aggregate [ #2 ] Output [ SUM(SurfaceArea) AS Sum_SurfaceArea ]")
    , -- 29ca0628d7688ba66867d6b2b9c69262aed688372b572e9bfb32690f4dfb508c
      (orchestra, "#1 = Scan Table [ conductor ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- ca275588e6a1888e3ee9ac925a1f679efdc98638946b70168e6eb08bd0b42247
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Distinct [ true ] Output [ #1.course_name ]")
    , -- efc2abfda824f8537f7433476f8c634f1afe5c44f1e47895e62966073e995993
      (battleDeath, "#1 = Scan Table [ battle ] Output [ id ] ; #2 = Scan Table [ ship ] Predicate [ tonnage = '225' ] Output [ tonnage , lost_in_battle ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.lost_in_battle IS NULL OR #1.id = #2.lost_in_battle ] Output [ #1.id ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- adefbd4e9ba07e8bb82a8588229dab1e6e1b09b92df70ea6bd801b28f5656147
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #2 = Scan Table [ cars_data ] Predicate [ Cylinders = 3 ] Output [ Id , Horsepower , Cylinders ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Make ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Make ]")
    , -- b6dbcf35e637466fb878964b2ca6759c7d8c27b687b8e18916214f47b4fb9708
      (world1, "#1 = Scan Table [ country ] Output [ Continent , LifeExpectancy , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ LifeExpectancy , Name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ LifeExpectancy ASC ] Output [ LifeExpectancy , Name ]")
    , -- cce310591b81b5c42d2388e7d5f7462d4d15db56b4ec47479ff05f4b43ad2cfa
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Version_Number ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , MIN(Version_Number) AS Min_Version_Number ]")
    , -- 95a64f969855e9817719f0ec18278eba85b5e86a4c520343b59cce05a0f425e1
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country ] ; #2 = Aggregate [ #1 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Country , Count_Star ]")
    , -- 179ac3c6aa019713305f70d101ac1fc9a2c0fb2b8dafbb0ee2a5290079d80fc0
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_departed , date_arrived ]")
    , -- bcc64c0bb22e3f9f4d8fd691b32c0951929c845558050f560d0cb8ec9d35aa9f
      (orchestra, "#1 = Scan Table [ performance ] Predicate [ Type <> 'live final' ] Output [ Type , Share ] ; #2 = Aggregate [ #1 ] Output [ MIN(Share) AS Min_Share , MAX(Share) AS Max_Share ]")
    , -- 9d0778eb0707002333a0bf777d868b7a14384e4a6da008beda575d4c56628f95
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Average , Capacity ] ; #2 = Aggregate [ #1 ] GroupBy [ Average ] Output [ Average , MAX(Capacity) AS Max_Capacity ]")
    , -- d48e7fe6972cb8e21a3c6394d53980bdf7e37fc28a78f91f9fb7230c24136dae
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , birth_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ birth_date ASC ] Output [ country_code , first_name , birth_date ]")
    , -- 60381fe18778956685f148ed16d9626f22531748406bdbd7c0c99be5af63cc29
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ]")
    , -- caaf4a80c883edab18f4e7e85da3f3348e643534f21bcb95b97ba3db14647a8d
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Age > 20 ] Distinct [ true ] Output [ Country ]")
    , -- b949490e009a7f50dfe5876c63c8f31a252c1e327bee7cf800057e949a391ee3
      (singer, "#1 = Scan Table [ singer ] Output [ Birth_Year , Citizenship ]")
    , -- 0304ccac6215bdeb68fee72019cb089b06fd44940d8a52dd0a70443824e39952
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Predicate [ Earnings > 300000.0 ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name ]")
    , -- 3124e28ac1a7fe690afecd460ac8ece90d118c90179e403c6d3922793b87a58c
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- eda66e735c51570820c08ac218e6aa49fb6d80f3b459827f5ebb9b608188d08f
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ GovernmentForm ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8efd5f524fe11882fd054fbe9338eead2cd3fe81797f3704ed122a780f499367
      (flight2, "#1 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , FlightNo ]")
    , -- 9613549d75cadf3aaf9e382df3277d0bf72df467f14c96d5783c19c5479f5f9b
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ #1.Name ] ; #5 = Scan Table [ country ] Output [ Code , Name ] ; #6 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' ] Output [ IsOfficial , CountryCode , Language ] ; #7 = Filter [ #6 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #8 = Join [ #5 , #7 ] Predicate [ #7.CountryCode = #5.Code ] Output [ #5.Name ] ; #9 = Union [ #4 , #8 ] Output [ #4.Name ]")
    , -- 47842e1ee406532450416aa3a3b74cc576643fbc9dfe9d4bffca7d9d676ecccf
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Conductor_ID , Name ] ; #2 = Scan Table [ orchestra ] Output [ Orchestra , Conductor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Conductor_ID = #1.Conductor_ID ] Output [ #1.Name , #2.Orchestra ]")
    , -- 73af14f9e8271c97b343c331de6a984ba197bd3ba69a66b4418187b22f316392
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Net_Worth_Millions DESC ] Output [ Net_Worth_Millions , Name ]")
    , -- d75c9b7a13adce151a16d7cca833ab0cb99145f5a35857c3008c4f22ddb3bf44
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ CountryCode ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #4 = Except [ #2 , #3 ] Predicate [ #2.CountryCode = #3.CountryCode ] Output [ #2.CountryCode ]")
    , -- 8e3e0c5cc6890da0f2ac1becf06e642b0b35b4f63f9c20289406a40c69a77641
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Population ] ; #3 = Aggregate [ #2 ] Output [ MAX(Population) AS Max_Population ] ; #4 = Scan Table [ country ] Output [ Continent , Population , Name ] ; #5 = Filter [ #4 ] Predicate [ Continent = 'africa' ] Output [ Population , Name ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.Population < #3.Max_Population ] Output [ #5.Name ]")
    , -- 862cf18a84d6b570717481f1cee798370bd820600fed8d9fb547212392fc97d1
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ Final_Table_Made , People_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name , #2.Final_Table_Made ]")
    , -- 8f8dd95299a63e06a826543a636d943555a7b97b7b1a3fae24cebc48ce2f8de4
      (studentTranscriptsTracking, "#1 = Scan Table [ Semesters ] Output [ semester_name , semester_id ] ; #2 = Scan Table [ Student_Enrolment ] Distinct [ true ] Output [ semester_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.semester_id = #1.semester_id ] Output [ #1.semester_name ]")
    , -- 36c7b520f8030b3154a34e0448f53c05b97574743e8f106665ad05142e78acc2
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Weight >= 3000 AND Weight <= 4000 ] Distinct [ true ] Output [ Year ]")
    , -- 2e4abbe3322902bb4a641597f938f81afeaba7aa81b1943b46b40b6db2d0f182
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Predicate [ Cylinders = 4 ] Output [ Id , Horsepower , Cylinders ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Model ]")
    , -- 08b917ef83c5cde81cdece7e98cfef78e82f1bd17c0dc8b77e8759f9fa88485a
      (wta1, "#1 = Scan Table [ matches ] Predicate [ tourney_name = 'wta championships' AND winner_hand = 'l' ] Distinct [ true ] Output [ winner_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT winner_name) AS Count_Dist_winner_name ]")
    , -- b3a92bd00df018276c532ac506f498a4aab18fc78bd5e5c233593b3d0919d6e3
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 560524f03cef0b0c2248599274a33d9621b0f01f721c71d46382408e6c0e6f56
      (wta1, "#1 = Scan Table [ matches ] Predicate [ year = 2013 OR year = 2016 ] Output [ year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8501b8421d3703c0f326d035b6a98713416838884d95dce6d6d6f9e9785e9513
      (world1, "#1 = Scan Table [ country ] Output [ HeadOfState , Population , SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ SurfaceArea DESC ] Output [ HeadOfState , Population , SurfaceArea , Name ]")
    , -- 6606a29dd2b7f2d93ea8e171a867970cf5da5496ddb77658dc04d73678da4f44
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ professional_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- d7fc07e68990b36dc06d1e0618a67411b9ca8d0cdbb2507c1994df52cec72a11
      (world1, "#1 = Scan Table [ country ] Output [ HeadOfState , Population , SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ SurfaceArea DESC ] Output [ HeadOfState , Population , SurfaceArea , Name ]")
    , -- b8e73cdb60d918375ac05b729ae481ecc9d1efb4140ab54400235c695a03b096
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Country = 'usa' ] Output [ Country ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 5916846cb35aee32cb93f7b29358c8341b8cd43935cd8392e41b0cc4bd7f0183
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Package_Option , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Channel , Directed_by ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Channel IS NULL OR #1.id = #2.Channel ] Output [ #1.Package_Option ]")
    , -- 2ccd32ac0d180b828be858b0bf0735ce6f91ee1507751a8ac74b2614fb9dda0e
      (battleDeath, "#1 = Scan Table [ ship ] Output [ tonnage , name ]")
    , -- 8f5134a55bcc35aa15116970a07f380e26620ed0e44157fb4a7a5afdeea9b368
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Major_Record_Format ] ; #2 = Aggregate [ #1 ] GroupBy [ Major_Record_Format ] Output [ countstar AS Count_Star , Major_Record_Format ]")
    , -- 4a26693e8b64b388a869f74c12041375fe55f7851e8138794063998f3b04f9f3
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Output [ Population ] ; #3 = Aggregate [ #2 ] Output [ MIN(Population) AS Min_Population ] ; #4 = Scan Table [ country ] Output [ Continent , Population , Name ] ; #5 = Filter [ #4 ] Predicate [ Continent = 'asia' ] Output [ Population , Name ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.Population > #3.Min_Population ] Output [ #5.Name ]")
    , -- e76fdac7b3d43bfbb98970b3914f8afa9705c4d943431cbb16e627f0c60ee527
      (tvshow, "#1 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Air_Date , Episode ]")
    , -- 3020ddb5623bc3540cb9939da3f22bd066bc0e6679425deaf65e0faadfecbd31
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ]")
    , -- c3c0c78ed6a2f30afcfd3f309300640fd3f03dc8619ee2ab43d1b39f24566e90
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Distinct [ true ] Output [ #1.course_name ]")
    , -- 0617e10465be92424cb8e6ad6c98682473571d33e1ce56d7ccc259123ce41d1d
      (flight2, "#1 = Scan Table [ airports ] Predicate [ AirportCode = 'ako' ] Output [ AirportName , AirportCode ]")
    , -- 664f0c6f067262d02049ca69c3f9f7726e6d086c3325b29eca9eb11398448854
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade > 5 ] Output [ grade , name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ name ]")
    , -- 3e0018e4a77c7beccb7a8bd929b7232c2651929030a3b338803d131a009889a5
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , FlightNo ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ #2.FlightNo ]")
    , -- 57a37b0501428222f4c8034672ee226bc3ec6d001972e5e1b7a7218189e3276c
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Sections ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Output [ #1.course_id , #1.course_name ] ; #4 = Aggregate [ #3 ] GroupBy [ course_id ] Output [ course_id , course_name , countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star <= 2 ] Output [ course_id , course_name ]")
    , -- d4c083cb95db6dcb9ca733446fc4c7c4a43e2b085ee182b10d387d7b8d4694d6
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , zip_code ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , dog_id ] ; #3 = Scan Table [ Treatments ] Output [ dog_id , cost_of_treatment ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.dog_id = #2.dog_id ] Output [ #3.cost_of_treatment , #2.owner_id ] ; #5 = Aggregate [ #4 ] GroupBy [ owner_id ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , owner_id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.owner_id = #1.owner_id ] Output [ #1.zip_code , #5.Sum_cost_of_treatment , #1.owner_id ] ; #7 = TopSort [ #6 ] Rows [ 1 ] OrderBy [ Sum_cost_of_treatment DESC ] Output [ Sum_cost_of_treatment , owner_id , zip_code ]")
    , -- 236dcef9e2b84f096ed08b1920b85a8df68af104b942aa599e0635cdb1e04178
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , name ]")
    , -- 76ef862e3c511c50ec1ff363f7b90eadbad4ccac85a6b9d3d4cf4b027b49a5d1
      (network1, "#1 = Scan Table [ Friend ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id ] ; #3 = Scan Table [ Likes ] Distinct [ true ] Output [ liked_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.liked_id = #2.student_id ] Output [ #2.student_id ]")
    , -- c64e0faa9e89897971fbbb82dd7381df2d0f37bc67ff227a876b71f041eb036f
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Language <> 'english' ] Output [ Pixel_aspect_ratio_PAR , Country , Language ]")
    , -- 92e4d4fbc8091177b07c249b6d37d5ae85675b91bec3b9f0ad37339fbf223c48
      (pets1, "#1 = Scan Table [ Student ] Predicate [ Age > 20 ] Output [ Age , StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 680ba48e48448ad6bc596a4098af77b8f44684a2676f89ea8faf15035aa7e516
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Rating , Episode ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Rating DESC ] Output [ Rating , Episode ]")
    , -- 066534f971100acbd4ecf9d5a5ec2ac78b6c117238983af48d09b97b812e2236
      (world1, "#1 = Scan Table [ city ] Predicate [ Population >= 160000 AND Population <= 900000 ] Output [ Population , Name ]")
    , -- 42c58734b7b2117d31f7c8ae5a8fcb3ee80e9712f2b48d534c7896cc0edf9681
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Language = 'english' ] Output [ Language ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 3e300a389805c802468ed78e0375595f808905a65d3a714dca27a4605afb5dde
      (flight2, "#1 = Scan Table [ airports ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6e07e3442e971836451c6b5d8270702979d958da915172bf10e273487e3e254d
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Predicate [ first_name = 'timmothy' AND last_name = 'ward' ] Output [ first_name , cell_mobile_number , last_name ]")
    , -- 9b0b35fe9d58a109152308667dfc887aad2df9802bb5be1a0a5a212734da450d
      (world1, "#1 = Scan Table [ country ] Predicate [ Region = 'caribbean' ] Output [ SurfaceArea , Region ] ; #2 = Aggregate [ #1 ] Output [ SUM(SurfaceArea) AS Sum_SurfaceArea ]")
    , -- 044f714d672d32a325bbfb225b0075e090856f30f465f5e162edb51e8f2525c0
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ Final_Table_Made , People_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name , #2.Final_Table_Made ]")
    , -- 7d87dde5ac17ed632e07ab362831b1b48cbfcfa82d40bf5164a4590ca7894143
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language , Count_Star ]")
    , -- ef4c1b5e130aa488efbf131f5a392c01c95c1e9be40ff4af6960a1d9f3e744a0
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name , professional_id , role_code ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.professional_id , #1.role_code , #3.Count_Star , #1.first_name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ first_name , professional_id , role_code ]")
    , -- 4b2ac205277d7c5884472a73b7c2e9091542447d1c927af072dc0edc0bac2b1e
      (dogKennels, "#1 = Scan Table [ Dogs ] Distinct [ true ] Output [ size_code , breed_code ]")
    , -- e2a8016205c76a65594123511298f5a3b3c80cdcda2a34b2d5958b3b76357407
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Predicate [ department_name = 'engineer' ] Output [ department_name , department_id ] ; #2 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.department_id = #1.department_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- fdfea30a058eb1515bcf094ea6132c66bcd901c2ecc1be5f888c488c81485f8e
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #4 = Scan Table [ country ] Output [ Code , Name ] ; #5 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' ] Output [ CountryCode , Language ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.CountryCode = #4.Code ] Distinct [ true ] Output [ #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ 1 AS One ] ; #8 = Aggregate [ #7 ] Output [ countstar AS Count_Star ]")
    , -- dbbfb1513b82391695d42babdf470c3cde68b3f2eb3e972fc216e917ea6f1c48
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ other_student_details ]")
    , -- c7b79dc46ba1d29aaab498484888e38ee860e274eca99a6919829c054daf7d81
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_products ] ; #2 = Aggregate [ #1 ] Output [ AVG(Number_products) AS Avg_Number_products ] ; #3 = Scan Table [ shop ] Output [ Number_products , Name ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Number_products > #2.Avg_Number_products ] Output [ #3.Name ]")
    , -- a063d955c79fd05ec31becccdbd310b4bc3d29e965130d1e7c2b89b7f0e3e1b2
      (world1, "#1 = Scan Table [ country ] Output [ GNP , Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ GNP , Population ] ; #3 = Aggregate [ #2 ] Output [ MAX(GNP) AS Max_GNP , SUM(Population) AS Sum_Population ]")
    , -- 12ced80a38250c5c815da4230bfbddaf6b6310ee3e3c49b50a0747f812fdd80c
      (orchestra, "#1 = Scan Table [ conductor ] Distinct [ true ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Nationality) AS Count_Dist_Nationality ]")
    , -- cb384f0755ee64aadab7999c2dfdc55442be5549699fa4be5be6b2bc0a111457
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ age , owner_id ] ; #3 = Filter [ #2 ] Predicate [ age IS NOT NULL ] Output [ age , owner_id ] ; #4 = Top [ #3 ] Rows [ 1 ] Output [ owner_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.owner_id = #1.owner_id ] Output [ #1.last_name ]")
    , -- c61132133c0884369b3656e64742fefba5bafb269a5d2e9604eed2bd4d7792f7
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id , line_2 , line_1 ] ; #2 = Scan Table [ Students ] Output [ current_address_id ] ; #3 = Aggregate [ #2 ] GroupBy [ current_address_id ] Output [ countstar AS Count_Star , current_address_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.current_address_id = #1.address_id ] Output [ #1.line_2 , #1.address_id , #3.Count_Star , #1.line_1 ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ address_id , line_2 , line_1 , Count_Star ]")
    , -- a18b1ec289665e858ed449e97f2baf04c419f3a8ecbc84d40b899776cc8686ec
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #2.name , #1.first_name ]")
    , -- 1cc43d0dd4258523da70628365e645be9219fddc3472704ea11ef01afdc90b4d
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryName , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , CountryName ]")
    , -- 24951b727022323b841fa4837a8f3c39e5b669a8458b03cfc4f009b4d71d98b1
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Predicate [ Document_Name = 'data base' ] Output [ Document_Name , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ]")
    , -- 21a326c50fe17acbb83d3c76d8ef9b391937207f1540f33c05c37f28ca6a7b67
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ]")
    , -- a007a938175d709e14791598607b8aeb8b640dd14dd48f3e56eb97824e0acacd
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ]")
    , -- bc01be7fce4867f664d6814ae240bfc097023a0d8bcc6196449757b046ef01a3
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Title , Directed_by ]")
    , -- ad9d991e1f140de0bcbb72b639b2b2c55ef989561d953b6b65c0c60098413bba
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_code , breed_name ] ; #2 = Scan Table [ Dogs ] Output [ breed_code ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #1.breed_name ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_name ] Output [ countstar AS Count_Star , breed_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ breed_name , Count_Star ]")
    , -- 95b58705014ea9cafe1d2b2967eceea55b90e10025390a1d8c79348f47380569
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ treatment_type_code , cost_of_treatment ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.treatment_type_code = #1.treatment_type_code ] Output [ #2.cost_of_treatment , #1.treatment_type_description ]")
    , -- cf86a2583a04d0373d4ca4b2b0464985067d246fde2c58d8e2de54134a4528c4
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Year = 1980 ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6526137048ae8dec7f67b1d156501fe03e65412e05ce2362239d91b62eb64ae3
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Predicate [ Sales > 300000.0 ] Output [ Singer_ID , Sales ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Distinct [ true ] Output [ #1.Name ]")
    , -- 57ea74cc58d20b8ed0db92d1be3dd10e1fe48807fd6ec9ac1060e4fd1c7553be
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ other_student_details ]")
    , -- 524c108e3bf0acdbbb82209403f005db8b11506bdae75cbd4850a8235c714cf5
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ Name , ID ] ; #2 = Scan Table [ museum ] Predicate [ Open_Year < 2009 ] Output [ Open_Year , Museum_ID ] ; #3 = Scan Table [ visit ] Output [ Museum_ID , visitor_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Museum_ID = #2.Museum_ID ] Output [ #3.visitor_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.visitor_ID = #1.ID ] Distinct [ true ] Output [ #1.Name ] ; #6 = Scan Table [ visitor ] Output [ Name , ID ] ; #7 = Scan Table [ museum ] Predicate [ Open_Year > 2011 ] Output [ Open_Year , Museum_ID ] ; #8 = Scan Table [ visit ] Output [ Museum_ID , visitor_ID ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.Museum_ID = #7.Museum_ID ] Output [ #8.visitor_ID ] ; #10 = Join [ #6 , #9 ] Predicate [ #9.visitor_ID = #6.ID ] Distinct [ true ] Output [ #6.Name ] ; #11 = Join [ #5 , #10 ] Predicate [ #5.Name = #10.Name ] Distinct [ true ] Output [ #5.Name ]")
    , -- 08dc2bd47d43756549ebaa3fc4b93ef053b8ccb78cf36090fb8b63aa8b29c96f
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Weight ] ; #3 = Aggregate [ #2 ] Output [ AVG(Weight) AS Avg_Weight ] ; #4 = Scan Table [ cars_data ] Output [ Id , Weight ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Weight < #3.Avg_Weight ] Output [ #4.Id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.Id = #1.MakeId ] Output [ #1.Model ]")
    , -- 587619e0bf6dca2cc715654f4d71bcfd092fea72301454feec993fd1010054e2
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id , #2.Maker ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , FullName ]")
    , -- b622b7727c2f59b8d9162a06af9d125c7b91f2b7cad4d9ba976a52a14dcbd86b
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age ] ; #3 = Scan Table [ singer ] Output [ Age , Song_Name ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Age > #2.Avg_Age ] Output [ #3.Song_Name ]")
    , -- 727d962436aa6dab57de5314949a51a9e99124c9086e4e950e58f7b3b425a9d1
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Distinct [ true ] Output [ #1.Airline ] ; #4 = Scan Table [ airlines ] Output [ uid , Airline ] ; #5 = Scan Table [ flights ] Predicate [ SourceAirport = 'cvo' ] Output [ SourceAirport , Airline ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Airline = #4.uid ] Distinct [ true ] Output [ #4.Airline ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Airline = #6.Airline ] Distinct [ true ] Output [ #3.Airline ]")
    , -- 3c6d87c1ae7bbff92689d133bff4b619478545457a0610d9ed0e01a8819082c3
      (tvshow, "#1 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Air_Date , Episode ]")
    , -- 4611a9d09e6d3dd627d95b6c315e97d00104bed81aa905e8c242ca35c0671678
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Hometown , Count_Star ]")
    , -- 139fe90e20205c170d6167b71f0e43f1bc29925a7d457c55605f62f830b59678
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_rank ] ; #2 = Aggregate [ #1 ] Output [ AVG(winner_rank) AS Avg_winner_rank ]")
    , -- e8085d6ad1c2965658080e2c0ebc3816ca37ec522dd5cad2606e9607878526d6
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Count_Star , Name ]")
    , -- 6cb24d73bd9d6854c0c145accf850e49e98a77696072a3e9f52e58a90d56a1ae
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Production_code , Channel , Original_air_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Original_air_date DESC ] Output [ Production_code , Channel , Original_air_date ]")
    , -- facbfa3fe4d0040431b7fdd4be746af38a6d427ca8d70f509c31b82ad1ae117b
      (car1, "#1 = Scan Table [ continents ] Predicate [ Continent = 'europe' ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent , CountryId , CountryName ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Output [ #2.Continent , #2.CountryName ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Continent = #1.ContId ] Output [ #4.CountryName ] ; #6 = Aggregate [ #5 ] GroupBy [ CountryName ] Output [ countstar AS Count_Star , CountryName ] ; #7 = Filter [ #6 ] Predicate [ Count_Star >= 3 ] Output [ CountryName ]")
    , -- b8e08896d0063efdc88fa6a6bffae66141b6086c3f792920f68aeffd8998b42f
      (car1, "#1 = Scan Table [ countries ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- d3f58202801fed06a5f97b5ad10641054333545fa7d15effc5c7fcc10bd721cb
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Count_Star ]")
    , -- 5f4c7f4307ad324c6bd8b44a5c91d45d8fa3f854c9b23f17d5fae490193e1363
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ Country , Airline ]")
    , -- d52b2fe734438314b9c3e2d3f0bd85983be6b638f7cdd57539fce25c52bfaa38
      (orchestra, "#1 = Scan Table [ conductor ] Predicate [ Nationality <> 'usa' ] Output [ Nationality , Name ]")
    , -- e7fcce4afab160c8a195796f3ea815d73d529587aa5c18bb9f11330e7cef0a2e
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f626b9a2929fc139061b844dbf890d7ba521f6aa73d94c8973a3d0c6049a9e93
      (dogKennels, "#1 = Scan Table [ Owners ] Distinct [ true ] Output [ state ] ; #2 = Scan Table [ Professionals ] Distinct [ true ] Output [ state ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.state = #1.state ] Distinct [ true ] Output [ #1.state ]")
    , -- 42e2d31ab3ab8660506a198d447bbeb3fe7a87e3dd1ce9a1ef067e3a6612d09f
      (world1, "#1 = Scan Table [ country ] Predicate [ Region = 'caribbean' ] Output [ SurfaceArea , Region ] ; #2 = Aggregate [ #1 ] Output [ SUM(SurfaceArea) AS Sum_SurfaceArea ]")
    , -- 5a8d71c970603ffa83f98d138980d8fe30589cc89224720daea8e4acd0e86daa
      (voter1, "#1 = Scan Table [ contestants ] Output [ contestant_name ] ; #2 = Filter [ #1 ] Predicate [ contestant_name <> 'jessie alloway' ] Output [ contestant_name ]")
    , -- b23e766b20d801d1a7c381585433382250fd7b37aeabd1fa122e67c8d8381468
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #4 = Scan Table [ country ] Output [ Code , Name ] ; #5 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' ] Output [ CountryCode , Language ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.CountryCode = #4.Code ] Distinct [ true ] Output [ #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ 1 AS One ] ; #8 = Aggregate [ #7 ] Output [ countstar AS Count_Star ]")
    , -- 525bacec227d0a51200bf17117551ede5163d4d834a2d0362f0855cbea4248ee
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 4 ] Output [ grade ]")
    , -- 877a21ee7d3418d9490cef1dc4f37236ea50bc68c12059a9466e5e0e862ca059
      (flight2, "#1 = Scan Table [ airports ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ #1.City ] ; #4 = Aggregate [ #3 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ City , Count_Star ]")
    , -- d4a04c0e1753c6236ee149512841790fd345f9394462bbf66a484f68764d52ee
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Year = 1980 ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 1dd789dce8dca1a681e95be275697f6194aebfedc41b85f2d3c370144d719682
      (car1, "#1 = Scan Table [ continents ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent , CountryId ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Output [ #2.Continent ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Continent = #1.ContId ] Output [ #1.Continent ] ; #6 = Aggregate [ #5 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ]")
    , -- 1b35f7d7b149e16fedff1f5ae56a8bb5a21a6a4e93ab8f12af0f265c757d44bd
      (battleDeath, "#1 = Scan Table [ death ] Predicate [ note like '% east %' ] Output [ note ]")
    , -- 8532df23cc7ba7610e55c027c11135e66dc3952524392a8ea9873a347c0e18b8
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Major ] ; #2 = Scan Table [ Student ] Output [ StuID ] ; #3 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #4 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.PetID = #3.PetID ] Output [ #4.StuID ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.StuID = #2.StuID ] Output [ #2.StuID ] ; #7 = Except [ #1 , #6 ] Predicate [ #1.StuID = #6.StuID ] Output [ #1.Age , #1.Major ]")
    , -- fb9f62e205b9bc6880b700da1dceb69b1975fb77e0c9ffce400ce0446e38b582
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #3 = Scan Table [ flights ] Output [ DestAirport , Airline ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Airline = #2.uid ] Output [ #3.DestAirport ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- df0d5aca30e690984137713a6b519a67f62563e44b1d3e5c69ca9b4155364f3b
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company , Year_of_Founded ]")
    , -- ec2e71aef485eb1901917a50f7e013ff97e143dfd5f84f5c8c6c198f9a69106c
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = Filter [ #4 ] Predicate [ Count_Star < 200 ] Output [ Airline ]")
    , -- 12f83d872b4996b26a5511d6910db085bcd48e6656dcaef27eb62b3424a06ca9
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Predicate [ first_name = 'timmothy' AND last_name = 'ward' ] Output [ first_name , cell_mobile_number , last_name ]")
    , -- 02ea3ce3c1ca33852d94e1ec67b4c4456820afff93824fb3d341ce5c6c667d45
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'brazil' ] Output [ Name , LifeExpectancy , Population ]")
    , -- fc8eb2a4b3514db63e9649bd5c29860d9397dcfdb5806eefd7e7f601c363bf28
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ size_code , owner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.last_name , #2.size_code , #1.first_name ]")
    , -- 8dd28dfa3877846461c9ca5ff24f1cf529cd5aa35599c46a87fbe88ad5a40e83
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Distinct [ true ] Output [ department_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f0a3396077268cb93b9b22bee78d31feaf8e636a88216d5d2f568ffd491ea915
      (wta1, "#1 = Scan Table [ matches ] Output [ tourney_name ] ; #2 = Aggregate [ #1 ] GroupBy [ tourney_name ] Output [ countstar AS Count_Star , tourney_name ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 10 ] Output [ tourney_name ]")
    , -- c642fd4df84252e3f94cc6a8622ebd176aac937469bde1ca03f02bb88852b44a
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 11f48bff71b58facc88ca7563664da98e0dda72f64e9130e8c18ead0c00c7bc8
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ weight > 10.0 ] Output [ weight ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f6382cc791510b0b5267aa6fe2219f8af8fa14534798187ff413f54375b1333f
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Conductor_ID , Name ] ; #2 = Scan Table [ orchestra ] Predicate [ Year_of_Founded > 2008.0 ] Output [ Year_of_Founded , Conductor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Conductor_ID = #1.Conductor_ID ] Output [ #1.Name ]")
    , -- 68c96d827202512a504df23f6ab033cb7b1ac9782afc82257aeab24e8c645959
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ Percentage , CountryCode , Language ]")
    , -- ead8406fcf8f5ac508a3fa2fee7f4eadfc597b2934367ddaa29a95d3b2a7a0ab
      (world1, "#1 = Scan Table [ country ] Predicate [ Region = 'central africa' ] Output [ LifeExpectancy , Region ] ; #2 = Aggregate [ #1 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 0b31c5a9abc4e7a1d92494ccca165c2c92d1134087b6c066d1b3ce747a13c3f7
      (network1, "#1 = Scan Table [ Friend ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id ] ; #3 = Scan Table [ Likes ] Distinct [ true ] Output [ liked_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.liked_id = #2.student_id ] Output [ #2.student_id ]")
    , -- e2aacdecf6d3b52d1802827572ef278aa2c5f3d76b5c6d26fcae103c47a8f0f2
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ email_address , cell_number , home_phone ]")
    , -- 0e930a583ef614f6f0b41fb786e062d289fc26ba0edd412723f27bf935248a70
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Fname ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Age , #1.Fname ]")
    , -- d22f2ff3f365ceb1b3d8479abfc5a1b892b0c5d4f31164f40f8a348e01319bb4
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Distinct [ true ] Output [ Template_Type_Code ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Scan Table [ Documents ] Output [ Template_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Template_ID = #2.Template_ID ] Distinct [ true ] Output [ #2.Template_Type_Code ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Template_Type_Code = #4.Template_Type_Code ] Output [ #1.Template_Type_Code ]")
    , -- 26ba285d395198118d592f466d811b5cfb823cb3e3c6b816162f719160149536
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ]")
    , -- b3fbd3fffe1bdb198cce71e819e0cf49319e836a0ded36d695ce29110d2b43d3
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Document_ID = #1.Document_ID ] Output [ #1.Document_Name , #3.Count_Star , #3.Document_ID ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Document_Name , Document_ID , Count_Star ]")
    , -- ad21629f0a4e48341926c3e116c4f3ae3e68f41715b9f118146b1b81010b5be1
      (car1, "#1 = Scan Table [ cars_data ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ MIN(Year) AS Min_Year ] ; #3 = Scan Table [ cars_data ] Output [ Id , Year ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #3.Year , #4.Make ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Year = #2.Min_Year ] Output [ #5.Year , #5.Make ]")
    , -- 84829bc37e43487777aad24bbb1d364ae6a732e03b5d67e19ee1a9885b5ed33d
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ FlightNo , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #2.FlightNo ]")
    , -- 5d72b16fa2cfb69617732597bc76509ba7d67eb30a250fc04d538e1c037127ec
      (flight2, "#1 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6e5a3955c039c7de8941e2b20560eb004bf6273531145bbe4f9433d229b66a37
      (wta1, "#1 = Scan Table [ players ] Output [ birth_date , first_name , last_name ]")
    , -- 3305381ed75e65f12ec11aaaaf8facba1833f5626c1485c860de2fda47f7085d
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade = 9 OR grade = 10 ] Output [ grade ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- fad45b9bc7573cd69e8c13a9273a0663dd75d1bbfa334582e5a7ec673bf88e6d
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Abbreviation = 'ual' ] Output [ Abbreviation , Airline ]")
    , -- b7ce7e96288841eb3415b871eb6a39d8aadabecb1b37a15b91b8309111d50ed1
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 2eae79665e670663f892b02b5ab203781851af06ec08b956ad48104a9ff70be6
      (realEstateProperties, "#1 = Scan Table [ Ref_Feature_Types ] Output [ feature_type_name , feature_type_code ] ; #2 = Scan Table [ Other_Available_Features ] Predicate [ feature_name = 'aircon' ] Output [ feature_name , feature_type_code ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.feature_type_code = #1.feature_type_code ] Output [ #1.feature_type_name ]")
    , -- 58b54f5a3d2293d6e55a40e44757181a2c3aed9fb41e5bb4961202045ca48c6e
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Hometown ]")
    , -- fd82a9f09b508e811cd8d7220707f1309008b4ff5a1aa9ad7873e7b2d54c7195
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ]")
    , -- ceb36e3b14327b223ca847535d4c11f45241bc16d511bf03380079252a63b090
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportName ]")
    , -- a1e86640236a193701c725b90a1521cb34923dc534777912bbdc11ee29853b4b
      (car1, "#1 = Scan Table [ cars_data ] Output [ Id , Cylinders , Accelerate ] ; #2 = Scan Table [ car_names ] Predicate [ Model = 'volvo' ] Output [ MakeId , Model ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.MakeId = #1.Id ] Output [ #1.Accelerate , #1.Cylinders ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Accelerate ASC ] Output [ Accelerate , Cylinders ]")
    , -- c0c3b1cbaa2da81a562a00b83e42f0c9667e93d3156777f71ac2f1d636cfd4a6
      (car1, "#1 = Scan Table [ car_names ] Predicate [ Model = 'volvo' ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , Edispl ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Edispl ] ; #4 = Aggregate [ #3 ] Output [ AVG(Edispl) AS Avg_Edispl ]")
    , -- 4f7180a6789311e9ad1d037c95fcb731331d0639d72e703d6dd5e1c58b5c24d8
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age , Song_release_year , Song_Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age ASC ] Output [ Age , Song_release_year , Song_Name ]")
    , -- b903ad5349ab796f8ca5e9ac20b113a4b545f06cd1b8fd03918a5b11ed313a29
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ Code , GovernmentForm ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 1 ] Output [ Language ]")
    , -- 00d2bfa30e9d1a0eeec54a5722b019f8d9c849abe3f18da1fd96dcc51e8ab2e6
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Document_ID ]")
    , -- df86c873292dcf609490b4289dedb15016c2b143c99e52d6908ecdb4262ae8c0
      (car1, "#1 = Scan Table [ continents ] Predicate [ Continent = 'europe' ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent , CountryId , CountryName ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Output [ #2.Continent , #2.CountryName ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Continent = #1.ContId ] Output [ #4.CountryName ] ; #6 = Aggregate [ #5 ] GroupBy [ CountryName ] Output [ countstar AS Count_Star , CountryName ] ; #7 = Filter [ #6 ] Predicate [ Count_Star >= 3 ] Output [ CountryName ]")
    , -- 3f394f24a9ffba65e83de378069abbc3c6dc21d0e6858fd28bcaf8a4c44c069c
      (battleDeath, "#1 = Scan Table [ battle ] Output [ name , id ] ; #2 = Scan Table [ ship ] Predicate [ ship_type = 'brig' ] Distinct [ true ] Output [ lost_in_battle ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.lost_in_battle = #1.id ] Output [ #1.name , #1.id ]")
    , -- ae0670f297cf9b8c324a52dc99fc74755fa27bb442814673d6e095611d79886f
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Output [ Template_Type_Code , Template_Type_Description ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Scan Table [ Documents ] Output [ Template_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Template_ID = #2.Template_ID ] Output [ #2.Template_Type_Code ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Template_Type_Code = #1.Template_Type_Code ] Distinct [ true ] Output [ #1.Template_Type_Description ]")
    , -- 73c8b1da8ff7be1c1d0af01653242378ba5b079a8bde31662382b9a99834ae05
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Predicate [ current_address_id <> permanent_address_id ] Output [ first_name , current_address_id , permanent_address_id ]")
    , -- 4951f1256981c4e699025f83ed4e0568f0da2b0adfeb2a539dc76094ae288c84
      (world1, "#1 = Scan Table [ country ] Output [ Code , Region ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' OR Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Region ]")
    , -- 1355c0cdad34ed6843f0c7be4c8311e7c04c5e47498de15c69206fb41203297b
      (wta1, "#1 = Scan Table [ rankings ] Output [ ranking_date , tours ] ; #2 = Aggregate [ #1 ] GroupBy [ ranking_date ] Output [ SUM(tours) AS Sum_tours , ranking_date ]")
    , -- 4a4ef13b7b975976a31902cf7be1396d6d291bb928fecc469235c9d646f33b5d
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Output [ section_description , section_name ]")
    , -- fcb55729d495351ebf7cd2023a68b2f96ba3ef9f97bf285aa825d8e40b9fb5b0
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'afghanistan' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 993f7da6bf9f3c08f1e566829f9baa9a8e5d5f1ec7f62cd1cc76d32e74fc924a
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Predicate [ Sales > 300000.0 ] Output [ Singer_ID , Sales ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Distinct [ true ] Output [ #1.Name ]")
    , -- 28a57a5b75f7a8f40eec87da513ebdcad210610f006d483f39f4de5e4d14f7a7
      (singer, "#1 = Scan Table [ singer ] Predicate [ Birth_Year < 1945.0 ] Distinct [ true ] Output [ Citizenship ] ; #2 = Scan Table [ singer ] Predicate [ Birth_Year > 1955.0 ] Distinct [ true ] Output [ Citizenship ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Citizenship = #2.Citizenship ] Distinct [ true ] Output [ #1.Citizenship ]")
    , -- d008496febb26c97a226a63cf4430e16490d2020d9a76a94f3440235c54a99f8
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 4 ] Output [ Cylinders , MPG ] ; #2 = Aggregate [ #1 ] Output [ AVG(MPG) AS Avg_MPG ]")
    , -- 16c8b2f4d9463070faff9317b19b1c0ccb8c1c214ccc3d71f8e08fef7bb61dac
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Distinct [ true ] Output [ Template_Type_Code ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Scan Table [ Documents ] Output [ Template_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Template_ID = #2.Template_ID ] Distinct [ true ] Output [ #2.Template_Type_Code ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Template_Type_Code = #4.Template_Type_Code ] Output [ #1.Template_Type_Code ]")
    , -- 1d475eb098ce0ad96f35972c2d26c617cfcc6e15efde805ae7ee5dbca0616181
      (wta1, "#1 = Scan Table [ matches ] Distinct [ true ] Output [ winner_rank , winner_age , winner_name ] ; #2 = Top [ #1 ] Rows [ 3 ] Output [ winner_rank , winner_age , winner_name ]")
    , -- 7bcbec7f9317af4cda4f934c99013fba1b27971fdf1e19b737506f1e2bbbadb7
      (pokerPlayer, "#1 = Scan Table [ people ] Predicate [ Height > 200.0 ] Output [ People_ID , Height ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #2.Earnings ] ; #4 = Aggregate [ #3 ] Output [ AVG(Earnings) AS Avg_Earnings ]")
    , -- 0fe435ff996ce5bd596ecf192de9539d0b672b65c46ad5ac0b30f3ae4de14179
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Distinct [ true ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Template_ID) AS Count_Dist_Template_ID ]")
    , -- 78dcba3c4a0a01a2b294e2d6c29257905932d8253d58e95ad5b2a863957910ae
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ dog_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 7569cefc19424ebb6ee479425b4d76d5f2227a77640326c89b0d7ecc30cb1451
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Major_Record_Format ] ; #2 = Aggregate [ #1 ] GroupBy [ Major_Record_Format ] Output [ countstar AS Count_Star , Major_Record_Format ]")
    , -- e60ca4d3c1158e28353a8f15c12a2c2846a2d48f2f3bf754959163476896c575
      (world1, "#1 = Scan Table [ country ] Output [ Continent , LifeExpectancy , Population ] ; #2 = Aggregate [ #1 ] GroupBy [ Continent ] Output [ Continent , AVG(LifeExpectancy) AS Avg_LifeExpectancy , SUM(Population) AS Sum_Population ] ; #3 = Filter [ #2 ] Predicate [ Avg_LifeExpectancy < 72.0 ] Output [ Continent , Avg_LifeExpectancy , Sum_Population ]")
    , -- e81d18bcec18f6d352f79d2f159af0c55a5dc378dca8d9aa19e6d1a9d78f5a9e
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ City ] ; #2 = Aggregate [ #1 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ]")
    , -- 26be22a865b394ee60cdcb1dadda77678afbeceda9793eee650b327d8025b6a4
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Distinct [ true ] Output [ Channel ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.id ]")
    , -- a413d0d9c13eaf0c7ba05ab34db24918f93f106adeb3d8c794efab911446ac22
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ Continent , LifeExpectancy , GovernmentForm ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Output [ LifeExpectancy ] ; #3 = Aggregate [ #2 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 3a98eaad53fc81c47f32a49cd7ec2e73520ec75e0536d99059050386a10ee590
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Hometown ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age ASC ] Output [ Age , Hometown ]")
    , -- 1358270cfa743c906e3f59a8ee2e396a495b714ff53cab341c222aa87d9924c2
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ AVG(weight) AS Avg_weight , PetType ]")
    , -- 24b9e3ac13501e8a2eb99f6d37af002f21006457b42f6138786b9a75515062a4
      (world1, "#1 = Scan Table [ country ] Predicate [ IndepYear < 1930 ] Output [ Code , IndepYear ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode , Language ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Distinct [ true ] Output [ #3.Language ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 61bb655bcee5c11242e7ae7ad2bb18245dcaaad4ade6d8d621789af648b98cd6
      (museumVisit, "#1 = Scan Table [ visitor ] Predicate [ Level_of_membership = 1 ] Output [ Level_of_membership , ID ] ; #2 = Scan Table [ visit ] Output [ Total_spent , visitor_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.visitor_ID = #1.ID ] Output [ #2.Total_spent ] ; #4 = Aggregate [ #3 ] Output [ SUM(Total_spent) AS Sum_Total_spent ]")
    , -- dcd57f330d2deb88d06e3aa786b8bad819dc63de5e9110d4fbb94cbab2d57c1f
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #2.Stadium_ID , #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Stadium_ID ] Output [ countstar AS Count_Star , Name ]")
    , -- 7d0952affa592f943383d85f82a3cdbae6b653e87a16d0198cd69070d06cd9ab
      (wta1, "#1 = Scan Table [ players ] Distinct [ true ] Output [ country_code ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT country_code) AS Count_Dist_country_code ]")
    , -- 81ea1ebcc988a1d5cfb2f5eed7737cbd6d17b0cb15f16a9d08837af696997f07
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Hometown ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age ASC ] Output [ Age , Hometown ]")
    , -- 0f511d2d227935024ef20380b60fb30dd28ff843040398025d6c1cb4cff1ce93
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id , #2.Maker ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ FullName , countstar AS Count_Star ]")
    , -- cbdbda7f6b5a8cb8a3e91eb569ed7fe4af064e5e9da84de6721c53d11042f4a6
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.People_ID IS NULL OR #1.People_ID = #2.People_ID ] Output [ #1.Name ]")
    , -- 2ecd289b6fa8307e7eaee7f29ec9f80701fd8cde59870b09aa00e307ff7ad0f0
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , Content ]")
    , -- d03d7fcb88ff343e5ee83769b30e5f75cf398e639d6be0a1c20fe3f0a406f9aa
      (flight2, "#1 = Scan Table [ airports ] Output [ AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.AirportCode = #2.DestAirport OR #1.AirportCode = #2.SourceAirport ] Output [ #1.AirportCode ] ; #4 = Aggregate [ #3 ] GroupBy [ AirportCode ] Output [ countstar AS Count_Star , AirportCode ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , AirportCode ]")
    , -- 14759693b8e6ccb3b5373b3635e7c8d5e0763f8e3fd96765eeaf0cd318627e24
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 0ed3028cce8847cc6d514f0cf58b7033f1af4dc410e9a4a107a33b12e6c7dcd6
      (car1, "#1 = Scan Table [ countries ] Predicate [ CountryName = 'france' ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Country = #1.CountryId ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- c5a692afde2f7670bc43c3d670e2d9235236da86cfd5f2e53f5c8b520a96a5a3
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ MAX(weight) AS Max_weight , PetType ]")
    , -- c8b3f1ae55f0334741eb68f99155ba70466e54b6e14fdf47419475fbf841cada
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , id ] ; #2 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Episode , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.series_name ]")
    , -- 621f50d37306c6e356a4de3df6e3793856ee7f9d9ab9b053e9890cfa5db56c89
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Predicate [ current_address_id <> permanent_address_id ] Output [ first_name , current_address_id , permanent_address_id ]")
    , -- 29238520da091881c4e7a017b6177cb764df61f4b23ba7e2bdb8786955bd3ad8
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ car_names ] Output [ Model ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Model = #2.Model ] Output [ #2.Maker ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Maker = #1.Id ] Output [ #1.Maker , #1.Id ] ; #6 = Aggregate [ #5 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , Maker ] ; #7 = Filter [ #6 ] Predicate [ Count_Star > 3 ] Output [ Id , Maker ] ; #8 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #9 = Scan Table [ model_list ] Output [ Maker ] ; #10 = Join [ #8 , #9 ] Predicate [ #9.Maker = #8.Id ] Output [ #8.Maker , #8.Id ] ; #11 = Join [ #7 , #10 ] Predicate [ #7.Id = #10.Id ] Output [ #7.Id , #7.Maker ] ; #12 = Aggregate [ #11 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , Maker ] ; #13 = Filter [ #12 ] Predicate [ Count_Star >= 2 ] Output [ Id , Maker ]")
    , -- 725a0a1fc36a2853a3b3653227520372024a5dba8ae7bed03e06066dc689001d
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Distinct [ true ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Template_ID) AS Count_Dist_Template_ID ]")
    , -- 7ff01e405c8570255b3f1e0b8579237f1b2cda024aedefc247a6207d8bee48c6
      (flight2, "#1 = Scan Table [ flights ] Predicate [ DestAirport = 'apg' ] Output [ DestAirport , FlightNo ]")
    , -- 5c61e85b2ff5cd14b865b09f64f10986de9093ff1ecd8910423dc80bd72b86ba
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #4 = Scan Table [ country ] Output [ Code , Name ] ; #5 = Scan Table [ countrylanguage ] Predicate [ Language = 'french' ] Output [ CountryCode , Language ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.CountryCode = #4.Code ] Distinct [ true ] Output [ #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ #3.Name ]")
    , -- 8c12cf9b50cade1629258a9e8344630d0a188e5a5d2f19b038075767850b934f
      (singer, "#1 = Scan Table [ singer ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 4aaffeb328aed243160907dfc6c6886143ddfb519b5bdddd61990f46ad20f2a1
      (pets1, "#1 = Scan Table [ Pets ] Output [ pet_age , weight , PetType ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ pet_age ASC ] Output [ pet_age , weight , PetType ]")
    , -- bd844dd1bbe595ee1aa0d5da9010030323680dc2b4a5b47d15a2dd2bd4796d8b
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , transcript_id ] ; #2 = Scan Table [ Transcript_Contents ] Output [ transcript_id ] ; #3 = Aggregate [ #2 ] GroupBy [ transcript_id ] Output [ countstar AS Count_Star , transcript_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.transcript_id = #1.transcript_id ] Output [ #1.transcript_date , #3.transcript_id , #3.Count_Star ] ; #5 = Top [ #4 ] Rows [ 1 ] Output [ transcript_date , transcript_id ]")
    , -- c14783a0953c100a8cdf5562d085bafac95385ffda14252282e3a01b1d41244d
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Name ]")
    , -- 2b498fdf0e61dd8e384e559787a60d74066bf3945e4a574b958a7e65d8676f8b
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company ] ; #2 = Aggregate [ #1 ] GroupBy [ Record_Company ] Output [ Record_Company , countstar AS Count_Star ]")
    , -- b53627579d8711d98990593ed80847023e92dbca50b1ca0ac0b92653554ca0c9
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 1e4db4c4de408f4f9be2225ed03040fed5bf6e86f840d6f753669492df7ee562
      (car1, "#1 = Scan Table [ countries ] Distinct [ true ] Output [ CountryName ] ; #2 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Distinct [ true ] Output [ #2.CountryName ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.CountryName = #4.CountryName ] Output [ #1.CountryName ]")
    , -- 0d4d196cc026090096873dca60f9f9112235e305878c0d7bab7b6fd404e4a148
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Output [ section_name ]")
    , -- ba2f6f7ee2f6c495a1a659ea8490d0ed8808d5ae72b806c1fc73d1ca4972d780
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.grade ] ; #4 = Aggregate [ #3 ] Output [ MIN(grade) AS Min_grade ]")
    , -- dc5f3fb7030d664528f7de029349056a952430b2c758a96323474d603b11c727
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #5 = Scan Table [ country ] Output [ Code , Name ] ; #6 = Scan Table [ countrylanguage ] Predicate [ Language = 'french' ] Output [ IsOfficial , CountryCode , Language ] ; #7 = Filter [ #6 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #8 = Join [ #5 , #7 ] Predicate [ #7.CountryCode = #5.Code ] Distinct [ true ] Output [ #5.Name ] ; #9 = Join [ #4 , #8 ] Predicate [ #4.Name = #8.Name ] Distinct [ true ] Output [ #4.Name ]")
    , -- 74853798510bb1be5881fc985b194c00060b2fa3fafaf8b2d0658e70f2d759f0
      (dogKennels, "#1 = Scan Table [ Treatments ] Output [ cost_of_treatment ] ; #2 = Aggregate [ #1 ] Output [ AVG(cost_of_treatment) AS Avg_cost_of_treatment ] ; #3 = Scan Table [ Treatments ] Output [ cost_of_treatment ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.cost_of_treatment < #2.Avg_cost_of_treatment ] Output [ #3.cost_of_treatment ] ; #5 = Scan Table [ Professionals ] Output [ first_name , last_name ] ; #6 = Join [ #4 , #5 ] Distinct [ true ] Output [ #5.last_name , #5.first_name ]")
    , -- f8a3282285f9259ebf76f900a07aac1703877f2df99a0034fa27e72907327cb5
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Location , District , Number_products , Name ]")
    , -- 7acbdc4f7c108ce2c675170ef55882c7b9871fe3b5c8dbfee26a6f757a027492
      (concertSinger, "#1 = Scan Table [ concert ] Output [ concert_Name , Theme , concert_ID ] ; #2 = Scan Table [ singer_in_concert ] Output [ concert_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ concert_ID ] Output [ countstar AS Count_Star , concert_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.concert_ID = #1.concert_ID ] Output [ #1.concert_Name , #3.Count_Star , #1.Theme ]")
    , -- 95b11b7b6da3a1a61a86398786d17ce1182a1250691e9475819940d233798069
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID , Title ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #2.Title ]")
    , -- a86a96d3e0f4b6052d11149f8f2da48ab46dbd0cc3e8d64f456496fb96dff6f4
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ airports ] Predicate [ City = 'ashley' ] Output [ City , AirportCode ] ; #3 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.DestAirport = #2.AirportCode ] Output [ #3.SourceAirport ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.SourceAirport = #1.AirportCode ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- 501aeb236dcd162233fa7f85eef288c637da8ef7000d13a300b753843ca5d84c
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Final_Table_Made , Best_Finish ]")
    , -- 1d303a4c9be0e889f0579981273206eb3953935055b14be901616cc6fc92ba5f
      (battleDeath, "#1 = Scan Table [ ship ] Output [ name , id ] ; #2 = Scan Table [ death ] Output [ caused_by_ship_id ] ; #3 = Aggregate [ #2 ] GroupBy [ caused_by_ship_id ] Output [ countstar AS Count_Star , caused_by_ship_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.caused_by_ship_id = #1.id ] Output [ #1.name , #3.Count_Star , #1.id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name , id , Count_Star ]")
    , -- 2a006605914d62ef4da26c68c384d0d57d1cb62ea9722f1a6f3676efc0c57456
      (pets1, "#1 = Scan Table [ Pets ] Distinct [ true ] Output [ PetType ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT PetType) AS Count_Dist_PetType ]")
    , -- 2a4a5e75c0774a24355f23685b6e1e35bf529fbe6c142f94efbf6a9f24a57f6d
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #2 = Scan Table [ matches ] Predicate [ tourney_name = 'wta championships' ] Output [ tourney_name , winner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.winner_id = #1.player_id ] Distinct [ true ] Output [ #1.country_code , #1.first_name ] ; #4 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #5 = Scan Table [ matches ] Predicate [ tourney_name = 'australian open' ] Output [ tourney_name , winner_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.winner_id = #4.player_id ] Distinct [ true ] Output [ #4.first_name , #4.country_code ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.country_code = #6.country_code ] Distinct [ true ] Output [ #3.first_name , #3.country_code ]")
    , -- 14f44cbc77a573230a3ff8f32108865b84f1805f31fa964bc07357c949ae4d26
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = Filter [ #4 ] Predicate [ Count_Star < 200 ] Output [ Airline ]")
    , -- c3bc8027a1635183c2a5ab079b6bd0b8d12076ab770b908c0ea6bfc617303969
      (museumVisit, "#1 = Scan Table [ visitor ] Predicate [ Level_of_membership > 4 ] Output [ Age , Level_of_membership , Name ]")
    , -- 6c9d0187eaa14d3822b76fab25575f0bd029a4aae739341d09c7aa944fbb9678
      (world1, "#1 = Scan Table [ country ] Output [ Continent , LifeExpectancy , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ LifeExpectancy , Name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ LifeExpectancy ASC ] Output [ LifeExpectancy , Name ]")
    , -- 4c7d617842ecf4c2c442a7865d9226b92d5fc0b85e7dbe47701a24899111864b
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Aggregate [ #2 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star , owner_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.owner_id = #1.owner_id ] Output [ #3.owner_id , #1.last_name , #3.Count_Star , #1.first_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ first_name , owner_id , Count_Star , last_name ]")
    , -- b2572fa21c59deecda02eba022c89a012ca1699008c53c14477974811d2ab2b7
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Song_Name like '% hey %' ] Output [ Country , Song_Name , Name ]")
    , -- 856fdf46f76eb38b3c95693281ff5fed72655659ac9ba441d820e7ef6a1675dd
      (flight2, "#1 = Scan Table [ flights ] Predicate [ DestAirport = 'ato' ] Output [ DestAirport ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- aa6bf7301371f2cff46a9c496cf9c22dbbb4cb140dfc89f2ac109fd69c17017a
      (concertSinger, "#1 = Scan Table [ concert ] Output [ Year ] ; #2 = Aggregate [ #1 ] GroupBy [ Year ] Output [ Year , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Year , Count_Star ]")
    , -- 3e0c05f363776d11348e6153e66cd5edbe0ef5a51c3a812ec2633d44e47352ee
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ City ] ; #2 = Aggregate [ #1 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ]")
    , -- 2fd1f2fb8e00ca6198f226e0484c696991787954ae2f6ca11ca96be1973dd548
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ]")
    , -- 4e203440b0f9a0aedc9e463d02382c9f59aab4bf42372c1411307a998ac33150
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Manager_name , District , Number_products ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Number_products DESC ] Output [ Manager_name , District , Number_products ]")
    , -- ed32d95c06b758a201d5b6a501e55481c633acf085ca4187edd64f37741a20c1
      (wta1, "#1 = Scan Table [ matches ] Predicate [ year = 2013 ] Distinct [ true ] Output [ winner_name ] ; #2 = Scan Table [ matches ] Predicate [ year = 2016 ] Distinct [ true ] Output [ winner_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.winner_name = #2.winner_name ] Distinct [ true ] Output [ #1.winner_name ]")
    , -- 4eaa950c1003fdf45a32673b42ff643ccb4dd6ed5d95e36682f364519dcc349b
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Birth_Date ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Birth_Date , #2.Earnings ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Earnings ASC ] Output [ Earnings , Birth_Date ]")
    , -- 6fcf089875e01f63af8f84cf31cc2e94508fb7a057790cb893544b2c05054445
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ DestAirport = 'asy' ] Output [ DestAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- cd4f8032e1b1e509a1649a730f3394d342daf5f43398b10aed829e6a4dfbe85b
      (world1, "#1 = Scan Table [ country ] Output [ SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 5 ] OrderBy [ SurfaceArea DESC ] Output [ SurfaceArea , Name ]")
    , -- 5c853eed095b6baf4df9f2f0070d754fac01d936f3136ee93d9295666ec32afc
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'welcome to ny' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Paragraph_ID , Document_ID , Paragraph_Text ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text , #2.Paragraph_ID ]")
    , -- daecf9f7334ab07a6861fe88b0db2d042b3d0baf22049a3c90c953ebd630e9a0
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Country = 'usa' ] Output [ Abbreviation , Country , Airline ]")
    , -- 3344efc6cf9baa0bfa29c17aab9d688f6b48c8f4b7d92cf472dd385b9d171429
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ CountryCode ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #4 = Except [ #2 , #3 ] Predicate [ #2.CountryCode = #3.CountryCode ] Output [ #2.CountryCode ]")
    , -- 9e5201c6e248666fa311ea7cccc6d4189470d448be20a0380a4062d80f82c71e
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name ]")
    , -- 27252c0db0413b8693acfca670aa3ed42cd52d470b30fac453a92b3cf2e9ce82
      (pets1, "#1 = Scan Table [ Student ] Predicate [ LName = 'smith' ] Output [ StuID , LName ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #2.PetID ]")
    , -- 11757dbf072cf94f23cb22210fb8ca4455a8343fc40e151645d31758e9de045d
      (dogKennels, "#1 = Scan Table [ Dogs ] Predicate [ abandoned_yn = 1 ] Output [ age , abandoned_yn , weight , name ]")
    , -- 2302a1b8bb2111d71497b49f79a57e7db73f1de39aa54c60c1bab8fae0217a10
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'bachelor' ] Output [ degree_summary_name , degree_program_id ] ; #3 = Scan Table [ Student_Enrolment ] Output [ student_id , degree_program_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.degree_program_id = #2.degree_program_id ] Output [ #3.student_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.student_id = #1.student_id ] Distinct [ true ] Output [ #1.last_name , #1.middle_name , #1.first_name ]")
    , -- c9a7efa3930c9f7e3a10444caceb7e50835b86408bdd65b9a89aebbd3db71302
      (singer, "#1 = Scan Table [ singer ] Output [ Birth_Year , Citizenship ]")
    , -- 916a509f0948cff8af77cf3a8a8905ca4e5a6dafdc6ddb386cc27f529e15253e
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Written_by = 'joseph kuhr' ] Output [ Written_by ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- ea13f16bad44cab1f5519ae833248e98e84d09409acf52956eae0675e9cf159e
      (museumVisit, "#1 = Scan Table [ museum ] Predicate [ Open_Year > 2013 OR Open_Year < 2008 ] Output [ Open_Year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 9a74739b1de108b16cb952da7dc049a7c4df7890b6f39ef2440ff75f46bd86ad
      (pokerPlayer, "#1 = Scan Table [ people ] Distinct [ true ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Nationality) AS Count_Dist_Nationality ]")
    , -- 5fd9ccaae0c96c0dbd181367f13e8533d804eda56bffe6c9cf52d2aa5bf2997c
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Hometown ]")
    , -- 3b9f0f36bbd855cfee9bb2d646369dc4a8280d0621cd411f99915cdaaac6739a
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Rating , Episode ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Rating DESC ] Output [ Rating , Episode ]")
    , -- 37e62b783f69df48aa3ec8d6e649c65292819d95b61eac824d791d914bc56cf0
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Language , Count_Star ]")
    , -- b3db64365a68c90a44de3089b599cbb27ffa0e6a1d83bc09344beac1c5cfaa6b
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_age , loser_age ] ; #2 = Aggregate [ #1 ] Output [ AVG(winner_age) AS Avg_winner_age , AVG(loser_age) AS Avg_loser_age ]")
    , -- e5bc7ae30bf83fb8eed96dab217d730ef7479ca2974ab899b2c5de3a57b5d83f
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Predicate [ course_name = 'math' ] Output [ course_name , course_description ]")
    , -- 8fc7a2ee5a2eb6023b8e472bb2464ab3199f614879d09a2882a8e5e7053c079b
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ email_address , professional_id , role_code ] ; #2 = Scan Table [ Professionals ] Output [ email_address , professional_id , role_code ] ; #3 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.professional_id = #2.professional_id ] Output [ #2.role_code , #2.email_address , #2.professional_id ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.professional_id = #4.professional_id ] Output [ #1.professional_id , #1.role_code , #1.email_address ]")
    , -- 72cb3e5d56ab334b4eb7dbfbb1e6d8cac17ea9531d988f83da4a411ca5ed89a6
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Shop_ID IS NULL OR #1.Shop_ID = #2.Shop_ID ] Output [ #1.Name ]")
    , -- 767f67bdff974cd007a4ef44b18713af81def3a6d3999f59653e9508ab25c234
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id ] ; #2 = Scan Table [ Dogs ] Distinct [ true ] Output [ owner_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- da1dbbcc0a1c8a817f65ae6ee6fce3dabc45b38d66111fc4c7bee9adec5000cb
      (wta1, "#1 = Scan Table [ players ] Predicate [ hand = 'l' ] Output [ birth_date , first_name , hand , last_name ]")
    , -- 7a5f7faeae28debe426151c8e824472857dbcfafd49de540e5824d750266034f
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Title , Original_air_date , Directed_by ]")
    , -- e213cd4fec20daef85edf43f959e494d49e9cfc209bf8d906ddc0e163d0b7736
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Predicate [ department_name like '% computer %' ] Output [ department_description , department_name ]")
    , -- 567783c3df80bd4ff5f729ab5c7b8fc416c10a71799c470a6d2c3beb6ed5fcc9
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Average , Capacity , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Average DESC ] Output [ Average , Capacity , Name ]")
    , -- 3a1b4170c50ef2fb65e0ffaa67b45ab9282a898ec6581c895060e31332cf025b
      (world1, "#1 = Scan Table [ country ] Predicate [ Population = 80000 ] Output [ Continent , Population , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ Name ]")
    , -- 603bc70182ffde705ac9eac27f319a5aba32804cf32d8fb791f32b264dd03922
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ]")
    , -- e24254d972f8ecf7aa0697d04ee3434c79327bfec5fcb6eaa7ff5ba5537f66f6
      (voter1, "#1 = Scan Table [ area_code_state ] Output [ area_code ] ; #2 = Aggregate [ #1 ] Output [ MAX(area_code) AS Max_area_code , MIN(area_code) AS Min_area_code ]")
    , -- 2ff92e902d385f0d3c7c7ac8839232b8f21877f00a5e4efad288d1204c1383cd
      (battleDeath, "#1 = Scan Table [ battle ] Distinct [ true ] Output [ bulgarian_commander , result , name ] ; #2 = Scan Table [ battle ] Output [ name , result , bulgarian_commander , id ] ; #3 = Scan Table [ ship ] Predicate [ location = 'english channel' ] Output [ location , lost_in_battle ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.lost_in_battle = #2.id ] Distinct [ true ] Output [ #2.name , #2.result , #2.bulgarian_commander ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.name = #4.name ] Output [ #1.result , #1.name , #1.bulgarian_commander ]")
    , -- 2e6a21ea522f1a50f525947926f0f042d7a8194f313d7a60aa58fe70c5062144
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ dog_id , name ] ; #2 = Scan Table [ Treatments ] Output [ dog_id , cost_of_treatment ] ; #3 = Aggregate [ #2 ] GroupBy [ dog_id ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , dog_id ] ; #4 = Filter [ #3 ] Predicate [ Sum_cost_of_treatment > 1000.0 ] Output [ dog_id ] ; #5 = Except [ #1 , #4 ] Predicate [ #4.dog_id = #1.dog_id ] Output [ #1.name ]")
    , -- 126dcbf655e9d0632f315fe6f8ed028a2c9578c87310dbb69752079828e3552c
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , pet_age ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ pet_age ASC ] Output [ weight , pet_age ]")
    , -- 4bd4410da025c4c92f23a5169756fb4e81a8495682cd19482dd9e8f84a988855
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- 9ac26cfb14e02c1544639c9d16255b9fe612fbbfbf90f627a8c841571f1565b1
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.ID ] Output [ #1.name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name , Count_Star ]")
    , -- 063b8bcdd6c9ad73b186d5c9b6447dec9581ac1841a4485b9badd7e27ae84b9b
      (flight2, "#1 = Scan Table [ airlines ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- d8dfc34cdbedc21a0d90ad298cde344397edb67285973cccaf4929b8f06682d8
      (wta1, "#1 = Scan Table [ matches ] Predicate [ tourney_name = 'australian open' ] Output [ winner_rank_points , tourney_name , winner_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ winner_rank_points , winner_name ]")
    , -- 5f6c5c97e4535a57a648be9149e33db7045c08bc96516c2e753c41f04e1e2583
      (world1, "#1 = Scan Table [ country ] Output [ IndepYear , GovernmentForm , Name , HeadOfState , Continent , LifeExpectancy , GNPOld , Capital , Code2 , LocalName , Population , GNP , Code , SurfaceArea , Region ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ Percentage , IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ Percentage , IsOfficial , CountryCode , Language ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ #1.Code , #1.GNP , #1.Continent , #3.CountryCode , #1.LocalName , #1.Population , #1.GNPOld , #3.Percentage , #1.LifeExpectancy , #1.Name , #1.GovernmentForm , #1.HeadOfState , #3.IsOfficial , #1.Region , #1.IndepYear , #1.Code2 , #1.SurfaceArea , #1.Capital , #3.Language ] ; #5 = Scan Table [ country ] Output [ IndepYear , GovernmentForm , Name , HeadOfState , Continent , LifeExpectancy , GNPOld , Capital , Code2 , LocalName , Population , GNP , Code , SurfaceArea , Region ] ; #6 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' ] Output [ Percentage , IsOfficial , CountryCode , Language ] ; #7 = Filter [ #6 ] Predicate [ IsOfficial = 't' ] Output [ Percentage , IsOfficial , CountryCode , Language ] ; #8 = Join [ #5 , #7 ] Predicate [ #7.CountryCode = #5.Code ] Output [ #5.LocalName , #5.HeadOfState , #5.Continent , #7.CountryCode , #5.Code2 , #5.SurfaceArea , #7.Language , #5.IndepYear , #5.Population , #5.GovernmentForm , #7.Percentage , #5.Region , #5.GNPOld , #5.LifeExpectancy , #5.Capital , #7.IsOfficial , #5.Name , #5.Code , #5.GNP ] ; #9 = Union [ #4 , #8 ] Output [ #4.Continent , #4.Population , #4.Name , #4.GNP , #4.GovernmentForm , #4.Region , #4.HeadOfState , #4.Language , #4.LocalName , #4.Capital , #4.IsOfficial , #4.SurfaceArea , #4.IndepYear , #4.GNPOld , #4.LifeExpectancy , #4.CountryCode , #4.Code , #4.Percentage , #4.Code2 ]")
    , -- 216deec7ce39e86c5ef67a4c5259db2aeabae0a3db17c2270cc93df36cee7e30
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Language <> 'english' ] Output [ Pixel_aspect_ratio_PAR , Country , Language ]")
    , -- 433878795dbaeb06e20ccdf8f7b8f57b4490fc5649d2e72bce7e7585deacbf03
      (dogKennels, "#1 = Scan Table [ Treatments ] Output [ cost_of_treatment , date_of_treatment ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_of_treatment DESC ] Output [ cost_of_treatment , date_of_treatment ]")
    , -- 2686e428ed6dee19e01cd063666a64aeceba24051c34ee875917395fcb3c1cfb
      (car1, "#1 = Scan Table [ countries ] Predicate [ CountryName = 'usa' ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Id , Country ] ; #3 = Scan Table [ model_list ] Output [ Maker ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Maker = #2.Id ] Output [ #2.Country ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Country = #1.CountryId ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- dce5580fa604cef1b7013efde88ea414c1480828f0c15e0c53b05b4ef6ff025b
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , id ] ; #2 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Episode , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.series_name ]")
    , -- 375f05a7144b42b7b01a5557989bdde5fbf222a82089e659eb469e04e6091ddb
      (voter1, "#1 = Scan Table [ contestants ] Output [ contestant_name ] ; #2 = Filter [ #1 ] Predicate [ contestant_name like '%al%' ] Output [ contestant_name ]")
    , -- 3854a4726f08605b3fc8736f407fd3320c4b070be41be27a18da970a13cabf86
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Predicate [ Earnings > 300000.0 ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name ]")
    , -- 7e3bd780ec04ba80fb47a192efc6c0fff9a6a083d07990a499435bf06c681be3
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ grade , Count_Star ]")
    , -- a5b58ec921e463893a58faab86400b125f114b5c0469aa70c41f39267cc6731e
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Orchestra_ID , Orchestra ] ; #2 = Scan Table [ performance ] Output [ Orchestra_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Orchestra_ID IS NULL OR #1.Orchestra_ID = #2.Orchestra_ID ] Output [ #1.Orchestra ]")
    , -- e5bb7493553ebb3687bf1cdb55d5edfc06663219cc39e255956981437ab3d826
      (wta1, "#1 = Scan Table [ players ] Output [ hand ] ; #2 = Aggregate [ #1 ] GroupBy [ hand ] Output [ countstar AS Count_Star , hand ]")
    , -- ee837d790c1052adcb9de495cfc9af05e217e5ad8839eeddf75d4cadfbd199fd
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_rank_points , winner_name ] ; #2 = Aggregate [ #1 ] GroupBy [ winner_rank_points , winner_name ] Output [ winner_rank_points , countstar AS Count_Star , winner_name ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ winner_rank_points , winner_name , Count_Star ]")
    , -- 09a03a898de94d379933b176c750be6d83e799a2d7d31e03de82e63888e69ed1
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ size_code , owner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.last_name , #2.size_code , #1.first_name ]")
    , -- e2e869b34513e5bed08d8f4fbbc0bbf12e76f971c72c6a06fd9e413fda048afc
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.grade ] ; #4 = Aggregate [ #3 ] Output [ AVG(grade) AS Avg_grade ]")
    , -- 510cd2705d653711d8a98af4c2f583205aad0b5adf2325464970f860083224cd
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Age > 20 ] Distinct [ true ] Output [ Country ]")
    , -- 638f6f2ec73a8fdd72296c056dbd30a739b9d387584c4b01c28c97f413f3675c
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Age , Name ]")
    , -- 6632e3ca9157ea891f945858d65d51a7c21b4b3beac8b3d957f92610d775da20
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'cvo' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Distinct [ true ] Output [ #1.Airline ] ; #4 = Scan Table [ airlines ] Output [ uid , Airline ] ; #5 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , Airline ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Airline = #4.uid ] Output [ #4.Airline ] ; #7 = Except [ #3 , #6 ] Predicate [ #3.Airline = #6.Airline ] Output [ #3.Airline ]")
    , -- 1f310f5bbbc32f27959b1948e0a2b55cc6d6ab439f95fa18d2a151873b24edf2
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- fe1e4fc69d4dfc7f14ea8c7ccb0d3d686be08850c06a3118dbb5c2c166fec18d
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #4 = Scan Table [ country ] Output [ Code , Name ] ; #5 = Scan Table [ countrylanguage ] Predicate [ Language = 'french' ] Output [ CountryCode , Language ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.CountryCode = #4.Code ] Distinct [ true ] Output [ #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ #3.Name ]")
    , -- 42d93c17d3b56bb252b66f63ab587d51a87c7c5714ad70b39b5c3bc9b6206343
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Capacity ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Capacity DESC ] Output [ Stadium_ID , Capacity ] ; #3 = Scan Table [ concert ] Output [ Stadium_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Stadium_ID = #2.Stadium_ID ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- b77fa3b8526203bcd90c712fdbdee81795d22020a91667f2c3c3d49f348b347a
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 7956562de86b573a31dfeb98d0b90656fb45a70318182803401388262c78da8b
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'angola' ] Output [ Name , Region , Population ]")
    , -- c799c2d3a69ce74de70092294fcae7075d54975ef156b0e53763fecc34b61ff3
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Predicate [ course_name = 'math' ] Output [ course_name , course_description ]")
    , -- f1c050489e77aa36a4a6916315d9101c4fc31dd87f4c21d1a86f6de09e54aa1b
      (wta1, "#1 = Scan Table [ matches ] Output [ minutes , winner_name , loser_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ minutes DESC ] Output [ minutes , winner_name , loser_name ]")
    , -- 767d8f34f1b268c7832d789fbb1f662604e9db7d49975fb7b642cb8ca235ce34
      (realEstateProperties, "#1 = Scan Table [ Ref_Property_Types ] Output [ property_type_code , property_type_description ] ; #2 = Scan Table [ Properties ] Distinct [ true ] Output [ property_type_code ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.property_type_code = #1.property_type_code ] Output [ #1.property_type_description ]")
    , -- d2502ee559df2f596143a49e800b73f835360ae66c3ddae79b9c43c55315a820
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text like 'korea' ] Output [ Paragraph_Text , Other_Details ]")
    , -- 7c4fa321a90c7351e476975b181c798ce83282484ff08fa81936504345c58670
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Manager_name , District , Number_products ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Number_products DESC ] Output [ Manager_name , District , Number_products ]")
    , -- 67d0d7311467f93130cc61ed07eb52dea243bb0b8805dada1872d0b4869b620e
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Final_Table_Made , Best_Finish ]")
    , -- 6c2fcf353449efb9231d6c798d779d0168d424c399c9c362f5a6da5654716338
      (wta1, "#1 = Scan Table [ matches ] Output [ tourney_name ] ; #2 = Aggregate [ #1 ] GroupBy [ tourney_name ] Output [ countstar AS Count_Star , tourney_name ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 10 ] Output [ tourney_name ]")
    , -- 5a1add434252fa8ef88afe242d0e6f6da6ebe21eab7ebb70940db2d4060acb6e
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id , line_2 , line_1 ] ; #2 = Scan Table [ Students ] Output [ current_address_id ] ; #3 = Aggregate [ #2 ] GroupBy [ current_address_id ] Output [ countstar AS Count_Star , current_address_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.current_address_id = #1.address_id ] Output [ #1.line_2 , #1.address_id , #3.Count_Star , #1.line_1 ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ address_id , line_2 , line_1 , Count_Star ]")
    , -- a5c6e42a1d24d3732f7b16dcde9891a5195f390875ae1f489359f2d7dccfb7a6
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Output [ Template_Type_Code , Template_Type_Description ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Scan Table [ Documents ] Output [ Template_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Template_ID = #2.Template_ID ] Output [ #2.Template_Type_Code ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Template_Type_Code = #1.Template_Type_Code ] Distinct [ true ] Output [ #1.Template_Type_Description ]")
    , -- 0d4fb20a6fb3ba654d1369ba25a6a2a37e5ff5c8fdd5227b2a6e28aa7436fa5e
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Location ] ; #2 = Aggregate [ #1 ] GroupBy [ Location ] Output [ Location , countstar AS Count_Star ]")
    , -- fc656750ad557e7b823554bc96113a1f7f9ecc12fbb70e851c875598e29ecd85
      (dogKennels, "#1 = Scan Table [ Charges ] Output [ charge_amount ] ; #2 = Aggregate [ #1 ] Output [ MAX(charge_amount) AS Max_charge_amount ]")
    , -- 6b4935ecf21e96347d09f914c1134d872dd90cea1d200906b8422cec79050abe
      (car1, "#1 = Scan Table [ cars_data ] Output [ Id , Accelerate ] ; #2 = Scan Table [ car_names ] Predicate [ Make = 'amc hornet sportabout ( sw )' ] Output [ MakeId , Make ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.MakeId = #1.Id ] Output [ #1.Accelerate ]")
    , -- 93b7ac35d94bcc7afc58e37c1555d4cd63f189511d09f623994cfda40291923d
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Employee_ID ] Output [ Employee_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Employee_ID = #1.Employee_ID ] Output [ #1.Name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- cbf9f39d623b23fe3ba8c7aa545d5a25e98577e97afccb06037e8b79412519ea
      (world1, "#1 = Scan Table [ country ] Predicate [ IndepYear > 1950 ] Output [ IndepYear , Name ]")
    , -- e449e6f942e8de3c7125b40721a8e17af0e967438dc82614ca4da0cc044227c3
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 1 ] Output [ Template_ID ]")
    , -- d7ae9ecca2a02d1ea9bab41b4eb1fb9f4020c46bb3c6f7cf3723d9032eb7b454
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Orchestra_ID , Orchestra ] ; #2 = Scan Table [ performance ] Output [ Orchestra_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Orchestra_ID IS NULL OR #1.Orchestra_ID = #2.Orchestra_ID ] Output [ #1.Orchestra ]")
    , -- 4af53503bdc21b5142677ed8df8d47ab8618267cae7b31f47a0953918d948d2a
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Rating , Episode ]")
    , -- 09c9bbb573dcab0c927cbe7d112f91c8834c15a2eb31f230e5f325df5793bdf6
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ email_address , cell_number , home_phone ]")
    , -- 7c9e7a7be63f400ff33df576791e0fd53332a3d954a89aa0cb953b4eb70b1682
      (singer, "#1 = Scan Table [ singer ] Output [ Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ countstar AS Count_Star , Citizenship ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Citizenship , Count_Star ]")
    , -- 85aeac6085a45b42a3cb13e9a51a1238d1d7659f549c5d296e0bd0b85977b67f
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Employee_ID = #1.Employee_ID ] Output [ #1.Name ]")
    , -- 181a002a5e4f8fec27048244b795b5b3f13c9550a5947e3599925be1edb96f8a
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 8 AND Year = 1974 ] Output [ Weight , Year , Cylinders ] ; #2 = Aggregate [ #1 ] Output [ MIN(Weight) AS Min_Weight ]")
    , -- d2374d59745c0e008a05a979d13f5c78e4b5039879a3a689dd950667f24dfdcc
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' OR City = 'abilene' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- a9c17fcf19a13f223416ed82289c1000f806514655d35b1590c3ad2d5f84cebf
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Predicate [ Earnings < 200000.0 ] Output [ Final_Table_Made , Earnings ] ; #2 = Aggregate [ #1 ] Output [ MAX(Final_Table_Made) AS Max_Final_Table_Made ]")
    , -- 90a8fb09639d78d2f2cca85fcc342eebec55dbb742658bab91e55d242e256e6b
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'anguilla' ] Output [ Continent , Name ]")
    , -- 51f9a9d3a8314bf9ecb1b1a87c9575af07e01bf2c3ca056692feb0849a94c29f
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'master' ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id , semester_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.degree_program_id = #1.degree_program_id ] Distinct [ true ] Output [ #2.semester_id ] ; #4 = Scan Table [ Degree_Programs ] Predicate [ degree_summary_name = 'bachelor' ] Output [ degree_summary_name , degree_program_id ] ; #5 = Scan Table [ Student_Enrolment ] Output [ degree_program_id , semester_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.degree_program_id = #4.degree_program_id ] Distinct [ true ] Output [ #5.semester_id ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.semester_id = #6.semester_id ] Distinct [ true ] Output [ #3.semester_id ]")
    , -- 8e3aad50097526966d284fe425eed6f8ffe01c3dca9060ccd62b3d3ff562e4b9
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Document_ID , Count_Star ]")
    , -- 3b8ab4e1d255f68608b86f8899d6adfb0367f92a350579daf6bc26437288a126
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name , #2.Earnings ]")
    , -- 2ae1a5a8d079e1ddb3c830c69f555e616cc82ca7a5d386879eb5085591970c7c
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_age , loser_age ] ; #2 = Aggregate [ #1 ] Output [ AVG(winner_age) AS Avg_winner_age , AVG(loser_age) AS Avg_loser_age ]")
    , -- e26742908088fa6b5a4a123e0c3d581e1de7fab7b51949cba4c73da7766784f9
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ]")
    , -- 61b6eaccc94d6d2900ca8a1d8163d9c358c6a9d2034e1abc1e0f04df540300a6
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , id ] ; #2 = Scan Table [ TV_series ] Output [ Episode , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #2.Episode ]")
    , -- e39c8aa6302e480ebe544ab36de4875b9b45d00eee51f4cc97c46be201830fa9
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #2.Course , #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name , #4.Course ]")
    , -- 37c6344d0991afd89c9c159fc6a00dd71a4e656faeb14892c43cb3a1d63c0848
      (courseTeach, "#1 = Scan Table [ teacher ] Predicate [ Age = 32 OR Age = 33 ] Output [ Age , Name ]")
    , -- c3ef543a45f6e5e4f66daf47c8a178b75e697130dea996d32edb01489e7f2b0c
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Template_ID = #1.Template_ID ] Output [ #3.Template_ID , #3.Count_Star , #1.Template_Type_Code ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Template_ID , Count_Star ]")
    , -- 25606457dfeb99c81a178c71cf5dbdd5bc475297eaae4baba83c0b3f28a8b5d5
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'summer show' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- ce82a2bc66cd458fd38b1b6325e2c841b5eb71ebe89e613ef8d2356e65d99a3b
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ transcript_date DESC ] Output [ transcript_date ]")
    , -- fb9cbfdceb6a3362120b75015476a3bdc879639245debb86984e0edc8b39b35e
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Title , Original_air_date , Directed_by ]")
    , -- b382a94261c2999cc724820561e70e7fc4fdab26b2e6c4e0a72ac715977e5ef4
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ Abbreviation , Airline ]")
    , -- d0add8ef7ebdb8bb0c8c3c4c33b8775c08dde1c736f9ad1398a7cbddcafa4776
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #2 = Scan Table [ Student ] Predicate [ Sex = 'f' ] Output [ StuID , Sex ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.StuID = #2.StuID ] Output [ #3.PetID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.PetID = #1.PetID ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- 593b02f02ed6283fc7f6f920d4f2c675dd951433acf861995146b5c3a0e90968
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 1 AND Count_Star <= 2 ] Output [ Document_ID ]")
    , -- a2ffbc395f534bbcc3f680bff6c1171efc495cd5e4a165fd980fb0040bac4623
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #2 = Scan Table [ concert ] Output [ Stadium_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Stadium_ID IS NULL OR #1.Stadium_ID = #2.Stadium_ID ] Output [ #1.Name ]")
    , -- bdc760b10e114287a082d9d26269eaba08a7116ab333ba86922c908eee77b475
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Distinct [ true ] Output [ Template_Type_Code ]")
    , -- 7f56858bb93fce00274ad7fc93c7c106d09905596af081d93d544e02731db6c4
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ Abbreviation , Airline ]")
    , -- 121311c3b8547bc02036a7ee997148efc6a18552e09213becf9d418b8b66bdec
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text like 'korea' ] Output [ Paragraph_Text , Other_Details ]")
    , -- a17adb01c205ee4acecf59e8282753026f4bcbfac86be64aba1ac37290f2415c
      (wta1, "#1 = Scan Table [ matches ] Output [ loser_rank ] ; #2 = Aggregate [ #1 ] Output [ MIN(loser_rank) AS Min_loser_rank ]")
    , -- 942ebb3b2f283625abe8cb0f069bc441f28e042e63ea9dbad0891cdf9bdcf33b
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Population ASC ] Output [ Population , Name ]")
    , -- a64d6f482d2ebdc30710080c6687dabf2623b14791148768a43369e54265ec45
      (wta1, "#1 = Scan Table [ matches ] Output [ loser_rank ] ; #2 = Aggregate [ #1 ] Output [ MIN(loser_rank) AS Min_loser_rank ]")
    , -- 59494964483df233275b18143af64420c0b7863a6e168ecb92028d30acc4c823
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'ahd' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ]")
    , -- d59fc2b348e4322ab55b3c0602d3c7281523c59e6cdc25eeba00a219ed306068
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 8 OR Year < 1980 ] Output [ Year , Cylinders , MPG ] ; #2 = Aggregate [ #1 ] Output [ MAX(MPG) AS Max_MPG ]")
    , -- 263ffac75ab9c422dd579995c62f4fdbd85d5041d6cdb5c017af4d1158c376a7
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 3 ] Output [ name ]")
    , -- c348d12b01b02a3eddb926cec1d07d17ee281ad2cebf76d0f34fbec50d2a8658
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings ] ; #2 = Aggregate [ #1 ] Output [ AVG(Earnings) AS Avg_Earnings ]")
    , -- 6aac79de3dfb498f14e452ccffef52b0fbffb19db5276bb259b6dd6196e2c474
      (network1, "#1 = Scan Table [ Likes ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ]")
    , -- 76315f6ac3350f7af835b9f7f6a46ec89579cd792877b93f61a84ee2ad621932
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #3 = Scan Table [ Friend ] Output [ student_id , friend_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.student_id = #2.ID ] Output [ #3.friend_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.friend_id = #1.ID ] Output [ #1.name ]")
    , -- a5718dce78aa6a1cb4b8449f5ac89c6e167966f9905923340a77326aba16ba34
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ name ]")
    , -- 1e794a6002b4eb201d69fd387733237b9ee039ee07e7e045ed7bcba1df37db8f
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , Country , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'michael chang' ] Output [ Channel , Directed_by ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Distinct [ true ] Output [ #1.Country , #1.series_name ] ; #4 = Scan Table [ TV_Channel ] Output [ series_name , Country , id ] ; #5 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Channel , Directed_by ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Channel = #4.id ] Distinct [ true ] Output [ #4.Country , #4.series_name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.series_name = #6.series_name ] Distinct [ true ] Output [ #3.Country , #3.series_name ]")
    , -- 7cfeeba3a17801aa0e5e8907ae3de3f7117164f2eac9624d4f86b7caed7ae112
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Description like '% w %' ] Output [ Document_Name , Document_Description , Template_ID ]")
    , -- 63184492d88ed5c4c27ba64d205fbe596fe665ec2cc7351381b9572871047832
      (car1, "#1 = Scan Table [ model_list ] Output [ Model ] ; #2 = Scan Table [ cars_data ] Predicate [ Year > 1980 ] Output [ Id , Year ] ; #3 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.MakeId = #2.Id ] Output [ #3.Model ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Model = #1.Model ] Output [ #1.Model ]")
    , -- 7bcee666dc61c24ef33d8f9dc8c2ce0f1d9fcc88e028a8ae269ea5507f2555d6
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 62e0e49372c6619ec2e9e395882058f8052df231fccbd47054d60d4d0cece143
      (network1, "#1 = Scan Table [ Friend ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ]")
    , -- 53334ecd19e94f941108a87084020b87e9f5c41dc547b09d9aae53339cc69b0d
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Country = 'france' ] Output [ Age , Country ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age , MAX(Age) AS Max_Age , MIN(Age) AS Min_Age ]")
    , -- c88891737613a4d053e155f72e36d99af9f1e6c24735c66f1070319dacf69229
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ Package_Option , series_name ]")
    , -- d23e45e01461740b309c05a03a6520364714fb42bf3fee6b1e3eac7a4799d8ce
      (orchestra, "#1 = Scan Table [ orchestra ] Predicate [ Major_Record_Format = 'cd' OR Major_Record_Format = 'dvd' ] Output [ Major_Record_Format ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- b9ea969d4c1a883ed38c19942e7eb9b608a8f06861c97fdde9839c049fa21c88
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Name ]")
    , -- eb3cde0276a0fc8b1f8d2f8fafb35798919522c42a6092dd8e015b09b31af5f9
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryName , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , CountryName ]")
    , -- 587e9458cada672d2d3927d405dbd2f9bca706e71eb19a1a0e6d26d029033252
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Top [ #4 ] Rows [ 1 ] Output [ name ]")
    , -- 36a2157fcc813e6a8d142d9e19e8471df3c97f9c4b89b1093f70b6d30255a382
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'jetblue airways' ] Output [ Country , Airline ]")
    , -- 7b60704a707282ff6d06ee3878ad4f01c67cc82227ec275359829b2c1cba6515
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Year_of_Work , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Year_of_Work DESC ] Output [ Year_of_Work , Name ]")
    , -- e13407fb59cee2490a6ebbe85e83d8aaafad8412414e1deeca3ddd50c02be181
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , FlightNo ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ #2.FlightNo ]")
    , -- 23f904d4bb657c2244387cda5a52f79e36b9bb5a5edd4ce0dc973805fe3d3e58
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Version_Number > 5 ] Output [ Template_Type_Code , Version_Number ]")
    , -- 73901c0e2644fd7bcca864ab987842eae3371572f3f1c7c7323bba227247e5a3
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_departed , date_arrived ]")
    , -- ec8b526c55f9a125041bfebfcd2a771dfccddcf370f22042f6b1147afdcaafe4
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Aggregate [ #2 ] GroupBy [ StuID ] Output [ StuID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.StuID = #1.StuID ] Output [ #1.StuID , #3.Count_Star ]")
    , -- 08a69a180305a344c510949c19179114ef27795b2597f6b53a9e8f126b7cde94
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name ]")
    , -- fe556df1566300f7d867bf85a0acea81c1ec223b682d1513e1b388040c727efe
      (battleDeath, "#1 = Scan Table [ battle ] Distinct [ true ] Output [ result ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT result) AS Count_Dist_result ]")
    , -- 6b280b59c701284ea7d360487270d2cdccc7b55f90b65e9d7e7484f4be0a3e78
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Hometown ]")
    , -- 83393630216ab26b6fab91f2a2babda82dc85c460b21671995a86dfb3b40b45c
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Title ]")
    , -- 4d5cee55fec256b8f6850ffd68ea37b824569ff2bdd66b6393e896020179a357
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Nationality ]")
    , -- 7d29cad1b4024d12284567661ef0e6588258cde70692d06347b87dcde5d31d9b
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'customer reviews' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Paragraph_Text , Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text ]")
    , -- a44b097d3f024e039d7a10d6b30bd8c5732316000159a260fef28e3ea1b0471c
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Language = 'english' ] Output [ Language ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8b9d043a303b43c1a782650d2ce723fe3dcd74a534ba49ee19d1b194d80acc7b
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ]")
    , -- bd73120de1d8750d59209a5ddee60a05cb1e802dcf56822cc36df4a5c48897a2
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Production_code , Channel , Original_air_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Original_air_date DESC ] Output [ Production_code , Channel , Original_air_date ]")
    , -- e1606375d3c23c6a2f2818d49e782b1425a672757cbc62f62375fa926d4a216c
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'angola' ] Output [ Name , Region , Population ]")
    , -- c68377e24e04a97ee2cb8d163fb6be38ae5e40a2f50c26dc500eeb8432ff76db
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- e544df3d47b4c732fba6bbe69959eb06d71a4b9701f1c2d772f07a2bd1a3e3b4
      (tvshow, "#1 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ Country ] ; #2 = Scan Table [ TV_Channel ] Output [ Country , id ] ; #3 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by , Channel ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Channel = #2.id ] Distinct [ true ] Output [ #2.Country ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Country = #4.Country ] Output [ #1.Country ]")
    , -- 01d36d186ac9bd072310196a084016e2239ab53dc2afc337552b1b90e333e482
      (dogKennels, "#1 = Scan Table [ Owners ] Predicate [ state = 'virginia' ] Output [ state , first_name , owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #2.name , #1.first_name ]")
    , -- 1f6246464b62f765bf1b1cd4fb9ab00f47b5ee2aa8b7ba1ac9112ecf774c5483
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name ] ; #2 = Scan Table [ Owners ] Output [ first_name ] ; #3 = Union [ #1 , #2 ] Output [ #1.first_name ] ; #4 = Scan Table [ Dogs ] Output [ name ] ; #5 = Except [ #3 , #4 ] Predicate [ #4.name = #3.first_name ] Output [ #3.first_name ]")
    , -- bf6b1d29e11ed83843dd7359807c686a7503effa62469509bf03de3a88b35b89
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.grade ] ; #4 = Aggregate [ #3 ] Output [ MIN(grade) AS Min_grade ]")
    , -- ff92bf186cb026e0855344183504608a989cfe970c6d5cc696280faa3f1ed561
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ]")
    , -- 9c652b3b6b8008aeefd32407accb5c92e8b77e33db8255bf73373095371f09ac
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Shop_ID ] Output [ countstar AS Count_Star , Shop_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Shop_ID = #1.Shop_ID ] Output [ #1.Name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- a96906121bf8107ed5d7287ea51641686047ef0e777391884145b07db87baad4
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ city = 'port chelsea' ] Output [ zip_postcode , city ]")
    , -- 1a52ea66e61e79d0c7556af1d81db30038d734dc4d84fcc7157edcb76b0e0f84
      (wta1, "#1 = Scan Table [ matches ] Output [ minutes , winner_name , loser_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ minutes DESC ] Output [ minutes , winner_name , loser_name ]")
    , -- 0f7d42df7248364edf39effe13d7eba22fde164f27cd785a594e0fcd44cabce8
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Airline ]")
    , -- b7b03db85ab48e278ad66f39305dfa4aa1bf37d7b21f77b565e7d380007d2127
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- d1f8533f2672bfc50cab0c09ffe4250953ede5126b08584e81b5315b1947af94
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language <> 'english' ] Output [ CountryCode , Language ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ CountryCode ]")
    , -- b69843ef90777876c4360c78bd23ba71beb1e392bbf2540345f6709eb354d205
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Location , District , Number_products , Name ]")
    , -- a271ea14ee9ab5f826f8435851bff6696ec77d2382036bb6174344f6a211ff5c
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , MPG ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.MPG , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ MPG DESC ] Output [ MPG , Model ]")
    , -- 3193d5beb7c66a6847f2c9dbe3f4f3078a8c1d60b15e1d257646ae05dc950b32
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'anguilla' ] Output [ Continent , Name ]")
    , -- 134c01a812f1d002b8ec3b1bada53172b4e50778eb87d5b24cb776d6a94c731f
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Birth_Date ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Birth_Date , #2.Earnings ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Earnings ASC ] Output [ Earnings , Birth_Date ]")
    , -- 8712f813e382b9eadb483db8adea6999189ff315c912822cb725e49f6fb06f95
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ treatment_type_code , cost_of_treatment ] ; #3 = Aggregate [ #2 ] GroupBy [ treatment_type_code ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , treatment_type_code ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.treatment_type_code = #1.treatment_type_code ] Output [ #1.treatment_type_description , #3.Sum_cost_of_treatment ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Sum_cost_of_treatment ASC ] Output [ Sum_cost_of_treatment , treatment_type_description ]")
    , -- 00b406cd591e370b0ca414e76c4edb78d82b3c13b4b63b505216c99f888eb002
      (car1, "#1 = Scan Table [ car_makers ] Predicate [ FullName = 'american motor company' ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 997a9d9b23d45ca4e3b077ba7f5a6f03f5475311200c92805f200366cfc56736
      (voter1, "#1 = Scan Table [ area_code_state ] Output [ area_code , state ] ; #2 = Scan Table [ votes ] Output [ state , contestant_number ] ; #3 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ] ; #4 = Filter [ #3 ] Predicate [ contestant_name = 'tabatha gehling' ] Output [ contestant_number ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.contestant_number = #2.contestant_number ] Output [ #2.state ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.state = #1.state ] Distinct [ true ] Output [ #1.area_code ] ; #7 = Scan Table [ area_code_state ] Output [ area_code , state ] ; #8 = Scan Table [ votes ] Output [ state , contestant_number ] ; #9 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ] ; #10 = Filter [ #9 ] Predicate [ contestant_name = 'kelly clauss' ] Output [ contestant_number ] ; #11 = Join [ #8 , #10 ] Predicate [ #10.contestant_number = #8.contestant_number ] Output [ #8.state ] ; #12 = Join [ #7 , #11 ] Predicate [ #11.state = #7.state ] Distinct [ true ] Output [ #7.area_code ] ; #13 = Join [ #6 , #12 ] Predicate [ #6.area_code = #12.area_code ] Distinct [ true ] Output [ #6.area_code ]")
    , -- ba3f56f03b1943de5b7ddbd446cd90be44d8e731880028b4f9de9e873e1a5457
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Version_Number , Template_Type_Code , Template_ID ]")
    , -- decfc871b13ceaffd983db7df7c5c5dd6962b493f507d45cc62e8e2e3a87588a
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age , dog_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ #1.age ] ; #4 = Aggregate [ #3 ] Output [ AVG(age) AS Avg_age ]")
    , -- 023663de7188fe415732228ff855e71fab5db97f44ddd42d8472b0f437beeb7a
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Age , Name ]")
    , -- 80efc9528d926cc2970eaa5a22f5f4d008fa1a94b6050d71ae100ab15bca8ef7
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 3 ] Output [ Template_Type_Code ]")
    , -- a78bd98cec62dcd2412bb4c46df0a833d83f005bae19b95ec2402f74142e86b9
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ]")
    , -- cc65ca5065252da2020bf5040dd74af587bed02d69e4980d862e8216f0a767b3
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , id ] ; #2 = Scan Table [ Cartoon ] Output [ Title , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #2.Title ]")
    , -- 0236e60074389525ae99b74bd2a1c01b56e74854227b6ac59849d44d9a5c6c00
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Code ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'chinese' ] Output [ IsOfficial , CountryCode , Language ] ; #4 = Filter [ #3 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.CountryCode = #2.Code ] Output [ #2.Code , #4.CountryCode ] ; #6 = Scan Table [ city ] Output [ CountryCode , Name ] ; #7 = Join [ #5 , #6 ] Predicate [ #6.CountryCode = #5.CountryCode ] Distinct [ true ] Output [ #6.Name ]")
    , -- 68a7c7be81a8bd9b48f9750cfc34bfa65110ac9eacce30055ad944d8300f8166
      (courseTeach, "#1 = Scan Table [ teacher ] Predicate [ Hometown <> 'little lever urban district' ] Output [ Hometown , Name ]")
    , -- 56d9b7569da6cfd36c31daac378eeebeed9acb76698e67c63f49a3fce4e8d187
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Distinct [ true ] Output [ #1.name ] ; #4 = Scan Table [ Highschooler ] Output [ name , ID ] ; #5 = Scan Table [ Likes ] Output [ liked_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.liked_id = #4.ID ] Distinct [ true ] Output [ #4.name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.name = #6.name ] Distinct [ true ] Output [ #3.name ]")
    , -- 87a14e66e6e77a9297169720ad579f780bf39faa6d4b05b82771e1e62f75d873
      (world1, "#1 = Scan Table [ city ] Predicate [ District = 'gelderland' ] Output [ District , Population ] ; #2 = Aggregate [ #1 ] Output [ SUM(Population) AS Sum_Population ]")
    , -- f2d22804f55d8c9889b17e685d05553725cce3ad4a081019ff11f72de7e9c8f1
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Average , Capacity , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Average DESC ] Output [ Average , Capacity , Name ]")
    , -- c41addc8cbd0fa2c9fcc48cbd0054859755fe0a2789378a6df2c3208334df8e8
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Count_Star ]")
    , -- 4dfb9f3bd2fd30f32394562225b6b6d5eb3ec4532cc089f93fa37897071f826f
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 1e24f527faaaa8d4bbae1ada8b98e945ff2183598b52186f41e56c2ea6b45afa
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Population ] ; #3 = Aggregate [ #2 ] Output [ MIN(Population) AS Min_Population ] ; #4 = Scan Table [ country ] Output [ Continent , Population , Name ] ; #5 = Filter [ #4 ] Predicate [ Continent = 'africa' ] Output [ Population , Name ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.Population < #3.Min_Population ] Output [ #5.Name ]")
    , -- e8547401e95957bca35ed38ffb63b21c97fd2a30d03f18821da27f7671f398df
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , dog_id ] ; #3 = Scan Table [ Treatments ] Output [ dog_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.dog_id = #2.dog_id ] Output [ #2.owner_id ] ; #5 = Aggregate [ #4 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star , owner_id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.owner_id = #1.owner_id ] Output [ #1.last_name , #5.Count_Star , #1.owner_id ] ; #7 = TopSort [ #6 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id , Count_Star , last_name ]")
    , -- 26ad51ff8d130d2aa117e8cb6d7ef07ce38bfbc418daa39207a4140fd1f93afa
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'aruba' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 7e71dfe9b226654ff253bf9928829d6497f2bd6209adea612d4187885a79975a
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Name ] ; #2 = Scan Table [ poker_player ] Output [ People_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.People_ID IS NULL OR #1.People_ID = #2.People_ID ] Output [ #1.Name ]")
    , -- 8a97b1f2dce33f93402760747b78c771827c6f87f26cd8b79c78e074a69bf916
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #2 = Scan Table [ rankings ] Output [ player_id , tours ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.player_id = #1.player_id ] Output [ #1.country_code , #2.tours , #1.first_name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ tours DESC ] Output [ country_code , first_name , tours ]")
    , -- 998f04b839afe54f9a8e1ec684ceb8a3ee1a4ad91dda2611a9867a29391d132c
      (orchestra, "#1 = Scan Table [ show ] Output [ Attendance ] ; #2 = Aggregate [ #1 ] Output [ AVG(Attendance) AS Avg_Attendance ]")
    , -- e6393c117f414da854c082eff60f93bd0300723381b35c6e2b65aaba840d0ea0
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , Country , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'michael chang' ] Output [ Channel , Directed_by ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Distinct [ true ] Output [ #1.Country , #1.series_name ] ; #4 = Scan Table [ TV_Channel ] Output [ series_name , Country , id ] ; #5 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Channel , Directed_by ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Channel = #4.id ] Distinct [ true ] Output [ #4.Country , #4.series_name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.series_name = #6.series_name ] Distinct [ true ] Output [ #3.Country , #3.series_name ]")
    , -- 8ae2a94a239d725b450e3f2319fccfc633f24c3e2b702c94b1e3933c301ff2ea
      (museumVisit, "#1 = Scan Table [ museum ] Output [ Museum_ID , Name ] ; #2 = Scan Table [ visit ] Output [ Museum_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Museum_ID = #1.Museum_ID ] Output [ #1.Name ]")
    , -- f3fa903b24fa8f9dc20a193fcf0256b80e56cd8c75cebe52ed4d28b5badf9486
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Birth_Date , Name ]")
    , -- b969e259f189aeb41d02cf9f2331af01a76604299a70247de3c91c3b863f3aa9
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Predicate [ section_name = 'h' ] Output [ section_description , section_name ]")
    , -- be8751acd82b0091ce91e727267eb60c7b15c95c21bf3d8d9f7e241ed60fd7a3
      (car1, "#1 = Scan Table [ continents ] Output [ Continent , ContId ] ; #2 = Scan Table [ countries ] Output [ Continent ] ; #3 = Aggregate [ #2 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Continent = #1.ContId ] Output [ #1.Continent , #1.ContId , #3.Count_Star ]")
    , -- 2d1ff3bdc9e4e167beb08971a10a8d8d149cc138b1bf5491f2dfdeb69f47e4d2
      (wta1, "#1 = Scan Table [ matches ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8671937b8fca85e18cd7d84da33377f4105cc302be5b0d30e884478c99e61450
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date ] ; #2 = Aggregate [ #1 ] Output [ AVG(transcript_date) AS Avg_transcript_date ]")
    , -- 5f2da74090ff46835a02f0b81d6fba00e4efcc8ddf7d14a503595b0354bdb3b6
      (dogKennels, "#1 = Scan Table [ Charges ] Output [ charge_type , charge_amount ]")
    , -- 66e090db2c6354463561fac293917d6c63cedb67424cde7983e0d0e45c06013f
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Age > 40 ] Distinct [ true ] Output [ Country ] ; #2 = Scan Table [ singer ] Predicate [ Age < 30 ] Distinct [ true ] Output [ Country ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Country = #2.Country ] Distinct [ true ] Output [ #1.Country ]")
    , -- 7d4d00e09ba1ba6a1e7656c6ce0d5484581e271467b204aa8afa2c37ac010302
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Predicate [ Document_Name = 'data base' ] Output [ Document_Name , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ]")
    , -- 2d5af1ae79c1eadb9a64c4e4ee431c883c34d42643e1275086b93079bebd1da4
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'afghanistan' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 1e89d560ac01a52205cd8edb1ad7d22d0084f87bb2d16c76405f82f6eed14cf0
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Fname ] ; #6 = Scan Table [ Student ] Output [ StuID , Fname ] ; #7 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #8 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.PetID = #7.PetID ] Output [ #8.StuID ] ; #10 = Join [ #6 , #9 ] Predicate [ #9.StuID = #6.StuID ] Distinct [ true ] Output [ #6.Fname ] ; #11 = Join [ #5 , #10 ] Predicate [ #5.Fname = #10.Fname ] Distinct [ true ] Output [ #5.Fname ]")
    , -- 6c0f1803add8e16276df518874b943504f46798a505b30fcd496ca3f2a5ef9e3
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Predicate [ department_name = 'engineer' ] Output [ department_name , department_id ] ; #2 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.department_id = #1.department_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 8c8870ec05f32246c5b7955c28f5c81d57e9115f47091d631a393c7bd79a4581
      (singer, "#1 = Scan Table [ singer ] Predicate [ Citizenship <> 'france' ] Output [ Citizenship , Name ]")
    , -- c3d09bbd5ef44b3e809bb09034af2f560f4d623215e8376b9b7c125a7a724849
      (concertSinger, "#1 = Scan Table [ concert ] Predicate [ Year = 2014 OR Year = 2015 ] Output [ Year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- a7077b7a0f70fac078e95093cec8fb26d721a60f9c4c08398d4592e55fcb39c8
      (world1, "#1 = Scan Table [ country ] Output [ Code , Region ] ; #2 = Scan Table [ city ] Predicate [ Name = 'kabul' ] Output [ CountryCode , Name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Region ]")
    , -- e0e10dd96631c9a039a0f6b68747d5eef73a3e9e37063de7381bdd2b09913603
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year , concert_ID ] ; #3 = Scan Table [ singer_in_concert ] Output [ Singer_ID , concert_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.concert_ID = #2.concert_ID ] Output [ #3.Singer_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Singer_ID = #1.Singer_ID ] Output [ #1.Name ]")
    , -- a580c27e04c6eaff182b09c757eac7709d4949a57857163ecf6f41adeb7e5063
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company ] ; #2 = Aggregate [ #1 ] GroupBy [ Record_Company ] Output [ Record_Company , countstar AS Count_Star ]")
    , -- aeab2749108b0a4074f867008a9cbff20796f8cfc0aa1b851851074dc8dbfa2e
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Airline ]")
    , -- ba9ec7f64a81c18e5612e3c60bd1335237118276d50004d9341e44428f26a6b6
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ] ; #4 = Aggregate [ #3 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ]")
    , -- e414d32b5423f613066d3bcdc923aeacd8d20f30e56c3f129024985e74d76087
      (pokerPlayer, "#1 = Scan Table [ people ] Predicate [ Nationality <> 'russia' ] Output [ Nationality , Name ]")
    , -- 173f849d4bec55e9caad720de4a82d892641f70b6b43abbd5c0e7447006ac41b
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Population ASC ] Output [ Population , Name ]")
    , -- ba1ee9f549168c44bb796a2bbdc8075e64e6df7ca595e5b4dd6c3ab0e7dc817c
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.StuID IS NULL OR #1.StuID = #2.StuID ] Output [ #1.Age ] ; #4 = Aggregate [ #3 ] Output [ AVG(Age) AS Avg_Age ]")
    , -- e60783a38fbe587fae22b5119c426af2faa291ec352b32ee73bd46e4d75c0c43
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.grade ] ; #4 = Aggregate [ #3 ] Output [ AVG(grade) AS Avg_grade ]")
    , -- a7b231276cbde5622a0f9f60560e0af1bab62d204e97a49af38c91aa73d0f2c0
      (world1, "#1 = Scan Table [ country ] Predicate [ SurfaceArea > 3000.0 ] Output [ Continent , SurfaceArea , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'north america' ] Output [ SurfaceArea , Population ] ; #3 = Aggregate [ #2 ] Output [ AVG(SurfaceArea) AS Avg_SurfaceArea , SUM(Population) AS Sum_Population ]")
    , -- a72bc94122c8335bb8ef116a28ae80c1bcafdbcf89ef8fca8233fe7a04a89520
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ cell_number , professional_id ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.cell_number , #1.professional_id , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ cell_number , professional_id ]")
    , -- b9856abd94006487ca31911b34964cc7e41c7ac610e84c761ed5d107e75be80b
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Capacity ] ; #2 = Aggregate [ #1 ] Output [ AVG(Capacity) AS Avg_Capacity , MAX(Capacity) AS Max_Capacity ]")
    , -- d4255528f288011bf282f9c70db59fb67c2df7481c80b30ccdb2bb1bb10a28d6
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' ] Output [ Code ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'chinese' ] Output [ IsOfficial , CountryCode , Language ] ; #4 = Filter [ #3 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.CountryCode = #2.Code ] Output [ #2.Code , #4.CountryCode ] ; #6 = Scan Table [ city ] Output [ CountryCode , Name ] ; #7 = Join [ #5 , #6 ] Predicate [ #6.CountryCode = #5.CountryCode ] Distinct [ true ] Output [ #6.Name ]")
    , -- 3ef872547c3c849b72137303c2397e4ddfa5620f0a8444b059405f38009ac1b5
      (voter1, "#1 = Scan Table [ votes ] Output [ state , phone_number , created , contestant_number ] ; #2 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ] ; #3 = Filter [ #2 ] Predicate [ contestant_name = 'tabatha gehling' ] Output [ contestant_number ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.contestant_number = #1.contestant_number ] Output [ #1.state , #1.phone_number , #1.created ]")
    , -- 596abcb0d56950837aea86f86897c9ec4d944f77fb56712c19b06aca08b5ab81
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 7b011cefaa29c94bcd921f109c6aba92f00feeee515a5c416047c8829261c99a
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'customer reviews' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Paragraph_Text , Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text ]")
    , -- 623537054e505047ae01d4aa98e12d75a8df926e1d7b3f51b1846adcd1990150
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 698c94dd60832c69da326ce8bfa2f179b719248703b9e09aa653ebe78a3a67e6
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Distinct [ true ] Output [ #1.Airline ] ; #4 = Scan Table [ airlines ] Output [ uid , Airline ] ; #5 = Scan Table [ flights ] Predicate [ SourceAirport = 'cvo' ] Output [ SourceAirport , Airline ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Airline = #4.uid ] Distinct [ true ] Output [ #4.Airline ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Airline = #6.Airline ] Distinct [ true ] Output [ #3.Airline ]")
    , -- 5f3e14ec082234fc4bddff7754ddeef043a6e8f0f62b789c3def9fb2df884b1e
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Year < 1980 ] Output [ Horsepower , Year ] ; #2 = Aggregate [ #1 ] Output [ AVG(Horsepower) AS Avg_Horsepower ]")
    , -- f69a450ed479db5ca5b690ab618f69a33863fef823c823cb818121c200280fbd
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Country = 'usa' ] Output [ Abbreviation , Country , Airline ]")
    , -- e2659b87d4a1e361b740b5e13188af89e0b4328076dd99f6a06de5b1b94b5523
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Abbreviation = 'ual' ] Output [ Abbreviation , Airline ]")
    , -- 18410d6eea9eaaa4ded15500a3cfd28e14e048a9c0b11d9c6c27f1ebd20ba32c
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Fname ] ; #6 = Scan Table [ Student ] Output [ StuID , Fname ] ; #7 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #8 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.PetID = #7.PetID ] Output [ #8.StuID ] ; #10 = Join [ #6 , #9 ] Predicate [ #9.StuID = #6.StuID ] Distinct [ true ] Output [ #6.Fname ] ; #11 = Join [ #5 , #10 ] Predicate [ #5.Fname = #10.Fname ] Distinct [ true ] Output [ #5.Fname ]")
    , -- c07bf8a5269d2f7e7fb84ce9604b7842d48ec4c1986c122f1982a9ad675efea5
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname , Sex ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Aggregate [ #2 ] GroupBy [ StuID ] Output [ StuID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.StuID = #1.StuID ] Output [ #1.Sex , #1.Fname , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ Sex , Fname ]")
    , -- 402c83aa7e9857cd245b007d9858090ddba77f61656583eb61ff34afc92fa7b2
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Output [ Teacher_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Name ]")
    , -- 8ae45237a4b14c518c470ccdb33ff70e8b3fdd9499e1d452bdde3806f222c183
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Count_Star ]")
    , -- 196aa60352af0cf7e4ef042eadf2f963c0c3073019e762a018959cca24f67b02
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Continent ] ; #4 = Aggregate [ #3 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Continent , Count_Star ]")
    , -- fcffebd3ff6c929d806e7b4ea91b3ad91aa2d65799cc8b9af47caed7c6fb1f68
      (wta1, "#1 = Scan Table [ players ] Output [ hand ] ; #2 = Aggregate [ #1 ] GroupBy [ hand ] Output [ countstar AS Count_Star , hand ]")
    , -- f8570300943103954805da5211d88f9110b2dfd81e138e50b0a6fa6285117742
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Code = 'ad' ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- 728498cf775875068b9bab8aa842056887ff0d7f89672525110cc65529a4fbef
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.student_id ] Output [ #1.student_id , #1.first_name , #1.last_name , #3.Count_Star , #1.middle_name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 2 ] Output [ student_id , first_name , middle_name , last_name ]")
    , -- 53552c392e22e333152e2693ed0474d4840881992fc15562e483b439b6782b5d
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Code = 'ad' ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- 16757dcf685a956d81ea88dce3aeca959bb39b0e7f5823e1d244ec45b8dc1448
      (car1, "#1 = Scan Table [ car_makers ] Predicate [ FullName <> 'ford motor company' ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ cars_data ] Predicate [ Weight < 3500 ] Output [ Id , Weight ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #4.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #2.Model , #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #6.Model ]")
    , -- 5ad21a316fc1e48c6d44ed5198b1070d3760ce48bfd31f752d8ed9e39bd2f980
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Document_ID = #1.Document_ID ] Output [ #1.Document_Name , #3.Count_Star , #3.Document_ID ]")
    , -- cf7eea7b6f50c57390d38c86939bf535a224b057c31c25a666208629c5ce7a00
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Name ] ; #5 = Scan Table [ country ] Output [ Code , Name ] ; #6 = Scan Table [ countrylanguage ] Predicate [ Language = 'french' ] Output [ IsOfficial , CountryCode , Language ] ; #7 = Filter [ #6 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #8 = Join [ #5 , #7 ] Predicate [ #7.CountryCode = #5.Code ] Distinct [ true ] Output [ #5.Name ] ; #9 = Join [ #4 , #8 ] Predicate [ #4.Name = #8.Name ] Distinct [ true ] Output [ #4.Name ]")
    , -- 75f66dc81cbf3a3f27d33d5d675fd43a1794de57f3234cbc274fa97f50765b86
      (network1, "#1 = Scan Table [ Friend ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ]")
    , -- ba118082f2f696e0f2bc26b33b647f0029b62f4d0e51713ae5858279f600f595
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f13ab0950e935045b8c2cf6da9d54577f46a2563067fbd21c9f82411262a20ba
      (world1, "#1 = Scan Table [ country ] Output [ Code , Region ] ; #2 = Scan Table [ city ] Predicate [ Name = 'kabul' ] Output [ CountryCode , Name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Region ]")
    , -- 1b4a7a6a4a6edbd99f288bea34b33440647837c357c6aaea4af04799805c576e
      (wta1, "#1 = Scan Table [ matches ] Predicate [ tourney_name = 'wta championships' AND winner_hand = 'l' ] Distinct [ true ] Output [ winner_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT winner_name) AS Count_Dist_winner_name ]")
    , -- 550e5e82df704280579aec36cce4557a6a0a38b91cf057b63a589c368210022a
      (singer, "#1 = Scan Table [ singer ] Predicate [ Citizenship <> 'france' ] Output [ Citizenship , Name ]")
    , -- 7ddb8484384a410a4ee334b2add390a2c95c81ba0d19f7b4fce4db288fef6f2b
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Continent ] ; #4 = Aggregate [ #3 ] GroupBy [ Continent ] Output [ Continent , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Continent , Count_Star ]")
    , -- 442a4d8280938cee442476698a6d9ec2f0f13c4983f75bd715496be8f10bb3ef
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ grade , Count_Star ]")
    , -- 0a0317dc30dddb0490383d219a1b1f2002d1ff2a27e96ed69090c468a73e9bcb
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ Name , Age , ID ] ; #2 = Scan Table [ visit ] Output [ visitor_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ visitor_ID ] Output [ countstar AS Count_Star , visitor_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.visitor_ID = #1.ID ] Output [ #1.Age , #1.ID , #1.Name , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ Name , Age , ID ]")
    , -- 5ef06542a1781f98163159be9c68e3f95ece37b1693cc50f7cbc6bb37dbda369
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #2 = Scan Table [ city ] Output [ Population , CountryCode , Name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #2.Population , #2.Name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Population DESC ] Output [ Population , Name ]")
    , -- 2889806e9f7d6a3170472334db0059bddb62f3b27c327d85fcbe1953a3a5bb12
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'cv' ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 07a63f1a5bc074a87b3ef04fa8dda9f595a429c36cc22af4b69b862e7c6ec7bf
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 3 ] Output [ name ]")
    , -- ed11ccc0c371befb3ffe3ea94cf16a1727cea5fdbd0c2379b78d4891bcd8f1a9
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , Horsepower ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower ASC ] Output [ Horsepower , Model ]")
    , -- 48d4d88081a41b0892197a3c9aa93eac81e0a2158d60ea3843a175b0f2b053c0
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'summer show' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 753b0e7cd97e2a2870fcc6afa6c4512421986fad6e8ffc72c01b48e16e203d9d
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ AVG(age) AS Avg_age ]")
    , -- 8bdd139d26705091a90878940a67335d43bde42567b0dbcd021c9dd118a84d20
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #2.Course , #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name , #4.Course ]")
    , -- effadf8df6dc99841f6c5970c502b75ffa1c1763e6c4dbecda029eb47c339b71
      (world1, "#1 = Scan Table [ country ] Output [ LifeExpectancy , GovernmentForm , Population ] ; #2 = Aggregate [ #1 ] GroupBy [ GovernmentForm ] Output [ SUM(Population) AS Sum_Population , AVG(LifeExpectancy) AS Avg_LifeExpectancy , GovernmentForm ] ; #3 = Filter [ #2 ] Predicate [ Avg_LifeExpectancy > 72.0 ] Output [ GovernmentForm , Sum_Population ]")
    , -- 950b12210f92f7fe8accf0f9ee01cdde5d5eddbb4ee55d11c62f35fcbd04a945
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age , Song_release_year , Song_Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age ASC ] Output [ Age , Song_release_year , Song_Name ]")
    , -- 76aabb0a0ad501bbb8c847b9056b539fcd3780a5c7da5f754aee2fc436378746
      (world1, "#1 = Scan Table [ country ] Predicate [ HeadOfState = 'beatrix' ] Output [ HeadOfState , Code ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode , Language ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ #3.Language ]")
    , -- de129d84d27db6a0fb572077f40706c07205c6e5de0feaa6dda6ccf452c57217
      (museumVisit, "#1 = Scan Table [ museum ] Predicate [ Name = 'plaza museum' ] Output [ Name , Open_Year , Num_of_Staff ]")
    , -- 1285a88105c026db53a8c6bc8a43ea895a25c3eef88da5796b307750abd1692f
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Singer_ID IS NULL OR #1.Singer_ID = #2.Singer_ID ] Output [ #1.Name ]")
    , -- 7724849737aab7b098851c89a0fd1ee146c0b00594fc5f0f2b2f6789ce855c51
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 8 AND Year = 1974 ] Output [ Weight , Year , Cylinders ] ; #2 = Aggregate [ #1 ] Output [ MIN(Weight) AS Min_Weight ]")
    , -- e14b091525b0605611e8ca7329ecc05141580545c11b68d81e0d40d9b9eed55f
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ]")
    , -- a1bf2d8958be8dd95641c593f66002a2c88d11a9c30eb564d954c166ea5ddb70
      (pokerPlayer, "#1 = Scan Table [ people ] Predicate [ Height > 200.0 ] Output [ People_ID , Height ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Earnings ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #2.Earnings ] ; #4 = Aggregate [ #3 ] Output [ AVG(Earnings) AS Avg_Earnings ]")
    , -- 7e07965719bdc4b883c84663dcc9b66ffdf2d7e962e4fcf8cebbdc95bad61b70
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #4 = Scan Table [ cars_data ] Output [ Id , Weight ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Id = #3.MakeId ] Output [ #4.Weight , #3.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #5.Weight , #2.Model , #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #6.Model ]")
    , -- 67897312488350728a9012ddf25e860149ea5ed4025d589030cc862639fddb39
      (world1, "#1 = Scan Table [ country ] Output [ Code , Region ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'dutch' OR Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Region ]")
    , -- e7fa38db30c3db68836b1449b6438e029192143eb94fa382df17ec3e016760e1
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings ] ; #2 = Aggregate [ #1 ] Output [ AVG(Earnings) AS Avg_Earnings ]")
    , -- ad9d7210fdfd7165816e6492d93dd1e6f8473cf6c35e401f46ded2de93952e94
      (flight2, "#1 = Scan Table [ airports ] Predicate [ AirportName = 'alton' ] Output [ City , AirportName , Country ]")
    , -- 41d3e92c786b0b23ab2969a8beed1284689a19b42473d98e6fdd654c6b4f7a2a
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Location , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Stadium_ID , Year ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Distinct [ true ] Output [ #1.Name , #1.Location ] ; #4 = Scan Table [ stadium ] Output [ Stadium_ID , Location , Name ] ; #5 = Scan Table [ concert ] Predicate [ Year = 2015 ] Output [ Stadium_ID , Year ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Stadium_ID = #4.Stadium_ID ] Distinct [ true ] Output [ #4.Location , #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ #3.Location , #3.Name ]")
    , -- bd4233682bf105762e3a9cb82f6a771c3ebd7fdecb6567ca4cce013ad6c9bbdf
      (network1, "#1 = Scan Table [ Highschooler ] Distinct [ true ] Output [ name ] ; #2 = Scan Table [ Highschooler ] Output [ name , ID ] ; #3 = Scan Table [ Friend ] Output [ student_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.student_id = #2.ID ] Distinct [ true ] Output [ #2.name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.name = #4.name ] Output [ #1.name ]")
    , -- d5a39686bba741ef689bc307f2c36a0afe1e3e7005626c834320c78d825a40e5
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Nationality ]")
    , -- 67ad6ffc709d3e44ff5f84c9af0a4d2e16a89919d6c6f723b770165a6314e930
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , id ] ; #2 = Scan Table [ Cartoon ] Output [ Title , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #2.Title ]")
    , -- f23d812f404ef6bef6297f48075b5a591f9c60c9f97f36861c9b5abce2350a5f
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryId , #1.CountryName , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ CountryId , CountryName ] ; #6 = Scan Table [ model_list ] Predicate [ Model = 'fiat' ] Output [ Model , Maker ] ; #7 = Scan Table [ car_makers ] Output [ Id , Country ] ; #8 = Join [ #6 , #7 ] Predicate [ #7.Id = #6.Maker ] Output [ #7.Country ] ; #9 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #10 = Join [ #8 , #9 ] Predicate [ #9.CountryId = #8.Country ] Output [ #9.CountryId , #9.CountryName ] ; #11 = Union [ #5 , #10 ] Output [ #5.CountryName , #5.CountryId ]")
    , -- 50c5d19b474f0dd61efdf6f2d8172cfb693e85bb6d2ee13d375870cddfb4fbac
      (network1, "#1 = Scan Table [ Highschooler ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 329f0c5f35657ebf6607ade381231dcb736e68b0a28915213b0fd689088299d5
      (network1, "#1 = Scan Table [ Highschooler ] Output [ ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.ID ]")
    , -- f1cf3d5bc498895a312f9d97a3c23ed602f4cb8b41f09d88666d37f56f9a4c4b
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company ] ; #2 = Aggregate [ #1 ] GroupBy [ Record_Company ] Output [ Record_Company , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Record_Company , Count_Star ]")
    , -- 04d01fafdfe0a2fc87f5e6a971770df71d346fe8153bd78a6c9fa41da7e500a4
      (car1, "#1 = Scan Table [ countries ] Predicate [ CountryName = 'usa' ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Id , Country ] ; #3 = Scan Table [ model_list ] Output [ Maker ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Maker = #2.Id ] Output [ #2.Country ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Country = #1.CountryId ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- 661e9a7253223a3ccb079a380550a1278fa81e2f92a8f848c1fe944b04d916e2
      (flight2, "#1 = Scan Table [ flights ] Predicate [ DestAirport = 'apg' ] Output [ DestAirport , FlightNo ]")
    , -- c1fd6f38135cfcb534461b08b25144826b8cbc55904aa39bf3f6cb55a584b206
      (flight2, "#1 = Scan Table [ flights ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 187a9dfd630ef2d10c685b291d0f05840d8d172803e5dede4b1dfcd226fa7f5e
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Age , Name ]")
    , -- 99902bf465647b9de71fa5b3a255675bf1cf550f6095bced50a1103e60932e10
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ city = 'port chelsea' ] Output [ zip_postcode , city ]")
    , -- 11df8747ba360172906df15c76c2aa949c4feade99a36210c6558fd502edde93
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders > 4 ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6ae399e06f0727c2e17b66033a479df7c995fb6126ac67372fe9c15c6a115c23
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_products ] ; #2 = Aggregate [ #1 ] Output [ MIN(Number_products) AS Min_Number_products , MAX(Number_products) AS Max_Number_products ]")
    , -- 804c8e18ba30e708d50724b2884ec025fcc5e03cf2f010b2e756c50555cf7bb3
      (singer, "#1 = Scan Table [ singer ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- d3843868bf41d4824aeaf42e48f823c66c1cddefe42f17b1af2797eb10d4404a
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings , Money_Rank ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Earnings DESC ] Output [ Earnings , Money_Rank ]")
    , -- 59affccbb588b409c985a1028b9e13bd2266620f0fdf99638a6fbb8439490855
      (car1, "#1 = Scan Table [ car_names ] Output [ Model ] ; #2 = Aggregate [ #1 ] GroupBy [ Model ] Output [ countstar AS Count_Star , Model ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Model , Count_Star ]")
    , -- 5233ddd186d5ebb3489169e89600027c8bd742e7e796b95faebfacd2c2a6b3ea
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Distinct [ true ] Output [ Template_Type_Code ]")
    , -- e968c73bf4c0d4b6fa12af529a4c949f561b0a51ef8510f0029c9dee84948ba4
      (concertSinger, "#1 = Scan Table [ singer ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 6b818bfc5b7ecb4ae741d03d4ff61323fd33d7453db6ca50c0b0a72664470020
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Distinct [ true ] Output [ department_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 4a689d6560058bdd8adf9567862f41d9fd0787c77beb5f837b9b44c155a76705
      (world1, "#1 = Scan Table [ country ] Output [ IndepYear , Population , SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Population ASC ] Output [ IndepYear , Population , SurfaceArea , Name ]")
    , -- 5b137f43eb6a56ae4d554a5fbf6b1f1ad7fa607e9bad79dfc2d4daaba0ebdc2e
      (voter1, "#1 = Scan Table [ contestants ] Output [ contestant_number ] ; #2 = Scan Table [ votes ] Output [ contestant_number ] ; #3 = Except [ #1 , #2 ] Predicate [ #1.contestant_number IS NULL OR #2.contestant_number IS NULL ] Output [ #1.contestant_number ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 99d01cadde9a3a585cfb95149c86e586e956c4807f67adea88f25cac11d941cf
      (singer, "#1 = Scan Table [ singer ] Output [ Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ countstar AS Count_Star , Citizenship ]")
    , -- 1e42d2900c9e527b66357dcab22aba24c3b4847d0413b659e3577639518175f7
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'aruba' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ Percentage , CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Percentage , #2.Language ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Percentage DESC ] Output [ Percentage , Language ]")
    , -- b5f8586908d9c60a605f91dcdce8a372301ffec88f551fc7611f66e2e04a5840
      (world1, "#1 = Scan Table [ city ] Output [ Population ] ; #2 = Aggregate [ #1 ] Output [ AVG(Population) AS Avg_Population ] ; #3 = Scan Table [ city ] Output [ District , Population ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Population > #2.Avg_Population ] Output [ #3.District ] ; #5 = Aggregate [ #4 ] GroupBy [ District ] Output [ District , countstar AS Count_Star ]")
    , -- 295988b244a1dd78a84417dd6e2054e99798ab87f1f153e3cae281c302e1c32e
      (wta1, "#1 = Scan Table [ players ] Predicate [ hand = 'l' ] Output [ birth_date , first_name , hand , last_name ]")
    , -- f43bc5903436fd6a4ae16ce9b91ac3a7775e605b398c5ad823d597286507bbf1
      (voter1, "#1 = Scan Table [ area_code_state ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- b502c155fba512cabb54000e371ee35e6737c6de75d89889c83254465c86e8c4
      (car1, "#1 = Scan Table [ car_makers ] Predicate [ FullName <> 'ford motor company' ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ cars_data ] Predicate [ Weight < 3500 ] Output [ Id , Weight ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #4.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #2.Model , #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #6.Model ]")
    , -- a0d50025a0dacc9b581e55f5d52ab1998a2dbf2f8f5f5d67a453d729b68fa414
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Population DESC ] Output [ Population , Name ]")
    , -- ffae8b56f4857f97c781656cf84ccfa69b2b5afec94b6ada88e32db83cf75a0d
      (concertSinger, "#1 = Scan Table [ singer ] Predicate [ Song_Name like '% hey %' ] Output [ Country , Song_Name , Name ]")
    , -- db4fbaa64e0ce68cfcc60c590b0bb1bff812a2a61390293307fba0d9cf1d1be2
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ line_1 , line_2 ]")
    , -- a2a172d7d2a542d70069554cde5ff036f577151c427f34994ab64326401a47dc
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ treatment_type_code , cost_of_treatment ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.treatment_type_code = #1.treatment_type_code ] Output [ #2.cost_of_treatment , #1.treatment_type_description ]")
    , -- 3a3c210329f066c16ae725a134bcf591f4cb70fa224a580ef0a2c17a0f9f0c2a
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcript_Contents ] Output [ student_course_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_course_id ] Output [ countstar AS Count_Star , student_course_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ student_course_id , Count_Star ]")
    , -- 8b33d8ebee3c820fd9c6f45fa6f76eeda92b42b72cc32487f29cfa4b79175f7b
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ state = 'indiana' ] Output [ state , cell_number , professional_id , last_name ] ; #2 = Scan Table [ Professionals ] Output [ cell_number , professional_id , last_name ] ; #3 = Scan Table [ Treatments ] Output [ professional_id ] ; #4 = Aggregate [ #3 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.professional_id = #2.professional_id ] Output [ #4.Count_Star , #2.last_name , #2.cell_number , #2.professional_id ] ; #6 = Filter [ #5 ] Predicate [ Count_Star > 2 ] Output [ cell_number , professional_id , last_name ] ; #7 = Union [ #1 , #6 ] Output [ #1.last_name , #1.professional_id , #1.cell_number ]")
    , -- e55c321fe2277cb22a4cdb52e32820d830e29d08212b93e1f6ed54a5c0f64e43
      (museumVisit, "#1 = Scan Table [ visitor ] Predicate [ Level_of_membership <= 4 ] Output [ Age , Level_of_membership ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age ]")
    , -- 9185b99e6274a74f1074d9390674f68dc176f3bd9f95bc67ad3b09b878fccc3a
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , FullName ]")
    , -- 8dcbaac89354f86302d6a16bc620ce64674b57a5369eb808b45bf41afe1560de
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ singer_in_concert ] Output [ Singer_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Singer_ID ] Output [ Singer_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #3.Count_Star ]")
    , -- 1d2463926c06c0b305d781cd6e0713784fbcac3498b19ded257d886e67364acc
      (world1, "#1 = Scan Table [ country ] Predicate [ HeadOfState = 'beatrix' ] Output [ HeadOfState , Code ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode , Language ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Output [ #3.Language ]")
    , -- bc82973d8a4f671f6ef6a3b4e3a994c811d7f72d0410a6437d4195f8c5b8a0ce
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age ] ; #2 = Aggregate [ #1 ] Output [ AVG(Age) AS Avg_Age ] ; #3 = Scan Table [ singer ] Output [ Age , Song_Name ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Age > #2.Avg_Age ] Output [ #3.Song_Name ]")
    , -- aaea944f7fbfe65c0aa2473b9e9ade93b8f024fc0c932efc0b05d3c9fe2cd13f
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- baa9a1483242a0a237f97714d50d97a1b5a523b10b592594eae08f5e9e0280e6
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , birth_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ birth_date ASC ] Output [ country_code , first_name , birth_date ]")
    , -- 073332a5fd4d410cbe407ca5590f3591cff693649f96109da43bc8619671d08b
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] GroupBy [ Nationality ] Output [ countstar AS Count_Star , Nationality ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Nationality ]")
    , -- 9e1d5ef6745da75269f01f2394f4be8f88a36f0f2f1760c4d6dd46ebc23dec81
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_products ] ; #2 = Aggregate [ #1 ] Output [ MIN(Number_products) AS Min_Number_products , MAX(Number_products) AS Max_Number_products ]")
    , -- b2964fe5bd1fd23fa2bcdde07996f8745f21fd16c8c9228fced51de099028872
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ weight > 10.0 ] Output [ weight ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- bd50cd3346fb9f7ff49fe956873de002222ca6019f59ecc9c76a1e5b989eb493
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Weight ] ; #3 = Aggregate [ #2 ] Output [ AVG(Weight) AS Avg_Weight ] ; #4 = Scan Table [ cars_data ] Output [ Id , Weight ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Weight < #3.Avg_Weight ] Output [ #4.Id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.Id = #1.MakeId ] Output [ #1.Model ]")
    , -- fbac0a412afaaebdda79a93fc97de8b3c3e4f837db81219eb1e3f4c895f50186
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Horsepower > 150.0 ] Output [ Horsepower ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- d6d0dc5db8b689d4c0ac7ea1f9baae2fc6d0363c22531ceab894610838fbd534
      (wta1, "#1 = Scan Table [ matches ] Output [ winner_rank ] ; #2 = Aggregate [ #1 ] Output [ AVG(winner_rank) AS Avg_winner_rank ]")
    , -- 2531b53784175464db3290bd4ce5272d913cecfecb1ae586d9d36047e4493035
      (world1, "#1 = Scan Table [ city ] Predicate [ Population >= 160000 AND Population <= 900000 ] Output [ Population , Name ]")
    , -- 9fb99b3230c59f8e93e31e9f3330ec2ef766cee0661a5362446bccfa564a4dc5
      (dogKennels, "#1 = Scan Table [ Owners ] Distinct [ true ] Output [ state ] ; #2 = Scan Table [ Professionals ] Distinct [ true ] Output [ state ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.state = #1.state ] Distinct [ true ] Output [ #1.state ]")
    , -- de87fcf74f2799bbaa79f8e759e47daa3b68377e6f8715ad9ca101b761546bed
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ airports ] Predicate [ City = 'ashley' ] Output [ City , AirportCode ] ; #3 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.DestAirport = #2.AirportCode ] Output [ #3.SourceAirport ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.SourceAirport = #1.AirportCode ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- bb647a855ae3fa4248d333184af9d583778c8243f925a40ea45b59085a0376b2
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ age , owner_id ] ; #3 = Filter [ #2 ] Predicate [ age IS NOT NULL ] Output [ age , owner_id ] ; #4 = Top [ #3 ] Rows [ 1 ] Output [ owner_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.owner_id = #1.owner_id ] Output [ #1.last_name ]")
    , -- ea75910ba3afc10a0d59dae128d0c75acb7487d6b9222ffa99e6fdc28fa60845
      (wta1, "#1 = Scan Table [ matches ] Output [ year ] ; #2 = Aggregate [ #1 ] GroupBy [ year ] Output [ countstar AS Count_Star , year ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ year , Count_Star ]")
    , -- d0a296f1837c86b98749f120148d725826c46b39b052aeb796e95d08240be359
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id ] ; #3 = Aggregate [ #2 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star , degree_program_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.degree_program_id = #1.degree_program_id ] Output [ #1.degree_summary_name , #1.degree_program_id , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_summary_name , degree_program_id , Count_Star ]")
    , -- aa943ef5c6203ba597019088c094ed685eea371be148c25ce154a9b373dc2c15
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders > 6 ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- e90ca10d3b801905b62e731b28f241b782967b8d2548e1057d546192c2a51a80
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 3 ] Output [ Template_Type_Code ]")
    , -- 2a8ea35ad7f723889d27b267bef72d3992a72b5dba5bd3d7c127682db1db41aa
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ dog_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 66ca5dbbeaf6330e1e4962deede1ffbb618a38a3ed59cf7c08d11c553f1497cb
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Aggregate [ #2 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star , owner_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.owner_id = #1.owner_id ] Output [ #3.owner_id , #1.last_name , #3.Count_Star , #1.first_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ first_name , owner_id , Count_Star , last_name ]")
    , -- eafbe8022e6e84b49effffba29e56d289b5d1e4c269a3c3933fb377ba09b6cb9
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Country ] ; #2 = Aggregate [ #1 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ]")
    , -- cbc8c9742f9ae63285f58dd8ef3664a68b1c4c9ca8cbd40a5b1fec608cd59749
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , pet_age ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ pet_age ASC ] Output [ weight , pet_age ]")
    , -- 30d1ee42433721023f9e094e933c912d93f73b99e7b74ebcee784b5b31fe5f57
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 4 ] Output [ Cylinders , MPG ] ; #2 = Aggregate [ #1 ] Output [ AVG(MPG) AS Avg_MPG ]")
    , -- 1945cc8311cc7faaa4f993120e9e91e02ec404f2dd194708081e7ac521de00ba
      (orchestra, "#1 = Scan Table [ conductor ] Distinct [ true ] Output [ Nationality ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Nationality) AS Count_Dist_Nationality ]")
    , -- 287c13b7cc426c370cd220879683109522739aad32877db06c470639a03a973a
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Output [ Teacher_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ]")
    , -- 94c692894c8dd9304581db7b6d26ff3423973cb28e3474fb0a4dc1d552bbfe43
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Distinct [ true ] Output [ current_address_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- caa8cc9af95a5c1b20b0bf682fe3c0c874b0f7df744592b557c3a30bbd608e52
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Distinct [ true ] Output [ Teacher_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- 5ebbb73a6afdbdb2974b2656c82d7299272d0e92e8831f62b3bbdbf3c4f63d21
      (flight2, "#1 = Scan Table [ flights ] Predicate [ DestAirport = 'ato' ] Output [ DestAirport ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 327bca9bb7bc2bad6f1c5c3550a309028f5d3855e7c1ec6922cdd503aa6bd187
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Distinct [ true ] Output [ Channel ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.id ]")
    , -- a53c60a49b1ef48137085af23de337bbc821e26eccb3bd759ba8ce5fcfc931ff
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport , FlightNo ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ #2.FlightNo ]")
    , -- ca57dfe053d7730d47f8a7dec696ff0bffb0c4a5ae2eddc518636c0a9cc93899
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company ] ; #2 = Aggregate [ #1 ] GroupBy [ Record_Company ] Output [ Record_Company , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Record_Company , Count_Star ]")
    , -- 2968bd140b8f572b292b72b93f380074b261e095b014111d7e34b5be584a0735
      (flight2, "#1 = Scan Table [ flights ] Predicate [ SourceAirport = 'apg' ] Output [ SourceAirport , FlightNo ]")
    , -- 751312a14e1b895457b1e3416dd352a7abcadef9679147be4cb3252af11101a7
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Distinct [ true ] Output [ #1.name ] ; #4 = Scan Table [ Highschooler ] Output [ name , ID ] ; #5 = Scan Table [ Likes ] Output [ liked_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.liked_id = #4.ID ] Distinct [ true ] Output [ #4.name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.name = #6.name ] Distinct [ true ] Output [ #3.name ]")
    , -- 2a3bb875beae5ee8230f21a90839bb7547486bd15cf8d6b567e659b137669342
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ FlightNo , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #2.FlightNo ]")
    , -- 6bbd055316a1a875b11f3caec173eb5a08b28dcebb6f61a5fb6c67d187d5d415
      (orchestra, "#1 = Scan Table [ show ] Output [ Attendance ] ; #2 = Aggregate [ #1 ] Output [ AVG(Attendance) AS Avg_Attendance ]")
    , -- 3356268778a1d181ee966ca9d917f094aa438755a17a6c70463309f229a4dcff
      (battleDeath, "#1 = Scan Table [ battle ] Output [ date , name ]")
    , -- 3941c44dd86826e64780268e4986fd9beabdcb24cc002665fe4249303f2d9fd1
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Sections ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Output [ #1.course_id , #1.course_name ] ; #4 = Aggregate [ #3 ] GroupBy [ course_id ] Output [ course_id , course_name , countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star <= 2 ] Output [ course_id , course_name ]")
    , -- 527a89df62df5b27b7fecaaec5caaac757cd54ef07aacbae2576450a55d385b0
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text = 'brazil' ] Distinct [ true ] Output [ Document_ID ] ; #2 = Scan Table [ Paragraphs ] Predicate [ Paragraph_Text = 'ireland' ] Distinct [ true ] Output [ Document_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Document_ID = #2.Document_ID ] Distinct [ true ] Output [ #1.Document_ID ]")
    , -- ee422562896a77aa11e6c9ce20da92a2899b4cc499fba146b5cdd42528824b2b
      (orchestra, "#1 = Scan Table [ orchestra ] Predicate [ Year_of_Founded < 2003.0 ] Distinct [ true ] Output [ Record_Company ] ; #2 = Scan Table [ orchestra ] Predicate [ Year_of_Founded > 2003.0 ] Distinct [ true ] Output [ Record_Company ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.Record_Company = #2.Record_Company ] Distinct [ true ] Output [ #1.Record_Company ]")
    , -- f290992f9d25245881047abb0c5a8fa75425fa9fa94cedc433334874825ed374
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Predicate [ Age < 30 ] Output [ City , Age ] ; #2 = Aggregate [ #1 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 1 ] Output [ City ]")
    , -- a43b9140724231649b4ddbab7229b1aa922a38418117b56994c953b9d5eaa96c
      (tvshow, "#1 = Scan Table [ Cartoon ] Output [ Title ]")
    , -- eded0e3c6d25bb3895cd6104eb9495428d4b8d1a9186de3ce6786eedecc9a792
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name , owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #2.name , #1.first_name ]")
    , -- a7a22869d73d48865b3babbf4cd9a658bca2148ab089e5178ccbfef3547536fb
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Document_ID = #1.Document_ID ] Output [ #1.Document_Name , #3.Count_Star , #3.Document_ID ]")
    , -- af31c2dbac0d1ab65d2339c0d55235dc257c160e670af45309e001bba3098cdd
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Professionals ] Output [ first_name , professional_id ] ; #3 = Scan Table [ Treatments ] Output [ treatment_type_code , professional_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.professional_id = #2.professional_id ] Output [ #2.first_name , #3.treatment_type_code ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.treatment_type_code = #1.treatment_type_code ] Distinct [ true ] Output [ #4.first_name , #1.treatment_type_description ]")
    , -- e75d3a7f87b0a33d06fce6ca17196f4c588fc1be645276004b8fc026e5de12d8
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID , Title ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #2.Title ]")
    , -- c8b3aede5aace8a4d0ece8d034f406ef98bd0e2a5d513ececdba72e3acb31d3e
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'pp' OR Template_Type_Code = 'ppt' ] Output [ Template_Type_Code , Template_ID ]")
    , -- 8d8d7be0915ab938d82fc0dc6b68687fa8a87c94b363531168932afc2034e978
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Output [ #1.course_name ] ; #4 = Aggregate [ #3 ] GroupBy [ course_name ] Output [ course_name , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ course_name , Count_Star ]")
    , -- 4e2a3009bf1eeef36db8e5fde67079e87dc569572f0683cc2aa31d95e6f5b471
      (car1, "#1 = Scan Table [ cars_data ] Output [ Accelerate , Cylinders ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ MAX(Accelerate) AS Max_Accelerate , Cylinders ]")
    , -- 3d3eca8148eb50a89b259e7e52852f0bc74562a78e97347bc1fabc4ccd9f2592
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'welcome to ny' ] Output [ Document_Name , Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Paragraph_ID , Document_ID , Paragraph_Text ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text , #2.Paragraph_ID ]")
    , -- d080be18c27371378e9624a6372e8ba0e7e9f9cde4f841e863a6a2a3aa5ea890
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Shop_ID IS NULL OR #1.Shop_ID = #2.Shop_ID ] Output [ #1.Name ]")
    , -- d4a90c1eaa15edba9a6d3920f3e16b7bfa906ace797d675ad139dd1f1982ae08
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Shop_ID = #1.Shop_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ]")
    , -- ea3eaa087a14e4f6fc7c7c334cff9088ec99f3d6c4c5e9da66d1ce24146ede11
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ professional_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- e216cdd1ff98c38427880127f0d408f230492aace2ab20e4d7e13def209ba0cf
      (concertSinger, "#1 = Scan Table [ stadium ] Distinct [ true ] Output [ Name ] ; #2 = Scan Table [ stadium ] Output [ Stadium_ID , Name ] ; #3 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Stadium_ID , Year ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Stadium_ID = #2.Stadium_ID ] Distinct [ true ] Output [ #2.Name ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.Name = #4.Name ] Output [ #1.Name ]")
    , -- 661ea27e7e8bc59503dbef3470b98ed3b9d917be0339f18d8dcb7f4268ed669f
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id , last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , dog_id ] ; #3 = Scan Table [ Treatments ] Output [ dog_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.dog_id = #2.dog_id ] Output [ #2.owner_id ] ; #5 = Aggregate [ #4 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star , owner_id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.owner_id = #1.owner_id ] Output [ #1.last_name , #5.Count_Star , #1.owner_id ] ; #7 = TopSort [ #6 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id , Count_Star , last_name ]")
    , -- 36adc0f401efd9e40060af9ac99b36de507b24338108ea1174f7e522094865df
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ email_address , professional_id , role_code ] ; #2 = Scan Table [ Professionals ] Output [ email_address , professional_id , role_code ] ; #3 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.professional_id = #2.professional_id ] Output [ #2.role_code , #2.email_address , #2.professional_id ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.professional_id = #4.professional_id ] Output [ #1.professional_id , #1.role_code , #1.email_address ]")
    , -- b4bf1579616f30d8191511ad0538c28b203ba0c36abbed3cf7d6fb7af1590c25
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Language , Count_Star ]")
    , -- c3597c57608e6709f8aa5590f37792720cf006026f950415914855999b49a2dc
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date ] ; #2 = Aggregate [ #1 ] Output [ AVG(transcript_date) AS Avg_transcript_date ]")
    , -- 653a2932fa46003787be8119d8beaab1ef997a5cf04809f7712481e7ffdecd2d
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_ID ] ; #2 = Scan Table [ Documents ] Distinct [ true ] Output [ Template_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_ID ]")
    , -- 7571db72eb5bba0f37d0be25e316684fb2c1e9f8c7b68a7a4d919a83bb7e09fa
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'robbin cv' ] Output [ Document_Name , Document_Description , Template_ID , Document_ID ]")
    , -- 9b93bef7838b4084eaaadeee2fb378c1b0abb129005052733376c12410782d8f
      (car1, "#1 = Scan Table [ model_list ] Output [ Model , Maker ]")
    , -- 1bd94e2f18aa0acb7fb193440870a60c58d392889f7f5282908b639d56d1d35e
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_id , course_name ] ; #2 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.course_id = #1.course_id ] Output [ #1.course_name ] ; #4 = Aggregate [ #3 ] GroupBy [ course_name ] Output [ course_name , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ course_name , Count_Star ]")
    , -- 3527f8c88c2c02b87402400adb4ca1df78d5a8ed8137a2e68e5ae161490f83b2
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Height ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Money_Rank ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #2.Money_Rank , #1.Height ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Height DESC ] Output [ Height , Money_Rank ]")
    , -- a1fb0df29395bbcc497b10676e7f0fcc9e1a41b4362640374d47995c3510d7a2
      (world1, "#1 = Scan Table [ country ] Output [ Continent , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ SurfaceArea ] ; #3 = Aggregate [ #2 ] Output [ MIN(SurfaceArea) AS Min_SurfaceArea ] ; #4 = Scan Table [ country ] Output [ SurfaceArea , Name ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.SurfaceArea > #3.Min_SurfaceArea ] Output [ #4.Name ]")
    , -- 79080aff1d071f0394c8b61de5cf2fff5f294694291ca094959f8b8e56a97e01
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Description = 'book' ] Output [ Template_Type_Code , Template_Type_Description ]")
    , -- 967c3c6ebe4369045d9dde46ef6cc5d3dad46a05783e44a3d183ee2c1b3b1d59
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ city like '% west %' ] Output [ state , role_code , street , city ]")
    , -- 312ecca6914f2c420ffd5f838287d2bd37e5588d4adca8b138affdbf865a7f5c
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Title = 'the rise of the blue beetle !' ] Output [ Title , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.series_name ]")
    , -- 845de45b965c3b3970089c390863ec33e835ecd3505b2b6734403f82f9483f47
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' OR Directed_by = 'brandon vietti' ] Output [ Title , Directed_by ]")
    , -- 64753597dc7d6d2a32db6eda3baa31e7ee2d2fb6ecd4b920fe5b970040457805
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.Country ]")
    , -- f0e91e76e174c126de5c9c0d6245a9120aaa03ae0ff59b30f94247798be5350f
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Hight_definition_TV = 'yes' ] Output [ Package_Option , series_name , Hight_definition_TV ]")
    , -- e24d36718f19f2c01300c0eb31b9ef1c7049290a48400f756e3898c3de1ba7cd
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Student ] Output [ StuID ] ; #3 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #4 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.PetID = #3.PetID ] Output [ #4.StuID ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.StuID = #2.StuID ] Output [ #2.StuID ] ; #7 = Except [ #1 , #6 ] Predicate [ #1.StuID = #6.StuID ] Output [ #1.StuID ]")
    , -- 4ee8e06d6ea0494afddda0a73ba51a5f3c93bfded92d39d8fef5436b57c0689b
      (studentTranscriptsTracking, "#1 = Scan Table [ Semesters ] Output [ semester_name , semester_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ semester_id ] ; #3 = Aggregate [ #2 ] GroupBy [ semester_id ] Output [ countstar AS Count_Star , semester_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.semester_id = #1.semester_id ] Output [ #1.semester_id , #1.semester_name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ semester_name , semester_id , Count_Star ]")
    , -- 9dfedf1ed380083968565ef5a9823ced768e51cfdfa1f398b7cfde5337d6a06d
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Output [ section_description , section_name ]")
    , -- 8a7eabc2f2afb4a40166c43715cce40cf1f8c574ace9542f0fc2f58fe4eb1b29
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade = 10 ] Output [ grade , name ]")
    , -- c8a261b56b3fd317715e20ae964633fe39d27e415421d119333cd698a3f48fb7
      (dogKennels, "#1 = Scan Table [ Treatments ] Output [ cost_of_treatment ] ; #2 = Aggregate [ #1 ] Output [ AVG(cost_of_treatment) AS Avg_cost_of_treatment ] ; #3 = Scan Table [ Treatments ] Output [ cost_of_treatment ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.cost_of_treatment < #2.Avg_cost_of_treatment ] Output [ #3.cost_of_treatment ] ; #5 = Scan Table [ Professionals ] Output [ first_name , last_name ] ; #6 = Join [ #4 , #5 ] Distinct [ true ] Output [ #5.last_name , #5.first_name ]")
    , -- 5f825d0ca7aab228d5c0ae6793b47a6d6044a166df89612088071c3bbdf4a22e
      (wta1, "#1 = Scan Table [ matches ] Distinct [ true ] Output [ winner_rank , winner_age , winner_name ] ; #2 = Top [ #1 ] Rows [ 3 ] Output [ winner_rank , winner_age , winner_name ]")
    , -- bd21f664a846bc1fe7d88e638adb44527375b28722a48eb0c8675360b6696489
      (battleDeath, "#1 = Scan Table [ battle ] Output [ name , date , id ] ; #2 = Scan Table [ ship ] Predicate [ name = 'lettice' ] Output [ name , lost_in_battle ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.lost_in_battle = #1.id ] Distinct [ true ] Output [ #1.date , #1.name ] ; #4 = Scan Table [ battle ] Output [ name , date , id ] ; #5 = Scan Table [ ship ] Predicate [ name = 'hms atalanta' ] Output [ name , lost_in_battle ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.lost_in_battle = #4.id ] Distinct [ true ] Output [ #4.name , #4.date ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.name = #6.name ] Distinct [ true ] Output [ #3.date , #3.name ]")
    , -- b1386d93c89b01508f84c2462d3dcc0f4f8ecec266f8b78d947bbe90436733a8
      (battleDeath, "#1 = Scan Table [ ship ] Predicate [ tonnage = 't' ] Output [ tonnage , id ] ; #2 = Scan Table [ death ] Output [ killed , caused_by_ship_id , injured ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.caused_by_ship_id = #1.id ] Output [ #2.injured , #2.killed ]")
    , -- d50de1020d3dcee5416196b209cf716fef84d0120bf108e9619ecbca20df62a3
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'ahd' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- dbbbe82c51d0aeb8bf96cdb30d579d6edc0ac34004b3f04fcea2e9b6f8fdb3c1
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' ] Output [ Title , Directed_by ]")
    , -- cbabb0f4acf5348df82086edafeb33e346d67ddb5ecf5f10dedfd657044434a3
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ series_name , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Title = 'the rise of the blue beetle !' ] Output [ Title , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.series_name ]")
    , -- 4b0a022ab96f7a4a516115996f72cb33a909184ac542d5a74415bce23b7c24a8
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Rating , Episode ]")
    , -- c6eaf80201ad8d7f85db0df294c33fed7080cd547a81a9a164d9c2ef59b662e3
      (wta1, "#1 = Scan Table [ players ] Predicate [ country_code = 'usa' ] Output [ country_code , first_name , birth_date ]")
    , -- aa8f4dc719d2148591f8ac649686e938d8fca15a61e0473dba4cde677c04eb35
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'bk' ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Document_Name , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #2.Document_Name ]")
    , -- e1c968c860459137f04af68da9abc88ba0199c805ad1c700791b8e06de9d9b00
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Year_of_Work , Name ]")
    , -- 4defbf0359c1037bfe89c5403c7cdb8c67b0f82ae96d81d003691e8e0500a564
      (wta1, "#1 = Scan Table [ rankings ] Output [ ranking_date , tours ] ; #2 = Aggregate [ #1 ] GroupBy [ ranking_date ] Output [ SUM(tours) AS Sum_tours , ranking_date ]")
    , -- d381b46013f0591ed9f55bae1c24b89d012b6cca147b787e06954fb2f9f1d091
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , other_details ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ transcript_date ASC ] Output [ transcript_date , other_details ]")
    , -- 133810f0e3f5f4b7d84f4b9d31f3fc19932e5f2965fdb8a9d6f5ee92cc706dd9
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Weight >= 3000 AND Weight <= 4000 ] Distinct [ true ] Output [ Year ]")
    , -- 0049599bd964edec86a7cd9e34a482b47430b2f6f3b2376013f90f446d7b20e0
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Employee_ID ] Output [ Employee_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Employee_ID = #1.Employee_ID ] Output [ #1.Name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- c0a96b9f9d0925f4b25d2753c394e50199efd3b2e713af2553e63e9a993cd92f
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ state_province_county = 'northcarolina' ] Output [ address_id , state_province_county ] ; #2 = Scan Table [ Students ] Output [ current_address_id , last_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.current_address_id = #1.address_id ] Distinct [ true ] Output [ #2.last_name ] ; #4 = Scan Table [ Students ] Output [ student_id , last_name ] ; #5 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.student_id = #4.student_id ] Distinct [ true ] Output [ #4.last_name ] ; #7 = Except [ #3 , #6 ] Predicate [ #3.last_name = #6.last_name ] Output [ #3.last_name ]")
    , -- 2e383ebce0c62942782b4210e6a1afa87716bc51cd92d0f5cdb21c1209ef2847
      (tvshow, "#1 = Scan Table [ TV_series ] Output [ Share ] ; #2 = Aggregate [ #1 ] Output [ MIN(Share) AS Min_Share , MAX(Share) AS Max_Share ]")
    , -- d0c1275920417bc3e083a6ffa3814d5dbd98e9791189c35e9c83e797092aa2c2
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , Content ]")
    , -- dbbf44711e8fd308d37064f71594e0580d43a6aff100d52e2b3c507f986e8094
      (pokerPlayer, "#1 = Scan Table [ people ] Predicate [ Nationality <> 'russia' ] Output [ Nationality , Name ]")
    , -- 325a3137319c748777644852730ad792ab3dcc7f88ab2407ae185d7899dde3c2
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ Code , GovernmentForm ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 1 ] Output [ Language ]")
    , -- 6940b25b51becbeb25e648b50fc48812060854804e93b48086f08f8e01bd3638
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_code , breed_name ] ; #2 = Scan Table [ Dogs ] Output [ breed_code ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #1.breed_name ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_name ] Output [ countstar AS Count_Star , breed_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ breed_name , Count_Star ]")
    , -- 84e29240b001575ac46e8f3eebcf206cf49d7fc7fb2a26cca0199b1123c01bdd
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Output [ section_name ]")
    , -- 121668ef9aa1b21c6f90356eb200c8415c68d85e24e4277a59824c5dd5f9f785
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' OR City = 'abilene' ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 035659c5c5e07d718124ae4a3b4635423b78d35990d7ce6a1447c312966c2d8d
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Version_Number ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , MIN(Version_Number) AS Min_Version_Number ]")
    , -- e0000e04d7b1f0b4787cee1a9cad5012af99c9d21b96a02abe5b69467345fa8b
      (tvshow, "#1 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Weekly_Rank , Episode ]")
    , -- 1ccca59a2bf0612bea4c52b6b33f8bf1840d579cce726f4ad8b25b8342c718d6
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ DestAirport = 'ahd' ] Output [ DestAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ]")
    , -- bee611719acb4d7633d62ac694f134c781ebbc780185efb12abf4c9f7ab521e9
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ Template_Type_Code = 'pp' OR Template_Type_Code = 'ppt' ] Output [ Template_Type_Code , Template_ID ]")
    , -- 647d2db94feaabbbdd3eecac3a26c557b1fb2a27a9e69a1f852d55b418ac6428
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year , concert_ID ] ; #3 = Scan Table [ singer_in_concert ] Output [ Singer_ID , concert_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.concert_ID = #2.concert_ID ] Output [ #3.Singer_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Singer_ID = #1.Singer_ID ] Output [ #1.Name ]")
    , -- 03a299a92f3839f2c0bb5e82bfe834b731538003186dcd06f7dea307ba81cee7
      (battleDeath, "#1 = Scan Table [ battle ] Predicate [ bulgarian_commander = 'kaloyan' AND latin_commander = 'baldwin i' ] Output [ bulgarian_commander , latin_commander , name ]")
    , -- c3998b7c1feeb87bae4cca7d360728a072f24c52445c2355240738d9e27063b6
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ DestAirport = 'ahd' ] Output [ DestAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ]")
    , -- e173f111341c71e2a837c8c0f18342105c3339de0e08e545b831d9f159845ed3
      (wta1, "#1 = Scan Table [ matches ] Predicate [ year = 2013 ] Distinct [ true ] Output [ winner_name ] ; #2 = Scan Table [ matches ] Predicate [ year = 2016 ] Distinct [ true ] Output [ winner_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.winner_name = #2.winner_name ] Distinct [ true ] Output [ #1.winner_name ]")
    , -- c645e766e0f936794bee7762b6bf8105d088753264597fd96793c738dd10dd91
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Shop_ID , Name ] ; #2 = Scan Table [ hiring ] Output [ Shop_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Shop_ID = #1.Shop_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ]")
    , -- 24a2b7acc32937966d07d1265d8dc136e4be76b7cfe7bf73b2ac90793d0c310b
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.student_id ] Output [ #1.student_id , #1.first_name , #1.last_name , #3.Count_Star , #1.middle_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ student_id , last_name , first_name , middle_name , Count_Star ]")
    , -- bff2974c43a128f711181e493e2036cb2b26cb7aa8f12d9009b047620bef2c21
      (voter1, "#1 = Scan Table [ votes ] Output [ contestant_number ] ; #2 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.contestant_number = #1.contestant_number ] Output [ #2.contestant_name , #2.contestant_number ] ; #4 = Aggregate [ #3 ] GroupBy [ contestant_name , contestant_number ] Output [ countstar AS Count_Star , contestant_number , contestant_name ] ; #5 = Top [ #4 ] Rows [ 1 ] Output [ contestant_number , contestant_name ]")
    , -- 462c2d108962edbbd5ff717ecf50a4f519aa59429596a9368897cbebb5f5f36f
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryId , #1.CountryName , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 1 ] Output [ CountryId , CountryName ]")
    , -- 34572d6690f52e3ae8b1930d673e5bb162d889950786a5123cf119a1dab9cc1e
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_summary_name , degree_program_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ degree_program_id ] ; #3 = Aggregate [ #2 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star , degree_program_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.degree_program_id = #1.degree_program_id ] Output [ #1.degree_summary_name , #1.degree_program_id , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_summary_name , degree_program_id , Count_Star ]")
    , -- 17831c8c47493e469a43da0b31f0b95d91ce356b726429b57d3929c4aa04974e
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ breed_code ] ; #2 = Aggregate [ #1 ] GroupBy [ breed_code ] Output [ countstar AS Count_Star , breed_code ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ breed_code , Count_Star ] ; #4 = Scan Table [ Dogs ] Output [ breed_code , dog_id , name ] ; #5 = Scan Table [ Treatments ] Output [ dog_id , date_of_treatment ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.dog_id = #4.dog_id ] Output [ #4.name , #5.date_of_treatment , #4.breed_code ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.breed_code = #6.breed_code ] Output [ #6.name , #6.date_of_treatment ]")
    , -- 0002168a04349f5ec8af3736caeba3db6f216aeec4b9c65dd78d1d1c4420b940
      (flight2, "#1 = Scan Table [ airports ] Output [ AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport , DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #1.AirportCode = #2.DestAirport OR #1.AirportCode = #2.SourceAirport ] Output [ #1.AirportCode ] ; #4 = Aggregate [ #3 ] GroupBy [ AirportCode ] Output [ countstar AS Count_Star , AirportCode ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ Count_Star , AirportCode ]")
    , -- 18b61f884d9b62c0631faab968c6bb3a753aafc3b726e3b5dbb62a9efe12b1b4
      (creDocTemplateMgt, "#1 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Document_ID ] Output [ countstar AS Count_Star , Document_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Document_ID ]")
    , -- 9a5c03af4b83ba7b55e93a138b9c8711e265ee47ca1a1ffa85059523cee22920
      (employeeHireEvaluation, "#1 = Scan Table [ hiring ] Output [ Employee_ID , Start_from , Shop_ID , Is_full_time ]")
    , -- 8c22247b347d4e3a016d6cf1c8b13a1bf4dc34f953f590d860f9f4901eaf98fd
      (tvshow, "#1 = Scan Table [ Cartoon ] Predicate [ Directed_by = 'ben jones' OR Directed_by = 'brandon vietti' ] Output [ Title , Directed_by ]")
    , -- 3139aeb80c8cefdaf39826e2d00b9d3cd210caeef5fb2ead36207817e06f956c
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID , Bonus ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Employee_ID = #1.Employee_ID ] Output [ #1.Name , #2.Bonus ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Bonus DESC ] Output [ Bonus , Name ]")
    , -- c77304be5a473c9034ca40868437e0b9f90523b4106fb5e2fa4db8724e5109b5
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id ] ; #2 = Scan Table [ Dogs ] Distinct [ true ] Output [ owner_id ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 523fbe361abc1311f6b3f07e9edf236519a70dbd66130b8dce011bcb8d76bd5e
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 9eb49aca2584d05d0366be17ba34ccfb07f238dffed751db48a4e86346eb6789
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name , date_left , middle_name , last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_left ASC ] Output [ first_name , date_left , middle_name , last_name ]")
    , -- 94d08d95b346a6cac868d8fad31eb0e5183488ba52e84f42ebb956b97efcf487
      (car1, "#1 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #2 = Scan Table [ car_makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryId , #1.CountryName , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 1 ] Output [ CountryId , CountryName ]")
    , -- 546ff06611de4b3ac4065c402b00c84c621762013d5a957cafdab6b13860ac83
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , LName ] ; #2 = Scan Table [ Pets ] Predicate [ pet_age = 3 AND PetType = 'cat' ] Output [ PetType , PetID , pet_age ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Output [ #1.LName ]")
    , -- 5cc42c682b5f85b204d17a77cab55f313f590e22ca5b0bdcd9e04dc092cfa830
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ Package_Option , series_name ]")
    , -- 847022cb66cc94760f125822895688d689431d8dd110319a78dea3ac54d8e390
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ] ; #4 = Aggregate [ #3 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Count_Star ]")
    , -- f58f82e66f2a77494424f80aa471496689fb273caf330128dc3b95ffc6d3ace7
      (network1, "#1 = Scan Table [ Likes ] Output [ student_id ] ; #2 = Aggregate [ #1 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ]")
    , -- 5a89af6cde45af39529cde237524a39a4b5bf5f6e805cf069bc3fd29ad32b8c0
      (car1, "#1 = Scan Table [ cars_data ] Output [ Horsepower , Accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Accelerate ] ; #3 = Scan Table [ cars_data ] Output [ Accelerate ] ; #4 = Join [ #2 , #3 ] Predicate [ #2.Accelerate > #3.Accelerate ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- f120ceebe63b91cf7d8ec2153a05da63c2f6a2cb3b1402da0f1772c73a21307e
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , other_details ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ transcript_date ASC ] Output [ transcript_date , other_details ]")
    , -- a9ff32fcd6bd92e2683cd5b35a991b73751f44afc13e6146cc8b4a68a61dcc1c
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 10 ] Output [ Airline ]")
    , -- b42c56ca3986518a42d21d9a1861a788415493c0260395d2d232b10d6da2bb65
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'aruba' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ Percentage , CountryCode , Language ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Percentage , #2.Language ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Percentage DESC ] Output [ Percentage , Language ]")
    , -- a7ac46f6fac1b59f3e7af600f51d43c2cb3e999a65bed7a25b53c188b5ea89d5
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ cell_number , professional_id ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.cell_number , #1.professional_id , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ cell_number , professional_id ]")
    , -- 279d2d1be85f34d2c0d188a4a33ed356a3ad63f477e61581ca597812edee5c28
      (flight2, "#1 = Scan Table [ flights ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 14675f95b778f27a99a45c1da9ba1a4976478bf0be82d56d97978b9952346a78
      (pets1, "#1 = Scan Table [ Pets ] Output [ pet_age , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ MAX(pet_age) AS Max_pet_age , AVG(pet_age) AS Avg_pet_age , PetType ]")
    , -- 80c3435a30611055d27a8c5e7b6cb75d19f7ffd652eb663fe6b6cb388ab74697
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #2 = Scan Table [ Student ] Predicate [ Sex = 'f' ] Output [ StuID , Sex ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.StuID = #2.StuID ] Output [ #3.PetID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.PetID = #1.PetID ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- d98f8fe8157483e3c7d8cfc11da276a7efd8100150eb4e6e7170ed40aa5b1e4f
      (singer, "#1 = Scan Table [ singer ] Predicate [ Birth_Year = 1948.0 OR Birth_Year = 1949.0 ] Output [ Birth_Year , Name ]")
    , -- df8e2eaea9db6a1d91940430669a0e36d2ac025433b2a3df977d949a20aefcd3
      (voter1, "#1 = Scan Table [ votes ] Output [ contestant_number ] ; #2 = Scan Table [ contestants ] Output [ contestant_number , contestant_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.contestant_number = #1.contestant_number ] Output [ #2.contestant_name , #2.contestant_number ] ; #4 = Aggregate [ #3 ] GroupBy [ contestant_name , contestant_number ] Output [ countstar AS Count_Star , contestant_number , contestant_name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ contestant_number , contestant_name ]")
    , -- d96c4aa465d4471e493741e9b5bd593cb4cee234edcbb652473be660899b21cf
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Capacity ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Capacity DESC ] Output [ Stadium_ID , Capacity ] ; #3 = Scan Table [ concert ] Output [ Stadium_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Stadium_ID = #2.Stadium_ID ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- a6c5ac5f34c3767df7ecfa7d8e8fa26d6aa081e9ae9a06b31887b21badbbe39f
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id , country ] ; #2 = Scan Table [ Students ] Output [ permanent_address_id , cell_mobile_number , first_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.permanent_address_id = #1.address_id ] Output [ #2.first_name ]")
    , -- 157adfc6e10475a6903221bfc25168a40ae9a2ef7302d6de45ef016f64c3a329
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age , dog_id ] ; #2 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ #1.age ] ; #4 = Aggregate [ #3 ] Output [ AVG(age) AS Avg_age ]")
    , -- b95a8aefa5bfc0f7d9606648e7afb9ffe2f3381c9f6147255b4f9af1b166c581
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #2 = Scan Table [ cars_data ] Predicate [ Cylinders = 3 ] Output [ Id , Horsepower , Cylinders ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Make ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Make ]")
    , -- e3cd6248e6e7f1dba56b3d1440d38872d8d0c60b3c205be143bf0e682bee3268
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ transcript_date DESC ] Output [ transcript_date ]")
    , -- 5322a644022dbc15036fe0c0099125fa375687c8e4eeb4917d45d70c1b33f836
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 50 ] Output [ country_code ]")
    , -- 425bff2bfebdbee3e9137540cf2239f10e3986898173aa49e7bbbba2d55064a9
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 50 ] Output [ country_code ]")
    , -- 620308662187c344a0e108bb40e62440d3db5e674d02984ac1edc18328782d6e
      (wta1, "#1 = Scan Table [ matches ] Output [ year ] ; #2 = Aggregate [ #1 ] GroupBy [ year ] Output [ countstar AS Count_Star , year ]")
    , -- 4ef7c7e7cdfb5f345e3af0a619b2fb55d98588777a38c541dd047cdcc5f39cde
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ] ; #4 = Aggregate [ #3 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Count_Star ]")
    , -- 32ff77c2b84d8fdfca0153500392286944ab8a6286191e53738a1bbf35ae9632
      (dogKennels, "#1 = Scan Table [ Dogs ] Predicate [ abandoned_yn = 1 ] Output [ age , abandoned_yn , weight , name ]")
    , -- b23e0c05a205accabd7aae54026cd0c93fc6315ab33314ad9de359fdc652715e
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Population ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Output [ Population ] ; #3 = Aggregate [ #2 ] Output [ MAX(Population) AS Max_Population ] ; #4 = Scan Table [ country ] Output [ Continent , Population , Name ] ; #5 = Filter [ #4 ] Predicate [ Continent = 'asia' ] Output [ Population , Name ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.Population > #3.Max_Population ] Output [ #5.Name ]")
    , -- 1a9e7cad0a48794e4ee18f147764337a553b0709e9a446f572b6fc855fc872d2
      (orchestra, "#1 = Scan Table [ conductor ] Output [ Age , Name ]")
    , -- 73165e09ea1c7c3e8c2058b4d3ae9211344a042bda319db31c06871c272683e2
      (tvshow, "#1 = Scan Table [ TV_series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Weekly_Rank , Episode ]")
    , -- da8cd4bbfc74b3388a037e8ca179f7adc6b22bbe197285d40fb33fa0f18b6fb2
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country ] ; #2 = Aggregate [ #1 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Country , Count_Star ]")
    , -- 93c0a5389ccc0e73693c2bcf4e1766badd062d038814a9442c11b9dc37fda3bc
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ SourceAirport = 'ahd' ] Output [ SourceAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 6fe75339376762c506c994080ce1289b6391db7a92fe1aad3b3a7528e9c66869
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , LName ] ; #2 = Scan Table [ Pets ] Predicate [ pet_age = 3 AND PetType = 'cat' ] Output [ PetType , PetID , pet_age ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Output [ #1.LName ]")
    , -- 3c4d21d33530da607dd924e2bc3544cedcadf73d4cfb0e585c45b6a36baf5b23
      (world1, "#1 = Scan Table [ countrylanguage ] Distinct [ true ] Output [ Language ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 8f2fa5fd0ef79053cfaef4c8c5f35c04f052a81db289cbdc839fcf8309c7201c
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Distinct [ true ] Output [ Location ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT Location) AS Count_Dist_Location ]")
    , -- dfeb5c39fcfaa04fbe29e401a052a5057e480adbb6384afdcf777c02c5a13a38
      (dogKennels, "#1 = Scan Table [ Owners ] Predicate [ state like '% north %' ] Output [ state , email_address , first_name , last_name ]")
    , -- ac7fe855633f31421a9bd706d23dfb20d80b0b538b0dc8520b1ebb91bc942e58
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade , name ]")
    , -- 92a0c46b93d249a1e5a2e1086fd87aae4f97324b1cca25ecbdad7407df10a42f
      (world1, "#1 = Scan Table [ countrylanguage ] Output [ Language ] ; #2 = Aggregate [ #1 ] GroupBy [ Language ] Output [ countstar AS Count_Star , Language ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language , Count_Star ]")
    , -- 77339ce451bff4db5fb89e5639a28995743d1ebb7b76c82c33c1f952c058812d
      (world1, "#1 = Scan Table [ country ] Output [ LifeExpectancy , Name ] ; #2 = Scan Table [ country ] Output [ Code , Name ] ; #3 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #4 = Filter [ #3 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.CountryCode = #2.Code ] Distinct [ true ] Output [ #2.Name ] ; #6 = Except [ #1 , #5 ] Predicate [ #1.Name = #5.Name ] Output [ #1.LifeExpectancy ] ; #7 = Aggregate [ #6 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 8314cff444da4190f678444cf54af0f671ea099bf1fd89b5c3d7fd8992206b6e
      (concertSinger, "#1 = Scan Table [ concert ] Output [ Year ] ; #2 = Aggregate [ #1 ] GroupBy [ Year ] Output [ Year , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Year , Count_Star ]")
    , -- 5c3b7fe9487dc73740aedb8cf7af43aa29068d1db0bd2ceb247e499df33f354c
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'dog' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Output [ #1.Age , #1.StuID , #1.Fname ] ; #6 = Scan Table [ Student ] Output [ StuID ] ; #7 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #8 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.PetID = #7.PetID ] Output [ #8.StuID ] ; #10 = Join [ #6 , #9 ] Predicate [ #9.StuID = #6.StuID ] Output [ #6.StuID ] ; #11 = Except [ #5 , #10 ] Predicate [ #5.StuID = #10.StuID ] Output [ #5.Age , #5.Fname ]")
    , -- a1fd3e36763de62d67634d2be00cc30e68e90ed8288550458734eb39e0156e48
      (world1, "#1 = Scan Table [ countrylanguage ] Predicate [ Language = 'Spanish' ] Output [ Percentage , CountryCode , Language ] ; #2 = Aggregate [ #1 ] GroupBy [ CountryCode ] Output [ countstar AS Count_Star , MAX(Percentage) AS Max_Percentage ]")
    , -- 0af2de205b31198e6eca3d7b0b73802ad3764080025941cb66a392eda65a9e13
      (courseTeach, "#1 = Scan Table [ teacher ] Predicate [ Hometown <> 'little lever urban district' ] Output [ Hometown , Name ]")
    , -- 512837d29318e63bfaec1474fb6fc4170733428b7d581c634116984533d750eb
      (flight2, "#1 = Scan Table [ airports ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ #1.City ] ; #4 = Aggregate [ #3 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ City , Count_Star ]")
    , -- 018da303b9516c988e9c24f88bd456d97adba3d25ba308c366e8eaa9027a509f
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.FullName , #1.Id ] ; #4 = Aggregate [ #3 ] GroupBy [ Id ] Output [ Id , countstar AS Count_Star , FullName ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ Id , FullName ]")
    , -- 411e3a9f339783dbf100ebab4a646a530bbbf7c0315e64cb7fc5982f87dd007e
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm <> 'republic' ] Output [ Code , GovernmentForm ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ CountryCode , Language ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Code ]")
    , -- 944f0b4d6ff267f7af127233f544a13a26d78eac3fd23869c146f15b97c3279f
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID , Bonus ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Employee_ID = #1.Employee_ID ] Output [ #1.Name , #2.Bonus ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Bonus DESC ] Output [ Bonus , Name ]")
    , -- d8eacdf8a3d6a1f89099265b0457ac988f631378f30f90fd38ada84b418b65c0
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ] ; #3 = Scan Table [ Friend ] Output [ student_id , friend_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.student_id = #2.ID ] Output [ #3.friend_id ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.friend_id = #1.ID ] Output [ #1.name ]")
    , -- 2b4311470404464d3aceb7aa1ee3fe0b8a84f764405a2eec8a7224e91344cc85
      (museumVisit, "#1 = Scan Table [ visitor ] Predicate [ Level_of_membership > 4 ] Output [ Level_of_membership , Name ]")
    , -- 14d7ca6040f3fd88253dc36d52a5dc3f8c9fddca5527843daae9a68e3513cdfd
      (wta1, "#1 = Scan Table [ matches ] Output [ year ] ; #2 = Aggregate [ #1 ] GroupBy [ year ] Output [ countstar AS Count_Star , year ]")
    , -- 67367330d8de673f906ebfa5f90854abadcd59ec692acaadafbf1c0b0fcbd88b
      (flight2, "#1 = Scan Table [ airlines ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Output [ Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ #1.Airline ] ; #4 = Aggregate [ #3 ] GroupBy [ Airline ] Output [ countstar AS Count_Star , Airline ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 10 ] Output [ Airline ]")
    , -- 2cf656ceb1eb210f1f81d421ee219bde550d715a32a6c7677ff2fa5526174d2f
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ state = 'hawaii' OR state = 'wisconsin' ] Output [ state , email_address ]")
    , -- 508534bf0da2fdfac341224de99be1122d48ac8789e1c28ff1cb466571264236
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ age ] ; #2 = Aggregate [ #1 ] Output [ MAX(age) AS Max_age ]")
    , -- 9468ef5d219c1fc8111244fca69f0d535063a6e7bc3bb6219ce500e89256e5d0
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description , treatment_type_code ] ; #2 = Scan Table [ Professionals ] Output [ first_name , professional_id ] ; #3 = Scan Table [ Treatments ] Output [ treatment_type_code , professional_id ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.professional_id = #2.professional_id ] Output [ #2.first_name , #3.treatment_type_code ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.treatment_type_code = #1.treatment_type_code ] Distinct [ true ] Output [ #4.first_name , #1.treatment_type_description ]")
    , -- a1c640433ac0aa6246e93a4cb6c53dd0dfd6ea14e7528d4c9080d31beb9bc5db
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Predicate [ Template_Type_Description = 'presentation' ] Output [ Template_Type_Code , Template_Type_Description ] ; #2 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Template_Type_Code = #1.Template_Type_Code ] Output [ #2.Template_ID ]")
    , -- b4b4ae10d25e46d7369817827ed4141e9c701e7046aefa27d6f88b73baff0a32
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ transcript_date , transcript_id ] ; #2 = Scan Table [ Transcript_Contents ] Output [ transcript_id ] ; #3 = Aggregate [ #2 ] GroupBy [ transcript_id ] Output [ countstar AS Count_Star , transcript_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.transcript_id = #1.transcript_id ] Output [ #1.transcript_date , #3.transcript_id , #3.Count_Star ] ; #5 = Top [ #4 ] Rows [ 1 ] Output [ transcript_date , transcript_id ]")
    , -- d405cd0b531fc7126168977471c87d89140774601d8b1779ff31df5e3fee25af
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id , country ] ; #2 = Scan Table [ Students ] Output [ permanent_address_id , cell_mobile_number , first_name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.permanent_address_id = #1.address_id ] Output [ #2.first_name ]")
    , -- 0e79c74a5610e5c303a789fad6b46b6a88e4328a1f400bf558be69eaac43af46
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Hometown ] ; #2 = Aggregate [ #1 ] GroupBy [ Hometown ] Output [ Hometown , countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 2 ] Output [ Hometown ]")
    , -- c072e76619b9b9ee950cec35cf5f953243537d799f59ec4fca100dcca366c081
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name , date_first_registered , middle_name , last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_first_registered ASC ] Output [ first_name , date_first_registered , middle_name , last_name ]")
    , -- 4403cae911a936dae540f929868bd1cf333130dd770d1fd8be82c3244f48249c
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Output [ Id , Horsepower ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower ASC ] Output [ Horsepower , Model ]")
    , -- c850bd4e8300b6e5ba35a342efc45a3c8f2d8ed8a4ce4e92e01bc12f5688331c
      (employeeHireEvaluation, "#1 = Scan Table [ employee ] Output [ Employee_ID , Name ] ; #2 = Scan Table [ evaluation ] Output [ Employee_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Employee_ID = #1.Employee_ID ] Output [ #1.Name ]")
    , -- bf536a5accf17fc5f50fe4a88831ffb0eddf2c053cfd010f4e496faec5a26fbc
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ country_code , Count_Star ]")
    , -- e5944abdcf96b6c445082d7c73904e1a558fcf3e470659bf41d44f19d8842244
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #2 = Scan Table [ flights ] Predicate [ DestAirport = 'asy' ] Output [ DestAirport , Airline ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Airline = #1.uid ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 35123af8dc9b9ee62fb89c900e54cbc078224381186a88392dae10e50a7427b8
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ Name , Level_of_membership , ID ] ; #2 = Scan Table [ visit ] Output [ Total_spent , visitor_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ visitor_ID ] Output [ SUM(Total_spent) AS Sum_Total_spent , visitor_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.visitor_ID = #1.ID ] Output [ #3.visitor_ID , #1.Name , #1.Level_of_membership , #3.Sum_Total_spent ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Sum_Total_spent DESC ] Output [ visitor_ID , Level_of_membership , Sum_Total_spent , Name ]")
    , -- ff0a82c65d3f97565126fcc5ac049f4dbc79566d8ab0540c9d7d74e49940a317
      (flight2, "#1 = Scan Table [ airports ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ DestAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.DestAirport = #1.AirportCode ] Output [ #1.City ] ; #4 = Aggregate [ #3 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ City , Count_Star ]")
    , -- 6cc665c83afd60499ff4e24745c41e5fb4724d43e9409a2e72f07d8b013a4814
      (world1, "#1 = Scan Table [ country ] Output [ Continent , SurfaceArea ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'asia' OR Continent = 'europe' ] Output [ SurfaceArea ] ; #3 = Aggregate [ #2 ] Output [ SUM(SurfaceArea) AS Sum_SurfaceArea ]")
    , -- 40e5da0fbd145acd54d3d006d747228d77045559ef4773caa086c8734be6f556
      (world1, "#1 = Scan Table [ country ] Output [ Continent , GovernmentForm ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Distinct [ true ] Output [ GovernmentForm ] ; #3 = Aggregate [ #2 ] Output [ countstar AS Count_Star ]")
    , -- 02ee31443afa5b62019b5b08c0de715d262a4191a0e90dd4451a9d5d1a293efc
      (dogKennels, "#1 = Scan Table [ Owners ] Predicate [ state like '% north %' ] Output [ state , email_address , first_name , last_name ]")
    , -- ef3355a7fe3ce05cbe2e30e7a414c19cd64cc838a7d6cdb2e91aaea1f1811886
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Distinct [ true ] Output [ Teacher_ID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- 0c75ccfe4d4b0ec47c5677e32113c1b28aaf51d4a93834a03fe8f1674d1f650d
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country , id ] ; #2 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #1.Country ]")
    , -- 4081e5d7bc31db228a3c170e395df647ce46a1fd16e6f1ac5d2606249a8b1d37
      (world1, "#1 = Scan Table [ country ] Predicate [ IndepYear < 1930 ] Output [ Code , IndepYear ] ; #2 = Scan Table [ countrylanguage ] Output [ IsOfficial , CountryCode , Language ] ; #3 = Filter [ #2 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode , Language ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.CountryCode = #1.Code ] Distinct [ true ] Output [ #3.Language ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 3b3211d0463e7b65bdc40f6c3989d1bfeb949e049510419df985111529653097
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ Name ]")
    , -- 44db72f54c47304dbbd1f800ba4272ad3c910e06f260585d08261e5501deaddd
      (world1, "#1 = Scan Table [ country ] Output [ Continent , LifeExpectancy , Population ] ; #2 = Aggregate [ #1 ] GroupBy [ Continent ] Output [ Continent , AVG(LifeExpectancy) AS Avg_LifeExpectancy , SUM(Population) AS Sum_Population ] ; #3 = Filter [ #2 ] Predicate [ Avg_LifeExpectancy < 72.0 ] Output [ Continent , Avg_LifeExpectancy , Sum_Population ]")
    , -- 8ac627d9be26faacaad933328aa777c2ba3faa7b21cb4f3c343c13997de5c7a0
      (voter1, "#1 = Scan Table [ votes ] Output [ state , created ] ; #2 = Filter [ #1 ] Predicate [ state = 'ca' ] Output [ created ] ; #3 = Aggregate [ #2 ] Output [ MAX(created) AS Max_created ]")
    , -- e42e09df5ba3b939399271de5fec1b7bcb6fd4f75c9a0ebc3b54f0823831ff38
      (orchestra, "#1 = Scan Table [ conductor ] Predicate [ Nationality <> 'usa' ] Output [ Nationality , Name ]")
    , -- dbf216d50046bffe3525bbf214859163bbb25370ba59b212e66125d6db158dd4
      (pets1, "#1 = Scan Table [ Pets ] Output [ weight , PetType ] ; #2 = Aggregate [ #1 ] GroupBy [ PetType ] Output [ MAX(weight) AS Max_weight , PetType ]")
    , -- 3060597756a5391c591fd7056a8c19f57f2d440c443ea414541bc487cacf96a2
      (car1, "#1 = Scan Table [ model_list ] Output [ Model ] ; #2 = Scan Table [ cars_data ] Predicate [ Year > 1980 ] Output [ Id , Year ] ; #3 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.MakeId = #2.Id ] Output [ #3.Model ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Model = #1.Model ] Output [ #1.Model ]")
    , -- d01287301b3ab267c9011c0d72455a523c3ac26d89ed5a67dbe3e23e670b9d15
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ People_ID , Height ] ; #2 = Scan Table [ poker_player ] Output [ People_ID , Money_Rank ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #2.Money_Rank , #1.Height ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Height DESC ] Output [ Height , Money_Rank ]")
    , -- 185d457b4daa3628c437828ee9ad39f78143b5f76428b6d1991904e89b9b7ec4
      (orchestra, "#1 = Scan Table [ performance ] Predicate [ Type <> 'live final' ] Output [ Type , Share ] ; #2 = Aggregate [ #1 ] Output [ MIN(Share) AS Min_Share , MAX(Share) AS Max_Share ]")
    , -- 64d97831731936fc8fa76d5d897530503fe24df345357db9599440a78381e569
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Version_Number , Template_Type_Code , Template_ID ]")
    , -- 5b29113c5ab990f62b686fbdc871914d99e8e268ea27a89a31141d06be57b7a9
      (singer, "#1 = Scan Table [ singer ] Predicate [ Birth_Year = 1948.0 OR Birth_Year = 1949.0 ] Output [ Birth_Year , Name ]")
    , -- 4f0586d6a811c9dd3d73bdee44c39fc23377c7738abf1a2060ccbab35237dec4
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ GovernmentForm ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- b08ef71ef93254d405738b9cd0374cff3985ee5e36c497a19f987ccff4384b5f
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'us territory' ] Output [ GNP , GovernmentForm , Population ] ; #2 = Aggregate [ #1 ] Output [ AVG(GNP) AS Avg_GNP , SUM(Population) AS Sum_Population ]")
    , -- dbfcc50884c2d7e4346c3172892aa8910971ebcd3c46dba825586dd3347b9a24
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Except [ #1 , #2 ] Predicate [ #2.StuID IS NULL OR #1.StuID = #2.StuID ] Output [ #1.Age ] ; #4 = Aggregate [ #3 ] Output [ AVG(Age) AS Avg_Age ]")
    , -- 55985502904668903fc70726bab09acf27f4a63cb38da420aac63d72edfcc8ac
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ breed_code ] ; #2 = Aggregate [ #1 ] GroupBy [ breed_code ] Output [ countstar AS Count_Star , breed_code ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star ASC ] Output [ breed_code , Count_Star ] ; #4 = Scan Table [ Dogs ] Output [ breed_code , dog_id , name ] ; #5 = Scan Table [ Treatments ] Output [ dog_id , date_of_treatment ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.dog_id = #4.dog_id ] Output [ #4.name , #5.date_of_treatment , #4.breed_code ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.breed_code = #6.breed_code ] Output [ #6.name , #6.date_of_treatment ]")
    , -- 6c99977d3e70f4f90d745fa4f3116ae0f4423f66a5b9d7157fcf3fd8f13451ce
      (car1, "#1 = Scan Table [ countries ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 3def30b1ac991f058d5d2835e68edd88f98f0b397ec317e4db5c6ad6cacb91fb
      (dogKennels, "#1 = Scan Table [ Owners ] Predicate [ state = 'virginia' ] Output [ state , first_name , owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id , name ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #2.name , #1.first_name ]")
    , -- 66c3f98482a14280727e245d4aa8fb05ff84ec2ea3d5c2fc79ecd29f068dc541
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code , Template_ID ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Aggregate [ #2 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Template_ID = #1.Template_ID ] Output [ #3.Template_ID , #3.Count_Star , #1.Template_Type_Code ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code , Template_ID , Count_Star ]")
    , -- 4a94a6a7efd98efae436bb2d28b838c67c042c12a753e7c5dd6189f43f8d246d
      (car1, "#1 = Scan Table [ model_list ] Output [ Model , Maker ]")
    , -- 025e0f3fdad5dd9c427fe7336fda1a25861b44bd961230fd0d51ebfe02eae5d6
      (pets1, "#1 = Scan Table [ Student ] Predicate [ Age > 20 ] Output [ Age , StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 226cd9a74a1b2e51610774012d114c254e10c37065ac9d0b0e0f451343dcc72e
      (realEstateProperties, "#1 = Scan Table [ Properties ] Predicate [ property_type_code = 'house' ] Output [ property_type_code , property_name ] ; #2 = Scan Table [ Properties ] Predicate [ room_count > 1 AND property_type_code = 'apartment' ] Output [ property_type_code , property_name , room_count ] ; #3 = Union [ #1 , #2 ] Output [ #1.property_name ]")
    , -- 95886c213cb2f796b359970764254b64bbe0314263e65f9fbaea1c469021457b
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Cylinders = 8 OR Year < 1980 ] Output [ Year , Cylinders , MPG ] ; #2 = Aggregate [ #1 ] Output [ MAX(MPG) AS Max_MPG ]")
    , -- 58c46fcc34a7383d2e710c843d03f5bf99d9592aa7e497a33a507a2e6058fe5f
      (singer, "#1 = Scan Table [ singer ] Output [ Net_Worth_Millions , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Net_Worth_Millions DESC ] Output [ Net_Worth_Millions , Name ]")
    , -- ccf0a1234580e327589862c55c99a5568deaaa030d338a8f77d11c02036eab31
      (museumVisit, "#1 = Scan Table [ visitor ] Predicate [ Age < 30 ] Output [ Age ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 65eeff6ba62debfd324c1369719ec178496b3f06a7b1df6fc9760d2bd4d00bc0
      (battleDeath, "#1 = Scan Table [ ship ] Predicate [ disposition_of_ship = 'captured' ] Output [ disposition_of_ship ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 1a6d7284f609f767a7d2bbc05f7e125020d7b13ecf4c7f2f2de8e63338e8f6fe
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id , birth_date ] ; #2 = Scan Table [ matches ] Output [ winner_rank_points , winner_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.winner_id = #1.player_id ] Output [ #2.winner_rank_points , #1.country_code , #1.birth_date , #1.first_name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ winner_rank_points , country_code , first_name , birth_date ]")
    , -- f85c2f09f4eae3cc1aaf881656ac6d56ca396023118851906c9efa64f26e905d
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id , first_name , middle_name , last_name ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.student_id ] Output [ #1.student_id , #1.first_name , #1.last_name , #3.Count_Star , #1.middle_name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 2 ] Output [ student_id , first_name , middle_name , last_name ]")
    , -- 18df0d6d89d729ddddb63ab14a7b51091dcdaa8a024eb30d6fc2483580187d04
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Description like '% w %' ] Output [ Document_Name , Document_Description , Template_ID ]")
    , -- 9ae78bb93870f4f5e609eea4e7be9e17d17f90eedf2b3f5d801460325259aff7
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #2.Course , #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name , #4.Course ]")
    , -- b3221e9c112854ef99fba5d334b12427914fef6cde224429b25a501e64e6c4ae
      (realEstateProperties, "#1 = Scan Table [ Other_Available_Features ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- bd1edcbd11ce93f7ca5db25e0f6a2121942bb60f441d1551ad5bfaedcaa0bad0
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ grade = 9 OR grade = 10 ] Output [ grade ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- f188a37bade4eaee7d3ab43541a2979675922644d5338853df3bf004604a9d03
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'cat' OR PetType = 'dog' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Fname ]")
    , -- d62f00c18f52de786886bd8891a3d2bf89ffa4b15a55048cd99820de47c66fb2
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #2 = Scan Table [ cars_data ] Predicate [ Cylinders = 4 ] Output [ Id , Horsepower , Cylinders ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Id = #1.MakeId ] Output [ #2.Horsepower , #1.Model ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Model ]")
    , -- a1757bd28d3c99a6d0f79e9427ace21cf824ba79417c1559f8b20ff238b12c32
      (world1, "#1 = Scan Table [ country ] Predicate [ Name = 'aruba' ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 72a560902ad1a26b3705b36166d2d4bb791b70869b75743abfae8ace99e81301
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Friend ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ student_id , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.student_id = #1.ID ] Output [ #1.name , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name , Count_Star ]")
    , -- d435cfadf939ca48c701dd06598c00e6e2ef5bc5c0d70ad308404adeb96b8b4e
      (car1, "#1 = Scan Table [ car_makers ] Output [ Id , Maker ] ; #2 = Scan Table [ model_list ] Output [ Model , Maker ] ; #3 = Scan Table [ cars_data ] Predicate [ Year = 1970 ] Output [ Id , Year ] ; #4 = Scan Table [ car_names ] Output [ MakeId , Model ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.MakeId = #3.Id ] Output [ #4.Model ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.Model = #2.Model ] Output [ #2.Maker ] ; #7 = Join [ #1 , #6 ] Predicate [ #6.Maker = #1.Id ] Distinct [ true ] Output [ #1.Maker ]")
    , -- fc7d50c7b91da6ea233b30b07836fcf085ac0fcc1678f271d0c50c3ccb040ab8
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'aberdeen' ] Output [ City , AirportCode ] ; #2 = Scan Table [ airlines ] Predicate [ Airline = 'united airlines' ] Output [ uid , Airline ] ; #3 = Scan Table [ flights ] Output [ DestAirport , Airline ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Airline = #2.uid ] Output [ #3.DestAirport ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.DestAirport = #1.AirportCode ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- e12cf91c771fa037e6783e5800ff94968bc131b55bf15a098ff231834fa087d0
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Location , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Stadium_ID , Year ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Distinct [ true ] Output [ #1.Name , #1.Location ] ; #4 = Scan Table [ stadium ] Output [ Stadium_ID , Location , Name ] ; #5 = Scan Table [ concert ] Predicate [ Year = 2015 ] Output [ Stadium_ID , Year ] ; #6 = Join [ #4 , #5 ] Predicate [ #5.Stadium_ID = #4.Stadium_ID ] Distinct [ true ] Output [ #4.Location , #4.Name ] ; #7 = Join [ #3 , #6 ] Predicate [ #3.Name = #6.Name ] Distinct [ true ] Output [ #3.Location , #3.Name ]")
    , -- 23c4fe45297b48d8ee466d2d1d6ec177bcea9379322d3dc4925ed1db0e1ecdd1
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 4 ] Output [ grade ]")
    , -- 2c0de20779e40a8f22108d64a6d535afadb5261fca03a654dfb32a79b1987e60
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Count_Star , Name ]")
    , -- 64fc77b18d68161ef02cddfa0391c902fd60785ca67c788616dce5eff2d8ec7c
      (dogKennels, "#1 = Scan Table [ Treatments ] Distinct [ true ] Output [ dog_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- e75fca8acdfc313eda670c300d1d3931ee4ab7bc8f3ae5fd929fe9f48b3b1e4e
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ series_name = 'sky radio' ] Output [ series_name , id ] ; #2 = Scan Table [ TV_series ] Output [ Episode , Channel ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Channel = #1.id ] Output [ #2.Episode ]")
    , -- de7fe93e9fc34cbb4e48313cb3c9d1a8b89df8398f23bf0ed08a5dca217c31d4
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'robbin cv' ] Output [ Document_Name , Document_Description , Template_ID , Document_ID ]")
    , -- 9d6035ad0ad42b2d785b043e82035e314bdf85d3fa4ae7d8d22cb7a8980c2c5b
      (employeeHireEvaluation, "#1 = Scan Table [ evaluation ] Output [ Bonus ] ; #2 = Aggregate [ #1 ] Output [ SUM(Bonus) AS Sum_Bonus ]")
    , -- f9daf85575404c5b449d54a8baa0724475494e972fe99743b94ee039c21ade56
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #2 = Scan Table [ cars_data ] Output [ Horsepower ] ; #3 = Aggregate [ #2 ] Output [ MIN(Horsepower) AS Min_Horsepower ] ; #4 = Scan Table [ cars_data ] Predicate [ Cylinders <= 3 ] Output [ Id , Horsepower , Cylinders ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Horsepower > #3.Min_Horsepower ] Output [ #4.Id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.Id = #1.MakeId ] Output [ #1.MakeId , #1.Make ]")
    , -- 456cfce7f4f9a1bf5059801519fd02ec3ef4b74df8dd9289c623633591d50cce
      (wta1, "#1 = Scan Table [ matches ] Distinct [ true ] Output [ loser_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT loser_name) AS Count_Dist_loser_name ]")
    , -- 0d767c181e12d55eb4c6543cc27fd975df0309e40c6def682cfc56597fc5faed
      (car1, "#1 = Scan Table [ car_names ] Output [ MakeId , Make ] ; #2 = Scan Table [ cars_data ] Output [ Horsepower ] ; #3 = Aggregate [ #2 ] Output [ MIN(Horsepower) AS Min_Horsepower ] ; #4 = Scan Table [ cars_data ] Predicate [ Cylinders < 4 ] Output [ Id , Horsepower , Cylinders ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.Horsepower > #3.Min_Horsepower ] Output [ #4.Id ] ; #6 = Join [ #1 , #5 ] Predicate [ #5.Id = #1.MakeId ] Output [ #1.MakeId , #1.Make ]")
    , -- 8ff76f894695250cc3219a3776484c51d536e913fbbfae05da57575988b3aaeb
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ dog_id , name ] ; #2 = Scan Table [ Treatments ] Output [ dog_id , cost_of_treatment ] ; #3 = Aggregate [ #2 ] GroupBy [ dog_id ] Output [ SUM(cost_of_treatment) AS Sum_cost_of_treatment , dog_id ] ; #4 = Filter [ #3 ] Predicate [ Sum_cost_of_treatment > 1000.0 ] Output [ dog_id ] ; #5 = Except [ #1 , #4 ] Predicate [ #4.dog_id = #1.dog_id ] Output [ #1.name ]")
    , -- 6b65ceb9aba024837ed659880317510fa7c5a5b16560bf85c2308d4fb5e398fd
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Record_Company , Year_of_Founded ]")
    , -- fe924a806ef085407a4c416512b5a8145323d4427e751f280efeb70d1bc2c1cf
      (pets1, "#1 = Scan Table [ Pets ] Output [ pet_age , weight , PetType ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ pet_age ASC ] Output [ pet_age , weight , PetType ]")
    , -- 11e3dfccf0adfb124a6c25b1db3b111936b727842d24ab609fcd295a69fc760d
      (flight2, "#1 = Scan Table [ airports ] Predicate [ AirportCode = 'ako' ] Output [ AirportName , AirportCode ]")
    , -- 48d3b1951efeabcc1977bdb8ee2d1140c1f13dd2d22d9335243284834c4c12e1
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm = 'republic' ] Output [ Continent , LifeExpectancy , GovernmentForm ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'africa' ] Output [ LifeExpectancy ] ; #3 = Aggregate [ #2 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 0e52fbec4158ca7c3cfba053e57807319098341d3583da7d1076f728ea86df2b
      (wta1, "#1 = Scan Table [ matches ] Predicate [ year = 2013 OR year = 2016 ] Output [ year ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- db474200659b4d04abc94f233be2174f0b5d7bad40e32821c04983268be79774
      (car1, "#1 = Scan Table [ countries ] Distinct [ true ] Output [ CountryName ] ; #2 = Scan Table [ countries ] Output [ CountryId , CountryName ] ; #3 = Scan Table [ car_makers ] Output [ Country ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Country = #2.CountryId ] Distinct [ true ] Output [ #2.CountryName ] ; #5 = Except [ #1 , #4 ] Predicate [ #1.CountryName = #4.CountryName ] Output [ #1.CountryName ]")
    , -- 96ecc85b71033293fa2c714428724abb820b7d37ef95d0c06006e19e54d286a8
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_arrived , date_departed , dog_id ] ; #2 = Scan Table [ Treatments ] Output [ dog_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.dog_id = #1.dog_id ] Distinct [ true ] Output [ #1.date_departed , #1.date_arrived ]")
    , -- 34a29224cb1a2db69920126c04ee5270c88f451260a25f12974f6cb81799530a
      (car1, "#1 = Scan Table [ cars_data ] Output [ Horsepower , Accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Accelerate DESC ] Output [ Horsepower , Accelerate ]")
    , -- 6b4498103b5d61a19827ce25667aea3019ce7675511bd6745692252c786e1437
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Stadium_ID , Capacity , Name ] ; #2 = Scan Table [ concert ] Predicate [ Year > 2013 ] Output [ Stadium_ID , Year ] ; #3 = Aggregate [ #2 ] GroupBy [ Stadium_ID ] Output [ Stadium_ID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name , #3.Count_Star , #1.Capacity ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Capacity , Count_Star , Name ]")
    , -- 50a9673efed62eae22b4c202df67633cef3c1493a63dcfa415e75c65c29580f2
      (museumVisit, "#1 = Scan Table [ visit ] Output [ Num_of_Ticket ] ; #2 = Aggregate [ #1 ] Output [ MAX(Num_of_Ticket) AS Max_Num_of_Ticket , AVG(Num_of_Ticket) AS Avg_Num_of_Ticket ]")
    , -- 083277424cc72b24b52d3e290a538f559469a57cd0a48ed24160555273b717de
      (tvshow, "#1 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ series_name ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT series_name) AS Count_Dist_series_name ] ; #3 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ Content ] ; #4 = Aggregate [ #3 ] Output [ COUNT(DISTINCT Content) AS Count_Dist_Content ] ; #5 = Join [ #2 , #4 ] Output [ #4.Count_Dist_Content , #2.Count_Dist_series_name ]")
    , -- 8ddb7c07d3458e79a1b0ab40bec542aa9573847464da7037e2e78d99b362b74d
      (singer, "#1 = Scan Table [ singer ] Output [ Singer_ID , Name ] ; #2 = Scan Table [ song ] Output [ Singer_ID , Sales ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name , #2.Sales ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ SUM(Sales) AS Sum_Sales , Name ]")
    , -- 846e09f26beeee5ebb3abf7a28810861967194e38262b68ea53c0d47e8b2709e
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name , professional_id , role_code ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.professional_id , #1.role_code , #3.Count_Star , #1.first_name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ first_name , professional_id , role_code ]")
    , -- cdc8145fd792a6edaffb1bd812a01f52de104c77fbc0a642f538ef1ea0887887
      (dogKennels, "#1 = Scan Table [ Treatments ] Distinct [ true ] Output [ professional_id ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- b231dc84cc5a3164c7790160a3d477c445f337f31d5eb74b92fa01a38341a47c
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Major ] ; #2 = Scan Table [ Student ] Output [ StuID ] ; #3 = Scan Table [ Pets ] Predicate [ PetType = 'cat' ] Output [ PetID , PetType ] ; #4 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #5 = Join [ #3 , #4 ] Predicate [ #4.PetID = #3.PetID ] Output [ #4.StuID ] ; #6 = Join [ #2 , #5 ] Predicate [ #5.StuID = #2.StuID ] Output [ #2.StuID ] ; #7 = Except [ #1 , #6 ] Predicate [ #1.StuID = #6.StuID ] Output [ #1.Age , #1.Major ]")
    , -- 5f078cf8840141aae2115e123c9cdd40f90ec682501edb26c3d06816b9a4eca2
      (network1, "#1 = Scan Table [ Highschooler ] Output [ name , ID ] ; #2 = Scan Table [ Likes ] Output [ student_id ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.student_id = #1.ID ] Output [ #1.name , #2.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star , name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ name ]")
    , -- f169ba7a72e220db320e37e251c8cb9711d7acc0bee315013137bf2271abee10
      (pets1, "#1 = Scan Table [ Student ] Output [ Age , StuID , Fname ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Age , #1.Fname ]")
    , -- 6f2b7f8fdc2f6cbf4c2b61688a16fbb31573f8fc967ef5acad0f68f46876e896
      (world1, "#1 = Scan Table [ country ] Output [ Code , Name ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star , Name ]")
    , -- ccad946be7d6d75013383b0a2dcc93dfd7c97d868dcafe7309b4e97793ad9e8c
      (flight2, "#1 = Scan Table [ airports ] Output [ City , AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.SourceAirport = #1.AirportCode ] Output [ #1.City ] ; #4 = Aggregate [ #3 ] GroupBy [ City ] Output [ City , countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ City , Count_Star ]")
    , -- 20aad5ec8be072a2fc801c6afcad66ba64d69ce743b9ab6f3f5237766dfde98f
      (car1, "#1 = Scan Table [ cars_data ] Output [ Id , Cylinders , Accelerate ] ; #2 = Scan Table [ car_names ] Predicate [ Model = 'volvo' ] Output [ MakeId , Model ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.MakeId = #1.Id ] Output [ #1.Accelerate , #1.Cylinders ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Accelerate ASC ] Output [ Accelerate , Cylinders ]")
    , -- 575ec295377477c9f31c046cc32ced0bff5306588047cf8a44524f07e76db154
      (voter1, "#1 = Scan Table [ votes ] Output [ state , phone_number , vote_id ]")
    , -- 5c621a2c9379a00f609d9e0aa243a240affd345c59eac074076072a0019e1f3e
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ city like '% west %' ] Output [ state , role_code , street , city ]")
    , -- 87a3b0989ee1dc1513ab72ca2965ce5304ba36e5ef0d89b458a1814f7fbcdb6c
      (singer, "#1 = Scan Table [ singer ] Output [ Citizenship ] ; #2 = Aggregate [ #1 ] GroupBy [ Citizenship ] Output [ countstar AS Count_Star , Citizenship ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Citizenship , Count_Star ]")
    , -- 4af5f846a2c00cc1660bb52df528a97d9532d57a5546a57a7d2989a3df6518c8
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Template_ID ] ; #2 = Aggregate [ #1 ] GroupBy [ Template_ID ] Output [ countstar AS Count_Star , Template_ID ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 1 ] Output [ Template_ID ]")
    , -- d470e09983752f911b63e42f813e74b44f366f7c126cfd843b5dc8b70d8a80dd
      (world1, "#1 = Scan Table [ country ] Output [ LifeExpectancy , GovernmentForm , Population ] ; #2 = Aggregate [ #1 ] GroupBy [ GovernmentForm ] Output [ SUM(Population) AS Sum_Population , AVG(LifeExpectancy) AS Avg_LifeExpectancy , GovernmentForm ] ; #3 = Filter [ #2 ] Predicate [ Avg_LifeExpectancy > 72.0 ] Output [ GovernmentForm , Sum_Population ]")
    , -- e8521737692fde7573e1b72b45538c2b1f7ff3b663744abb8012787667193b91
      (studentTranscriptsTracking, "#1 = Scan Table [ Sections ] Predicate [ section_name = 'h' ] Output [ section_description , section_name ]")
    , -- 0139e20814b0aee45d3111cbedd1d8d1b6453db970e4bf1a7b8b7202091a6f35
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ name = 'kyle' ] Output [ name , ID ]")
    , -- 7fddb3f9985c9698f0563fda7153bc19b66174ba26976910b80a60aaf59640a5
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Output [ Earnings ]")
    , -- 21558cf97f26dbb4214a9eae6e5df3b4c1b408de7847a6c459d57a3021c58c3b
      (pets1, "#1 = Scan Table [ Student ] Predicate [ LName = 'smith' ] Output [ StuID , LName ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #2.PetID ]")
    , -- 2d5aaf3ed4a87a7bfd3f47e80b31b63bc9cb52e1d5ab8aadfb5e21f80c15d4f4
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ state = 'indiana' ] Output [ state , cell_number , professional_id , last_name ] ; #2 = Scan Table [ Professionals ] Output [ cell_number , professional_id , last_name ] ; #3 = Scan Table [ Treatments ] Output [ professional_id ] ; #4 = Aggregate [ #3 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star , professional_id ] ; #5 = Join [ #2 , #4 ] Predicate [ #4.professional_id = #2.professional_id ] Output [ #4.Count_Star , #2.last_name , #2.cell_number , #2.professional_id ] ; #6 = Filter [ #5 ] Predicate [ Count_Star > 2 ] Output [ cell_number , professional_id , last_name ] ; #7 = Union [ #1 , #6 ] Output [ #1.last_name , #1.professional_id , #1.cell_number ]")
    , -- 964ffeff8f8a7b60a06ed97e9100a6c16331a8a237ac29efec1b336be3eeca13
      (pets1, "#1 = Scan Table [ Pets ] Distinct [ true ] Output [ PetType ] ; #2 = Aggregate [ #1 ] Output [ COUNT(DISTINCT PetType) AS Count_Dist_PetType ]")
    , -- 92e6a8f3680fa91a51338547b40a58e01a2044a47b181bc2301d2f71ed3a9817
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ state = 'hawaii' OR state = 'wisconsin' ] Output [ state , email_address ]")
    , -- ae181dcca46228f38a78aa5acf558f35f920c5e4bdb8b56ce47a9945cfb18458
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ ID ] ; #2 = Scan Table [ museum ] Predicate [ Open_Year > 2010 ] Output [ Open_Year , Museum_ID ] ; #3 = Scan Table [ visit ] Output [ Museum_ID , visitor_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Museum_ID = #2.Museum_ID ] Distinct [ true ] Output [ #3.visitor_ID ] ; #5 = Except [ #1 , #4 ] Predicate [ #4.visitor_ID = #1.ID ] Output [ 1 AS One ] ; #6 = Aggregate [ #5 ] Output [ countstar AS Count_Star ]")
    , -- c0a940b8887f4c7ef794eee72ddfb7b8c13f2f0d081cf6d873573933faf69e99
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ Code , Name ] ; #3 = Scan Table [ country ] Output [ Code , Name ] ; #4 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #5 = Filter [ #4 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.CountryCode = #3.Code ] Distinct [ true ] Output [ #3.Name ] ; #7 = Except [ #2 , #6 ] Predicate [ #2.Name = #6.Name ] Output [ #2.Code ] ; #8 = Scan Table [ city ] Output [ CountryCode , Name ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.CountryCode = #7.Code ] Distinct [ true ] Output [ #8.Name ]")
    , -- d55de3ff73f29e284106d565743be9d15c6776d3c50766545ca8af24e2fff9e4
      (pets1, "#1 = Scan Table [ Pets ] Predicate [ pet_age > 1 ] Output [ PetID , weight , pet_age ]")
    , -- 8257705ad9837960caf1153fa275f73bdb5e7c98cbbd9bd8f4d35ef3843d7e21
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname ] ; #2 = Scan Table [ Pets ] Predicate [ PetType = 'cat' OR PetType = 'dog' ] Output [ PetID , PetType ] ; #3 = Scan Table [ Has_Pet ] Output [ StuID , PetID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.PetID = #2.PetID ] Output [ #3.StuID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.StuID = #1.StuID ] Distinct [ true ] Output [ #1.Fname ]")
    , -- b81b808b3e493817e0147dc7b225dd4243187c2fcb355ad2bced48ea5131cc90
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Output [ department_name , department_id ] ; #2 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #3 = Aggregate [ #2 ] GroupBy [ department_id ] Output [ countstar AS Count_Star , department_id ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.department_id = #1.department_id ] Output [ #1.department_name , #3.department_id , #3.Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ department_name , Count_Star , department_id ]")
    , -- a207ddf9057f47af297b04e7f41856ac20a50fd2ed34907fb81ce862098d865b
      (network1, "#1 = Scan Table [ Highschooler ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 5a00e81d064799fc71f61f7eddc83f1fcad00988da1b787b02501bb425797671
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course_arrange ] Output [ Teacher_ID ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ countstar AS Count_Star , Name ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Name ]")
    , -- 277b5c8f864f36802e3bf5a4fdb43007f4b02f4575e48575970786bce9af05ee
      (wta1, "#1 = Scan Table [ players ] Output [ country_code ] ; #2 = Aggregate [ #1 ] GroupBy [ country_code ] Output [ country_code , countstar AS Count_Star ]")
    , -- 2e8baf9e453be42a11b71337dbfa3196ce81ab88196a3965e5d9eaef85ff4a28
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Teacher_ID , Name ] ; #2 = Scan Table [ course ] Predicate [ Course = 'math' ] Output [ Course_ID , Course ] ; #3 = Scan Table [ course_arrange ] Output [ Teacher_ID , Course_ID ] ; #4 = Join [ #2 , #3 ] Predicate [ #3.Course_ID = #2.Course_ID ] Output [ #3.Teacher_ID ] ; #5 = Join [ #1 , #4 ] Predicate [ #4.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- a138de21c6fb3c215e42c91746c2e9841522ae6a2bf1e80bde7978850e711477
      (wta1, "#1 = Scan Table [ matches ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 108ae9411be5efb3b8c13a863ccd27c25db8bb6f388e077086e5a293dfcddf27
      (wta1, "#1 = Scan Table [ players ] Output [ country_code , first_name , player_id ] ; #2 = Scan Table [ rankings ] Output [ player_id , tours ] ; #3 = Join [ #1 , #2 ] Predicate [ #2.player_id = #1.player_id ] Output [ #1.country_code , #2.tours , #1.first_name ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ tours DESC ] Output [ country_code , first_name , tours ]")
    , -- 245ef4bfa9b7661d4d74c480d37bfbbd1e0120f0ccb0f6c4f281bf958b53d2a7
      (car1, "#1 = Scan Table [ cars_data ] Output [ Accelerate , Cylinders ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ MAX(Accelerate) AS Max_Accelerate , Cylinders ]")
    , -- a7461adf7f778f867afb8fde575dd4680f7c8c40ac917ef8e354e11a8e01b73b
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID , Fname , Sex ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Aggregate [ #2 ] GroupBy [ StuID ] Output [ StuID , countstar AS Count_Star ] ; #4 = Join [ #1 , #3 ] Predicate [ #3.StuID = #1.StuID ] Output [ #1.Sex , #1.Fname , #3.Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ Sex , Fname ]")
    , -- 5c334eae39a83d351071183963010a8ed84b530e462431cf43876e0ced4fed9a
      (flight2, "#1 = Scan Table [ airports ] Predicate [ City = 'anthony' ] Output [ City , AirportName , AirportCode ]")
    , -- 4631e248fadb782ac6922779f4289d6c953b3c5d345b58dc7b86b67be4b17b1f
      (wta1, "#1 = Scan Table [ players ] Output [ 1 AS One ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 0107b0ffdcc55beb72507d69c0c32359b7bb551e3bcd2bac2dfb332b5809dc57
      (world1, "#1 = Scan Table [ countrylanguage ] Distinct [ true ] Output [ Language ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- e8e546b0d9e9fefa4c5f113010413fe3e77ee7f4f56456dc19a3d3ddb8314793
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Country ] ; #2 = Aggregate [ #1 ] GroupBy [ Country ] Output [ countstar AS Count_Star , Country ]")
    , -- 28ddb7e6b593e16d58aa021532f2d9e57af7b7574f003c9bc9d699893cf9f603
      (world1, "#1 = Scan Table [ country ] Output [ Population , Name ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Population DESC ] Output [ Population , Name ]")
    , -- e4c52b785e1632bd04805745f66503d7b650c8b3033ce632e1c491a6b718b3cf
      (world1, "#1 = Scan Table [ country ] Output [ IndepYear , Population , SurfaceArea , Name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Population ASC ] Output [ IndepYear , Population , SurfaceArea , Name ]")
    , -- 48a734d28ac0d45d15214f304ffedb1c3b0821398f90f0c5e93a378f96bf9bfc
      (car1, "#1 = Scan Table [ cars_data ] Output [ Horsepower , Accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Horsepower DESC ] Output [ Horsepower , Accelerate ] ; #3 = Scan Table [ cars_data ] Output [ Accelerate ] ; #4 = Join [ #2 , #3 ] Predicate [ #2.Accelerate > #3.Accelerate ] Output [ 1 AS One ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- 0d84fb9681915bfd4ab3a629c27b5ce0af8fc3c65ff7132f2d4cee75b10a0153
      (world1, "#1 = Scan Table [ country ] Output [ Continent , Code , Name ] ; #2 = Filter [ #1 ] Predicate [ Continent = 'europe' ] Output [ Code , Name ] ; #3 = Scan Table [ country ] Output [ Code , Name ] ; #4 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ IsOfficial , CountryCode , Language ] ; #5 = Filter [ #4 ] Predicate [ IsOfficial = 't' ] Output [ CountryCode ] ; #6 = Join [ #3 , #5 ] Predicate [ #5.CountryCode = #3.Code ] Distinct [ true ] Output [ #3.Name ] ; #7 = Except [ #2 , #6 ] Predicate [ #2.Name = #6.Name ] Output [ #2.Code ] ; #8 = Scan Table [ city ] Output [ CountryCode , Name ] ; #9 = Join [ #7 , #8 ] Predicate [ #8.CountryCode = #7.Code ] Distinct [ true ] Output [ #8.Name ]")
    , -- 58cef4c0076830335440dd933356d6eec64df763d1e4b8b8da20e69b4b7fb390
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Age , Name ]")
    , -- 22ee91deb377e46643d31c252f10263c8b22928407d5e83e3dfea73e93a2912f
      (network1, "#1 = Scan Table [ Highschooler ] Output [ grade ] ; #2 = Aggregate [ #1 ] GroupBy [ grade ] Output [ countstar AS Count_Star , grade ]")
    ]

negativeTestPlans :: [(SqlSchema, Text)]
negativeTestPlans =
    [ -- a5a6fef561cf350fc2c0f61225c80048d3e41977999c3e030b470ed1c19485e9
      (world1, "#1 = Scan Table [ country ] Output [ Population, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ CountryCode, Language ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Language, #1.CountryCode ] ; #4 = Aggregate [ #3 ] GroupBy [ CountryCode ] Output [ CountryCode, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ CountryCode, Count_Star ]")
    , -- 26edc7b34917846dc6fb176c89ec97752e591daa31f3fadc5e0bcb84f4b56b2c
      (world1, "#1 = Scan Table [ city ] Output [ Population, Name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #1.Population ] ; #4 = Aggregate [ #3 ] GroupBy [ Population ] Output [ Population, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Population, Count_Star ]")
    , -- 6ea998f796ec30bffa8e18b93df295017492f935422901936d3cd25d3d8cb4b4
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_Products, Name ] ; #2 = Aggregate [ #1 ] Output [ AVG(Number_Products) AS Avg_Number_Products ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Number_Products DESC ] Output [ Name, Avg_Number_Products ]")
    , -- 9e169afed9298dcaf606f723081977a0d33d4f22d10fc326ab83da4d35bc80d6
      (world1, "#1 = Scan Table [ country ] Output [ lifeexpectancy, code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ isOfficial = 'english' ] Output [ language, isOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.code ] Output [ #2.lifeexpectancy ] ; #4 = Aggregate [ #3 ] Output [ SUM(lifeexpectancy) AS Sum_lifeexpectancy ]")
    , -- 1b4ff28beddb2e20b5b98772dc08dc31b033b25d3bb666da28b6bfc81b517174
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Name, Capacity, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year >= 2014 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #1.Capacity ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star, Capacity ]")
    , -- 2ae88df2c4162c1fe98dc4ae1452e2b0dfd06263c9a682b94df0f969d32a241f
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' ] Distinct [ true ] Output [ StuID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.StuID ]")
    , -- a2cf4e35c9235fe7fe8b7f23cd46ecbf8798764d9afd5799468de4112f0a8b3d
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #1.Document_ID, #1.Document_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Document_ID ] Output [ Document_ID, countstar AS Count_Star ]")
    , -- 4e761a9127f36296f20021c44a8cadca031a57c3bb317ef82e3f9b28cfc2fee5
      (wta1, "#1 = Scan Table [ Players ] Output [ country_code, first_name ] ; #2 = Scan Table [ Matches ] Predicate [ tourney_name = 'wta championships' ] Output [ tourney_name, winner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_id = #1.player_id ] Output [ #2.country_code, #1.first_name ]")
    , -- 867cde5170a26741ae4655d22fca0ab3bb8617a3498fc46fe257463dea794d20
      (wta1, "#1 = Scan Table [ Players ] Output [ country_code, first_name, birth_date, player_id ] ; #2 = Scan Table [ Matches ] Output [ winner_rank_points, winner_name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_name = #1.player_id ] Output [ #1.winner_rank_points, #1.first_name, #2.country_code, #1.birth_date ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ birth_date, first_name, country_code, winner_rank_points ]")
    , -- deabaedeb3981927bf1f396a795b435a3035bd61ca255b76038121b2dbae91d2
      (world1, "#1 = Scan Table [ country ] Output [ code, name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ language < 'english' ] Output [ countrycode, language ] ; #3 = Join [ #1, #2 ] Predicate [ #2.countrycode = #1.code ] Output [ #1.countrycode ]")
    , -- 9f6ea46405112628df6ab798bc562f0bebb75f5ea0d962a455271e949a879db5
      (car1, "#1 = Scan Table [ Car_Names ] Predicate [ Make = 'amc hornet sportabout (sw)' ] Output [ Make, MakeId ] ; #2 = Scan Table [ Cars_Data ] Output [ Accelerate, Id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Id = #1.Id ] Output [ #1.Accelerate ]")
    , -- fefb38b1e47ce56411e8d791f7aff3e81d9c58f99f39beffa4c2b2146f8950a6
      (car1, "#1 = Scan Table [ car_makers ] Output [ id, maker ] ; #2 = Aggregate [ #1 ] GroupBy [ maker ] Output [ countstar AS Count_Star, maker ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 3 ] Output [ id, maker ]")
    , -- caf62133487d41ae6c81bff1ac1282aecfff3503c87cfb30cb05002b66459a4f
      (world1, "#1 = Scan Table [ country ] Predicate [ language = 'chinese' ] Output [ continent ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 702b793672d277ed4c482f92123e570d1e078e384702f2391b7b7bde241442cd
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Location, Capacity, Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Capacity ] Output [ Capacity, countstar AS Count_Star, Location ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 10000.0 ] Output [ Location, Count_Star, Name ]")
    , -- 16a6e522cfd501f609c46856f658cfd95b8ef2517b7ad60ecc032807076c99ac
      (car1, "#1 = Scan Table [ Countries ] Output [ CountryId, CountryName ] ; #2 = Scan Table [ Car_Makers ] Output [ Country ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Country = #1.CountryId ] Output [ #1.CountryName, #2.CountryId ] ; #4 = Aggregate [ #3 ] GroupBy [ CountryId ] Output [ CountryId, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ CountryId, Count_Star ]")
    , -- c21404f628622b0b31a04806e09664651daff826371944fb1be63ecf5b1627a7
      (wta1, "#1 = Scan Table [ Players ] Output [ First_Name, Player_ID ] ; #2 = Scan Table [ Rankings ] Output [ Ranking_Points, Player_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Player_ID = #1.Player_ID ] Output [ #1.Ranking_Points, #1.First_Name ] ; #4 = Aggregate [ #3 ] Output [ AVG(Ranking_Points) AS Avg_Ranking_Points, First_Name ]")
    , -- 1f4b6b8fe58168e372e3265b1dd9ea23b4530538ad134a2ffba2567cc80d9b8e
      (car1, "#1 = Scan Table [ car_makers ] Output [ id, fullname, maker ] ; #2 = Scan Table [ model_list ] Output [ maker ] ; #3 = Join [ #1, #2 ] Predicate [ #2.maker = #1.id ] Output [ #1.maker, #1.id ] ; #4 = Aggregate [ #3 ] GroupBy [ maker ] Output [ countstar AS Count_Star, maker, fullname ]")
    , -- 50c40e6bc28069c3bcc0382be99a457edbe8ea4d10caa0cd645599f8e47f6379
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline, uid ] ; #2 = Scan Table [ Airports ] Predicate [ airportName = 'ahd' ] Output [ airportName, airportCode ] ; #3 = Scan Table [ Flights ] Output [ airline, sourceAirport ] ; #4 = Join [ #2, #3 ] Predicate [ #3.sourceAirport = #2.sourceAirport ] Output [ #3.airline ]")
    , -- f00fb87bd37e2b2945ed497ba5ea69eac0f7d33f744a55657896bdbfc31dd036
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ name, age, id ] ; #2 = Scan Table [ visit ] Output [ visitor_id, total_spent ] ; #3 = Join [ #1, #2 ] Predicate [ #2.visitor_id = #1.id ] Output [ #1.total_spent, #1.name, #1.age ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ total_spent DESC ] Output [ name, age, total_spent ]")
    , -- fd3ab86c1726ff82dfae3f950d230250d8b8d89f8ebb0146cad28b2fb7ba5ecb
      (studentTranscriptsTracking, "#1 = Scan Table [ Semesters ] Output [ semester_name, semester_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ semester_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.semester_id = #1.semester_id ] Output [ #1.semester_name, #1.semester_id ] ; #4 = Aggregate [ #3 ] GroupBy [ semester_name ] Output [ countstar AS Count_Star, semester_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ semester_name, Count_Star, semester_id ]")
    , -- 60e9a83821454bd3ff7a90d11440f1e090c22d5ce2e40674a210dd1189f47522
      (museumVisit, "#1 = Scan Table [ museum ] Output [ Name, Num_of_Staff ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Num_of_Staff DESC ] Output [ Name, Num_of_Staff, Museum_ID ]")
    , -- 0958c0b2d43af122aef2fbe2e3aa770ae881b8f5b43febf6c3f9a3b5cf13e025
      (network1, "#1 = Scan Table [ highschooler ] Predicate [ Grade > 5 ] Output [ Grade, Name ] ; #2 = Scan Table [ friend ] Output [ Student_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.Student_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Name ]")
    , -- 154ade6ec7a46682d047b9181ae3c0a84374232035fcf506874a2219cdd09599
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name, middle_name, last_name ] ; #2 = Scan Table [ Student_Enrolment ] Predicate [ degree_program_id = 'bachelor' ] Output [ student_id, degree_program_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.student_id = #1.student_id ] Output [ #1.first_name, #2.middle_name, #1.last_name ]")
    , -- 869d090908c20d389878b3c1a8c760b86d77771817c2396a1fe57ce4f1537348
      (car1, "#1 = Scan Table [ Model_List ] Distinct [ true ] Output [ Model ] ; #2 = Scan Table [ Car_Makers ] Predicate [ Maker = 'general motors' ] Output [ Maker, Id ] ; #3 = Scan Table [ Cars_Data ] Output [ Weight, Id ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Id = #2.Id ] Distinct [ true ] Output [ #3.Model ] ; #5 = Join [ #1, #4 ] Predicate [ #4.Model = #1.Model ] Distinct [ true ] Output [ #1.Model ]")
    , -- 52e8fb837195616b49756027ccc6ca0ce0a8345e015fb0650c436258d6d84414
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_arrived, date_departed ] ; #2 = Scan Table [ Treatments ] Output [ date_of_treatment, dog_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ #2.date_of_treatment, #1.date_arrived ]")
    , -- aead834686e53b5a28f6330568c6b82b64797de7cded35cbc5b1feab82bda05c
      (world1, "#1 = Scan Table [ country ] Distinct [ true ] Output [ Population ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #1.Population ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 594047a3f87d0aa4e97ebf98f5d3e84a42a74422b787725d5ca6a6f0d75c94fb
      (studentTranscriptsTracking, "#1 = Scan Table [ Departments ] Output [ department_name, department_id ] ; #2 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.department_id = #1.department_id ] Output [ #1.department_name, #1.department_id ] ; #4 = Aggregate [ #3 ] GroupBy [ department_name ] Output [ countstar AS Count_Star, department_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ department_name, Count_Star, department_id ]")
    , -- c501736c887bf86ce56b90e4db34439faacb5416059971b688fd5830afa86a07
      (wta1, "#1 = Scan Table [ matches ] Predicate [ tourney_name = 'australia open' ] Output [ winner_rank_points, winner_name ] ; #2 = Scan Table [ rankings ] Output [ ranking_points, player_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.player_id = #1.player_id ] Output [ #2.ranking_points, #1.winner_name ] ; #4 = Aggregate [ #3 ] GroupBy [ winner_name ] Output [ winner_name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ winner_name, Count_Star ]")
    , -- f7f4826cde3d4d2d0ff201160a9274986c4dc75f8346cba26e99e80fd3ccc0b4
      (world1, "#1 = Scan Table [ country ] Distinct [ true ] Output [ Population ] ; #2 = Scan Table [ countrylanguage ] Distinct [ true ] Output [ Language ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.CountryCode ] Output [ #1.Population ] ; #4 = Aggregate [ #3 ] Output [ SUM(Population) AS Sum_Population ]")
    , -- 25e6219ead2bf27a2598b9113dc3d3af8c1960671ba08542f364e3d1cf519404
      (studentTranscriptsTracking, "#1 = Scan Table [ Student_Enrolment ] Output [ student_id, degree_program_id ] ; #2 = Aggregate [ #1 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star, degree_program_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, degree_program_id, student_id ]")
    , -- ec825644def6d351087212ad83bc285b307c370ff3598206227c45b0b4188c7f
      (world1, "#1 = Scan Table [ country ] Predicate [ continent = 'asia' ] Output [ continent, code ] ; #2 = Scan Table [ countrylanguage ] Output [ language, percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.code ] Output [ #1.language ] ; #4 = Aggregate [ #3 ] GroupBy [ language ] Output [ language, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ language, Count_Star ]")
    , -- 28003ee356dcce5bec7b0a6b0ac8b51f30bc4cfa2b0b8310e8dd3fb0007706b7
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID, Fname ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'dog' ] Distinct [ true ] Output [ PetID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.PetID = #1.StuID ] Distinct [ true ] Output [ #1.Fname ]")
    , -- e7e55a8fa3c545c49218fac804bb17a8f183588046d59a33f56a1e69d025ff83
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name, middle_name, last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_first_registered DESC ] Output [ first_name, middle_name, last_name ]")
    , -- b6618cc926b5b8cc6e09139cb718b03092808549394e8287aafb2b9044c491bf
      (concertSinger, "#1 = Scan Table [ concert ] Output [ Concert_Name, Theme ] ; #2 = Scan Table [ singer_in_concert ] Output [ Concert_ID, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #1.Concert_Name, #1.Theme ] ; #4 = Aggregate [ #3 ] GroupBy [ Concert_Name ] Output [ Concert_Name, countstar AS Count_Star ]")
    , -- 7150c07fb04ec364ebd00863c0abea6344eefeff62b6937753626258890e1907
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ make = 'volvo' ] Output [ edispl, id ] ; #2 = Aggregate [ #1 ] Output [ AVG(edispl) AS Avg_edispl ]")
    , -- 73eb7b4c3f37bf11cedc8f329393c4d8a8e8cfe20fd3345a5a445897b86fa329
      (studentTranscriptsTracking, "#1 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id, student_enrolment_id ] ; #2 = Scan Table [ Transcripts ] Output [ transcript_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.transcript_id = #1.course_id ] Output [ #1.course_id, #1.transcript_id ] ; #4 = Aggregate [ #3 ] GroupBy [ course_id ] Output [ course_id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ course_id, Count_Star ]")
    , -- 5c0de2f93c0a4a04d5e485de311035b20abd380bf6580f29e898c84ac4a90fc1
      (employeeHireEvaluation, "#1 = Scan Table [ Hiring ] Output [ Shop_ID, Employee_ID ] ; #2 = Scan Table [ Evaluation ] Output [ Employee_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Employee_ID = #1.Shop_ID ] Output [ #1.Employee_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Shop_ID ] Output [ Shop_ID, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Shop_ID, Count_Star ]")
    , -- 90fe37982799391287e4f0d346699f1b44e07bfa60c82d7570607cd1983a3094
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ state_province_county = 'north carolina' ] Output [ state_province_county, address_id ] ; #2 = Scan Table [ Students ] Output [ last_name, current_address_id ] ; #3 = Except [ #1, #2 ] Predicate [ #2.current_address_id = #1.address_id ] Output [ #1.last_name ]")
    , -- f13a210a276fb5976c3336f04458fd9194497a3627777813ef7e4bed4ddb8d7c
      (car1, "#1 = Scan Table [ car_makers ] Output [ Maker, FullName ] ; #2 = Scan Table [ cars_data ] Predicate [ Year = 1970 ] Output [ Year, Id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Id = #1.Id ] Output [ #1.Maker ]")
    , -- 3bd79e8079339ca598e74c333c4128f10638b4de9de645b52185fcd23d3115a4
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Teacher_ID ] ; #2 = Scan Table [ course ] Predicate [ Course ='math' ] Output [ Course, Course_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Course = #1.Course_ID ] Output [ #1.Name ]")
    , -- 577492e72abb4721384a009437ef90d0efd51c4d0a2fac6c92e9cceed7781094
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Predicate [ template_type_code = 'ptt' ] Output [ template_type_code ] ; #2 = Scan Table [ Documents ] Output [ template_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.template_id = #1.template_id ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 9904b062c563102b86314357314958e0648753b448df996620cdf9be065e0f0e
      (museumVisit, "#1 = Scan Table [ museum ] Output [ Name, Museum_ID ] ; #2 = Scan Table [ visit ] Output [ Museum_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Museum_ID = #1.Museum_ID ] Output [ #1.Name, #2.Museum_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star, Museum_ID ]")
    , -- 769c4f1348155baa4d093eb503db38362725a9c83d68fe615b476ac3e3c2d803
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description, treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ cost_of_treatment, treatment_type_code ] ; #3 = Join [ #1, #2 ] Predicate [ #2.treatment_type_code = #1.treatment_type_code ] Output [ #1.treatment_type_description ] ; #4 = Aggregate [ #3 ] GroupBy [ treatment_type_code ] Output [ treatment_type_code, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ treatment_type_description, Count_Star ]")
    , -- 78201a51f6489492d9712ea0074012d00b05eae33689bd9392a73b71b99c588a
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ zip_code, owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.zip_code, #1.owner_id ] ; #4 = Aggregate [ #3 ] GroupBy [ owner_id ] Output [ owner_id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id, Count_Star, zip_code ]")
    , -- bd6c48013f2fe3554e4971954f587f19ac143f32bfc43bc64107385601892a7f
      (world1, "#1 = Scan Table [ country ] Predicate [ continent = 'asia' ] Output [ name, continent ] ; #2 = Scan Table [ countrylanguage ] Output [ language, percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.language ] Output [ #1.language ] ; #4 = Aggregate [ #3 ] GroupBy [ language ] Output [ language, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ language, Count_Star ]")
    , -- 6b6e1c6478e1e38f5482e86be34aee7b06e9b39a193ea87dfdd42bee7e5d3092
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name, professional_id ] ; #2 = Scan Table [ Treatments ] Output [ date_of_treatment, professional_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #1.date_of_treatment, #1.first_name ]")
    , -- 7b30574d1ca66d7665e969229dd704a800f08994530b06fe62e3eb4fb57a6ab5
      (network1, "#1 = Scan Table [ highschooler ] Output [ Name, ID ] ; #2 = Scan Table [ friend ] Output [ Student_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.ID ] Output [ #1.Name, #2.Friend_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ]")
    , -- 50b5150d0be2fb25fb3c75ba5f9efedab022b25ddecc1718f39ef2cd8d319782
      (world1, "#1 = Scan Table [ country ] Predicate [ language = 'chinese' ] Distinct [ true ] Output [ continent ] ; #2 = Aggregate [ #1 ] Output [ countstar AS Count_Star ]")
    , -- 532d1e15f99ebc54005a555098c494296d44412ee0fd0a417574833f09b82c13
      (car1, "#1 = Scan Table [ Model_List ] Output [ Maker ] ; #2 = Aggregate [ #1 ] GroupBy [ Maker ] Output [ Maker, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 3 ] Output [ Maker, Count_Star, Maker ]")
    , -- 0ab456f2fbc7de30a54a57287745b5f8e8c5e3b734a5144f44b1265e347fc73e
      (flight2, "#1 = Scan Table [ Airlines ] Output [ Country, Abbreviation, UID ] ; #2 = Scan Table [ Flights ] Output [ Airline ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Airline = #1.UID ] Output [ #1.Country, #2.Abbreviation ] ; #4 = Aggregate [ #3 ] GroupBy [ Country ] Output [ Country, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Country, Count_Star, Country, Abbreviation ]")
    , -- bcc64c0bb22e3f9f4d8fd691b32c0951929c845558050f560d0cb8ec9d35aa9f
      (orchestra, "#1 = Scan Table [ performance ] Distinct [ true ] Output [ Share ] ; #2 = Filter [ #1 ] Predicate [ Type < 'live final' ] Output [ Share ] ; #3 = Aggregate [ #2 ] GroupBy [ Share ] Output [ Share, MAX(Share) AS Max_Share, MIN(Share) AS Min_Share ]")
    , -- 9613549d75cadf3aaf9e382df3277d0bf72df467f14c96d5783c19c5479f5f9b
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ IsOfficial = 'english' OR IsOfficial = 'dutch' ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Code ] Output [ #2.Name ]")
    , -- 862cf18a84d6b570717481f1cee798370bd820600fed8d9fb547212392fc97d1
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Name, People_ID ] ; #2 = Scan Table [ poker_player ] Output [ Final_Table_Made ] ; #3 = Join [ #1, #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Name ]")
    , -- 36c7b520f8030b3154a34e0448f53c05b97574743e8f106665ad05142e78acc2
      (car1, "#1 = Scan Table [ Cars_Data ] Output [ Weight, Year ] ; #2 = Aggregate [ #1 ] GroupBy [ Weight ] Output [ Weight, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 3000 AND Count_Star < 4000 ] Output [ Count_Star, Year ]")
    , -- 08b917ef83c5cde81cdece7e98cfef78e82f1bd17c0dc8b77e8759f9fa88485a
      (wta1, "#1 = Scan Table [ Players ] Predicate [ Hand = 'left' ] Output [ Hand, Player_ID ] ; #2 = Scan Table [ Matches ] Predicate [ Tourney_Name = 'wta championships' ] Output [ Winner_Hand, Winner_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Winner_ID = #1.Player_ID ] Output [ #1.Winner_Hand ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 664f0c6f067262d02049ca69c3f9f7726e6d086c3325b29eca9eb11398448854
      (network1, "#1 = Scan Table [ highschooler ] Predicate [ Grade > 5 ] Output [ Grade, Name ] ; #2 = Scan Table [ friend ] Output [ Student_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.Student_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Name ]")
    , -- 57a37b0501428222f4c8034672ee226bc3ec6d001972e5e1b7a7218189e3276c
      (studentTranscriptsTracking, "#1 = Scan Table [ Courses ] Output [ course_name, course_id ] ; #2 = Scan Table [ Sections ] Output [ course_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.course_id = #1.course_id ] Output [ #1.course_name, #1.course_id ] ; #4 = Aggregate [ #3 ] GroupBy [ course_name ] Output [ course_name, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star < 2 ] Output [ course_name, course_id ]")
    , -- d4c083cb95db6dcb9ca733446fc4c7c4a43e2b085ee182b10d387d7b8d4694d6
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ zip_code, owner_id ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.zip_code, #1.owner_id ] ; #4 = Aggregate [ #3 ] GroupBy [ owner_id ] Output [ owner_id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id, Count_Star, zip_code ]")
    , -- 76ef862e3c511c50ec1ff363f7b90eadbad4ccac85a6b9d3d4cf4b027b49a5d1
      (network1, "#1 = Scan Table [ Highschooler ] Output [ ID ] ; #2 = Scan Table [ Friend ] Output [ Student_ID ] ; #3 = Scan Table [ Likes ] Output [ Student_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Student_ID = #2.Student_ID ] Output [ #3.ID ] ; #5 = Join [ #1, #4 ] Predicate [ #4.ID = #1.ID ] Output [ #1.ID ]")
    , -- 066534f971100acbd4ecf9d5a5ec2ac78b6c117238983af48d09b97b812e2236
      (world1, "#1 = Scan Table [ city ] Output [ Population, Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Population ] Output [ Population, SUM(Population) AS Sum_Population ] ; #3 = Filter [ #2 ] Predicate [ Sum_Population < 160000.0 ] Output [ Name ]")
    , -- cb384f0755ee64aadab7999c2dfdc55442be5549699fa4be5be6b2bc0a111457
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ Owner_ID, Last_Name ] ; #2 = Scan Table [ Dogs ] Output [ Owner_ID, Age ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Owner_ID = #1.Owner_ID ] Output [ #1.Last_Name, #1.Age ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ Age DESC ] Output [ Last_Name, Age ]")
    , -- c61132133c0884369b3656e64742fefba5bafb269a5d2e9604eed2bd4d7792f7
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id, line_1, line_2 ] ; #2 = Scan Table [ Students ] Output [ current_address_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.current_address_id = #1.address_id ] Output [ #1.current_address_id ] ; #4 = Aggregate [ #3 ] GroupBy [ current_address_id ] Output [ countstar AS Count_Star, current_address_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, current_address_id, Count_Star ]")
    , -- 95b58705014ea9cafe1d2b2967eceea55b90e10025390a1d8c79348f47380569
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description, treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ cost_of_treatment, treatment_type_code ] ; #3 = Join [ #1, #2 ] Predicate [ #2.treatment_type_code = #1.treatment_type_code ] Output [ #1.cost_of_treatment, #1.treatment_type_description ]")
    , -- 524c108e3bf0acdbbb82209403f005db8b11506bdae75cbd4850a8235c714cf5
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ id, name ] ; #2 = Scan Table [ museum ] Predicate [ open_year < 2009 ] Output [ open_year, museum_id ] ; #3 = Scan Table [ visit ] Output [ visitor_id ] ; #4 = Join [ #2, #3 ] Predicate [ #3.museum_id = #2.museum_id ] Output [ #3.visitor_id ] ; #5 = Join [ #1, #4 ] Predicate [ #4.visitor_id = #1.id ] Output [ #1.name ]")
    , -- 08dc2bd47d43756549ebaa3fc4b93ef053b8ccb78cf36090fb8b63aa8b29c96f
      (car1, "#1 = Scan Table [ cars_data ] Output [ Weight ] ; #2 = Aggregate [ #1 ] Output [ AVG(Weight) AS Avg_Weight ] ; #3 = Scan Table [ model_list ] Output [ Model, ModelId ] ; #4 = Join [ #2, #3 ] Predicate [ #3.ModelId = #2.ModelId ] Output [ #3.Model ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Avg_Weight DESC ] Output [ Model, Avg_Weight ]")
    , -- 587619e0bf6dca2cc715654f4d71bcfd092fea72301454feec993fd1010054e2
      (car1, "#1 = Scan Table [ car_makers ] Output [ ID, Maker, FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Maker = #1.ID ] Output [ #1.ID, #2.Maker ] ; #4 = Aggregate [ #3 ] GroupBy [ Maker ] Output [ Maker, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 0 ] Output [ Maker, Count_Star, Maker ]")
    , -- b622b7727c2f59b8d9162a06af9d125c7b91f2b7cad4d9ba976a52a14dcbd86b
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Age DESC ] Output [ Age, Song_Name ]")
    , -- 727d962436aa6dab57de5314949a51a9e99124c9086e4e950e58f7b3b425a9d1
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline, uid ] ; #2 = Scan Table [ Airports ] Predicate [ airportName = 'apg' ] Output [ airportName, airportCode ] ; #3 = Scan Table [ Flights ] Output [ airline, sourceAirport ] ; #4 = Join [ #2, #3 ] Predicate [ #3.sourceAirport = #2.sourceAirport ] Output [ #3.airline ] ; #5 = Join [ #1, #4 ] Predicate [ #4.airline = #1.uid ] Output [ #1.airline ]")
    , -- 6cb24d73bd9d6854c0c145accf850e49e98a77696072a3e9f52e58a90d56a1ae
      (tvshow, "#1 = Scan Table [ cartoon ] Output [ production_code, channel ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ original_air_date DESC ] Output [ production_code, channel ]")
    , -- d52b2fe734438314b9c3e2d3f0bd85983be6b638f7cdd57539fce25c52bfaa38
      (orchestra, "#1 = Scan Table [ conductor ] Distinct [ true ] Output [ name, nationality ] ; #2 = Scan Table [ conductor ] Output [ name, conductor_id ] ; #3 = Except [ #1, #2 ] Predicate [ #2.conductor_id = #1.conductor_id ] Output [ #1.name ]")
    , -- b23e766b20d801d1a7c381585433382250fd7b37aeabd1fa122e67c8d8381468
      (world1, "#1 = Scan Table [ country ] Predicate [ language = 'english' ] Output [ name, code ] ; #2 = Scan Table [ countrylanguage ] Output [ language ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.code ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 877a21ee7d3418d9490cef1dc4f37236ea50bc68c12059a9466e5e0e862ca059
      (flight2, "#1 = Scan Table [ airports ] Output [ city ] ; #2 = Scan Table [ flights ] Output [ destairport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.destairport = #1.city ] Output [ #1.destairport ] ; #4 = Aggregate [ #3 ] GroupBy [ destairport ] Output [ countstar AS Count_Star, city ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ city, Count_Star ]")
    , -- 8532df23cc7ba7610e55c027c11135e66dc3952524392a8ea9873a347c0e18b8
      (pets1, "#1 = Scan Table [ Student ] Output [ Major, Age, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' ] Distinct [ true ] Output [ PetID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.PetID = #1.PetID ] Output [ #1.Age, #1.Major ]")
    , -- ec2e71aef485eb1901917a50f7e013ff97e143dfd5f84f5c8c6c198f9a69106c
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline ] ; #2 = Scan Table [ Flights ] Output [ airline ] ; #3 = Join [ #1, #2 ] Predicate [ #2.airline = #1.uid ] Output [ #1.airline ] ; #4 = Aggregate [ #3 ] GroupBy [ airline ] Output [ airline, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star < 200 ] Output [ airline ]")
    , -- fc8eb2a4b3514db63e9649bd5c29860d9397dcfdb5806eefd7e7f601c363bf28
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ first_name, last_name, owner_id ] ; #2 = Scan Table [ Dogs ] Output [ size_code, owner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.size_code, #1.first_name, #1.last_name ]")
    , -- 68c96d827202512a504df23f6ab033cb7b1ac9782afc82257aeab24e8c645959
      (world1, "#1 = Scan Table [ country ] Output [ Population, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, Percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.CountryCode ] Output [ #1.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Language ] Output [ Language, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language, Count_Star ]")
    , -- d22f2ff3f365ceb1b3d8479abfc5a1b892b0c5d4f31164f40f8a348e01319bb4
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ]")
    , -- b3fbd3fffe1bdb198cce71e819e0cf49319e836a0ded36d695ce29110d2b43d3
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Output [ document_name, document_id ] ; #2 = Scan Table [ Paragraphs ] Output [ document_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.document_id = #1.document_id ] Output [ #1.document_name, #1.document_id ] ; #4 = Aggregate [ #3 ] GroupBy [ document_name ] Output [ document_name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ document_name, Count_Star, document_id ]")
    , -- a1e86640236a193701c725b90a1521cb34923dc534777912bbdc11ee29853b4b
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ model = 'volvo' ] Output [ cylinders, accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ accelerate DESC ] Output [ cylinders, accelerate ]")
    , -- c0c3b1cbaa2da81a562a00b83e42f0c9667e93d3156777f71ac2f1d636cfd4a6
      (car1, "#1 = Scan Table [ Model_List ] Predicate [ model = 'volvo' ] Output [ model, modelid ] ; #2 = Scan Table [ Cars_Data ] Output [ edispl, id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #2.edispl ] ; #4 = Aggregate [ #3 ] Output [ AVG(edispl) AS Avg_edispl ]")
    , -- b903ad5349ab796f8ca5e9ac20b113a4b545f06cd1b8fd03918a5b11ed313a29
      (world1, "#1 = Scan Table [ country ] Predicate [ GovernmentForm ='republic' ] Output [ GovernmentForm, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.CountryCode ] Output [ #1.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Language ] Output [ Language, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 1 ] Output [ Language ]")
    , -- 3f394f24a9ffba65e83de378069abbc3c6dc21d0e6858fd28bcaf8a4c44c069c
      (battleDeath, "#1 = Scan Table [ ship ] Predicate [ ship_type = 'brig' ] Output [ ship_type, id ] ; #2 = Scan Table [ battle ] Output [ id, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #1.name, #1.id ]")
    , -- ae0670f297cf9b8c324a52dc99fc74755fa27bb442814673d6e095611d79886f
      (creDocTemplateMgt, "#1 = Scan Table [ Ref_Template_Types ] Distinct [ true ] Output [ template_type_description ] ; #2 = Scan Table [ Templates ] Output [ template_details ] ; #3 = Join [ #1, #2 ] Predicate [ #2.template_details = #1.template_details ] Distinct [ true ] Output [ #1.template_type_description ]")
    , -- 73c8b1da8ff7be1c1d0af01653242378ba5b079a8bde31662382b9a99834ae05
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Distinct [ true ] Output [ permanent_address_id, current_address_id ] ; #2 = Aggregate [ #1 ] GroupBy [ permanent_address_id ] Output [ permanent_address_id, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star >= 1 ] Output [ first_name, Count_Star ]")
    , -- 4951f1256981c4e699025f83ed4e0568f0da2b0adfeb2a539dc76094ae288c84
      (world1, "#1 = Scan Table [ country ] Output [ Region, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'english' OR Language = 'dutch' ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #2.Region ]")
    , -- 1d475eb098ce0ad96f35972c2d26c617cfcc6e15efde805ae7ee5dbca0616181
      (wta1, "#1 = Scan Table [ matches ] Output [ Winner_Age ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Winner_Age DESC ] Output [ Winner_Age, Winner_Name, Winner_Rank ]")
    , -- 7bcbec7f9317af4cda4f934c99013fba1b27971fdf1e19b737506f1e2bbbadb7
      (pokerPlayer, "#1 = Scan Table [ poker_player ] Predicate [ Height > 200 ] Output [ Earnings, Poker_Player_ID ] ; #2 = Aggregate [ #1 ] Output [ AVG(Earnings) AS Avg_Earnings ]")
    , -- 24b9e3ac13501e8a2eb99f6d37af002f21006457b42f6138786b9a75515062a4
      (world1, "#1 = Scan Table [ country ] Predicate [ IndepYear < 1930 ] Output [ Name, IndepYear ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Name ] Output [ #1.IsOfficial ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 0f511d2d227935024ef20380b60fb30dd28ff843040398025d6c1cb4cff1ce93
      (car1, "#1 = Scan Table [ car_makers ] Output [ Maker, FullName ] ; #2 = Scan Table [ model_list ] Output [ Maker ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Maker = #1.Id ] Output [ #1.Maker, #1.FullName ] ; #4 = Aggregate [ #3 ] GroupBy [ Maker ] Output [ Maker, countstar AS Count_Star ]")
    , -- c8b3f1ae55f0334741eb68f99155ba70466e54b6e14fdf47419475fbf841cada
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Series_Name, ID ] ; #2 = Scan Table [ TV_Series ] Predicate [ Episode = 'a love of a lifetime' ] Output [ Episode, Channel ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Channel = #1.ID ] Output [ #2.Series_Name ]")
    , -- 621f50d37306c6e356a4de3df6e3793856ee7f9d9ab9b053e9890cfa5db56c89
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Distinct [ true ] Output [ first_name ] ; #2 = Scan Table [ Addresses ] Distinct [ true ] Output [ address_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.address_id = #1.address_id ] Distinct [ true ] Output [ #1.first_name ]")
    , -- 29238520da091881c4e7a017b6177cb764df61f4b23ba7e2bdb8786955bd3ad8
      (car1, "#1 = Scan Table [ car_makers ] Output [ id, maker ] ; #2 = Aggregate [ #1 ] GroupBy [ maker ] Output [ countstar AS Count_Star, maker ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 3 ] Output [ id, maker ]")
    , -- 5c61e85b2ff5cd14b865b09f64f10986de9093ff1ecd8910423dc80bd72b86ba
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language = 'french' ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.CountryCode ] Output [ #1.Name ]")
    , -- dc5f3fb7030d664528f7de029349056a952430b2c758a96323474d603b11c727
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ IsOfficial = 'french' ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Code ] Output [ #2.Name ]")
    , -- 7acbdc4f7c108ce2c675170ef55882c7b9871fe3b5c8dbfee26a6f757a027492
      (concertSinger, "#1 = Scan Table [ concert ] Output [ Concert_Name, Theme, Concert_ID ] ; #2 = Scan Table [ singer_in_concert ] Output [ Concert_ID, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #1.Concert_Name, #2.Theme, #1.Concert_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Concert_Name ] Output [ Concert_Name, countstar AS Count_Star, Concert_Name ]")
    , -- 95b11b7b6da3a1a61a86398786d17ce1182a1250691e9475819940d233798069
      (singer, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ song ] Output [ Title, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Title, #1.Name ]")
    , -- a86a96d3e0f4b6052d11149f8f2da48ab46dbd0cc3e8d64f456496fb96dff6f4
      (flight2, "#1 = Scan Table [ Airports ] Predicate [ City = 'aberdeen' ] Output [ City, AirportCode ] ; #2 = Scan Table [ Flights ] Predicate [ SourceAirport = 'aberdeen' ] Output [ Destairport, SourceAirport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.SourceAirport = #1.SourceAirport ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 1d303a4c9be0e889f0579981273206eb3953935055b14be901616cc6fc92ba5f
      (battleDeath, "#1 = Scan Table [ ship ] Output [ id, name, id ] ; #2 = Scan Table [ death ] Output [ injured, id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #1.injured, #1.id ] ; #4 = Aggregate [ #3 ] GroupBy [ id ] Output [ id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, id, name ]")
    , -- 2a4a5e75c0774a24355f23685b6e1e35bf529fbe6c142f94efbf6a9f24a57f6d
      (wta1, "#1 = Scan Table [ Players ] Output [ country_code, first_name ] ; #2 = Scan Table [ Matches ] Predicate [ winner_name = 'wta championships' ] Output [ winner_name, winner_id ] ; #3 = Scan Table [ Rankings ] Output [ player_id ] ; #4 = Join [ #2, #3 ] Predicate [ #3.player_id = #2.player_id ] Output [ #3.player_id ] ; #5 = Join [ #1, #4 ] Predicate [ #4.player_id = #1.player_id ] Output [ #1.first_name, #1.country_code ]")
    , -- 4c7d617842ecf4c2c442a7865d9226b92d5fc0b85e7dbe47701a24899111864b
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id, first_name, last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.first_name, #1.last_name, #1.owner_id ] ; #4 = Aggregate [ #3 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star, owner_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id, Count_Star, first_name, last_name ]")
    , -- ed32d95c06b758a201d5b6a501e55481c633acf085ca4187edd64f37741a20c1
      (wta1, "#1 = Scan Table [ Players ] Output [ Player_ID, First_Name, Last_Name ] ; #2 = Scan Table [ Matches ] Predicate [ Year = 2013 ] Output [ Year, Winner_ID ] ; #3 = Scan Table [ Rankings ] Output [ Player_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Player_ID = #2.Player_ID ] Output [ #3.Player_ID ] ; #5 = Join [ #1, #4 ] Predicate [ #4.Player_ID = #1.Player_ID ] Output [ #1.First_Name ]")
    , -- 4eaa950c1003fdf45a32673b42ff643ccb4dd6ed5d95e36682f364519dcc349b
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Birth_Date, People_ID ] ; #2 = Scan Table [ poker_player ] Output [ Earnings, Poker_Player_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Poker_Player_ID = #1.Poker_Player_ID ] Output [ #1.Earnings ] ; #4 = Aggregate [ #3 ] GroupBy [ Earnings ] Output [ Earnings, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Earnings, Count_Star ]")
    , -- 5c853eed095b6baf4df9f2f0070d754fac01d936f3136ee93d9295666ec32afc
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'welcome to ny' ] Output [ Document_Name, Document_ID ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID, Paragraph_Text ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text, #2.Paragraph_ID ]")
    , -- 2302a1b8bb2111d71497b49f79a57e7db73f1de39aa54c60c1bab8fae0217a10
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name, middle_name, last_name ] ; #2 = Scan Table [ Student_Enrolment ] Predicate [ degree_program_id = 'bachelors' ] Output [ degree_program_id, student_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.student_id = #1.student_id ] Output [ #1.first_name, #2.middle_name, #1.last_name ]")
    , -- 2ff92e902d385f0d3c7c7ac8839232b8f21877f00a5e4efad288d1204c1383cd
      (battleDeath, "#1 = Scan Table [ battle ] Output [ name, result, bulgarian_commander, latin_commander ] ; #2 = Scan Table [ ship ] Predicate [ location = 'english channel' ] Output [ location, lost_in_battle ] ; #3 = Join [ #1, #2 ] Predicate [ #2.lost_in_battle = #1.id ] Output [ #1.name, #2.result, #1.bulgarian_commander ]")
    , -- 9ac26cfb14e02c1544639c9d16255b9fe612fbbfbf90f627a8c841571f1565b1
      (network1, "#1 = Scan Table [ highschooler ] Output [ id, name ] ; #2 = Scan Table [ friend ] Output [ student_id ] ; #3 = Aggregate [ #2 ] GroupBy [ student_id ] Output [ countstar AS Count_Star, student_id ] ; #4 = Join [ #1, #3 ] Predicate [ #3.student_id = #1.id ] Output [ #1.name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name, Count_Star ]")
    , -- 5f6c5c97e4535a57a648be9149e33db7045c08bc96516c2e753c41f04e1e2583
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ IsOfficial = 'english' OR IsOfficial = 'dutch' ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Code ] Output [ #2.Name ]")
    , -- 216deec7ce39e86c5ef67a4c5259db2aeabae0a3db17c2270cc93df36cee7e30
      (tvshow, "#1 = Scan Table [ TV_Channel ] Distinct [ true ] Output [ Language, Pixel_Aspect_Ratio_Par, Country ] ; #2 = Scan Table [ TV_Channel ] Output [ Country, Pixel_Aspect_Ratio_Par ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Country = #1.Country ] Output [ #1.Pixel_Aspect_Ratio_Par, #1.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Country ] Output [ Country, SUM(Pixel_Aspect_Ratio_Par) AS Sum_Pixel_Aspect_Ratio_Par ] ; #5 = Filter [ #4 ] Predicate [ Sum_Pixel_Aspect_Ratio_Par = 1 ] Output [ Country, Sum_Pixel_Aspect_Ratio_Par, Sum_Pixel_Aspect_Ratio_Par ]")
    , -- dce5580fa604cef1b7013efde88ea414c1480828f0c15e0c53b05b4ef6ff025b
      (tvshow, "#1 = Scan Table [ tv_series ] Predicate [ episode = 'a love of a lifetime' ] Output [ episode, id ] ; #2 = Scan Table [ cartoon ] Output [ id, title ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #1.title ]")
    , -- a5b58ec921e463893a58faab86400b125f114b5c0469aa70c41f39267cc6731e
      (orchestra, "#1 = Scan Table [ orchestra ] Output [ Orchestra ] ; #2 = Scan Table [ performance ] Output [ Orchestra_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Orchestra_ID = #1.Orchestra_ID ] Output [ #1.Orchestra ]")
    , -- ee837d790c1052adcb9de495cfc9af05e217e5ad8839eeddf75d4cadfbd199fd
      (wta1, "#1 = Scan Table [ Players ] Output [ player_id, first_name, last_name ] ; #2 = Scan Table [ Matches ] Output [ winner_rank, winner_name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_rank = #1.player_id ] Output [ #1.winner_name, #1.winner_rank_points ] ; #4 = Aggregate [ #3 ] GroupBy [ winner_name ] Output [ countstar AS Count_Star, winner_name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ winner_name, Count_Star, winner_rank_points ]")
    , -- 09a03a898de94d379933b176c750be6d83e799a2d7d31e03de82e63888e69ed1
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ First_Name, Last_Name, Owner_ID ] ; #2 = Scan Table [ Dogs ] Output [ Size_Code, Owner_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Owner_ID = #1.Owner_ID ] Output [ #1.First_Name, #1.Last_Name, #1.Size_Code ]")
    , -- 6632e3ca9157ea891f945858d65d51a7c21b4b3beac8b3d957f92610d775da20
      (flight2, "#1 = Scan Table [ flights ] Predicate [ sourceAirport = 'cvo' ] Distinct [ true ] Output [ airline ] ; #2 = Scan Table [ flights ] Predicate [ destairport = 'apg' ] Distinct [ true ] Output [ airline ] ; #3 = Join [ #1, #2 ] Predicate [ #2.airline = #1.uid ] Distinct [ true ] Output [ #1.airline ]")
    , -- b77fa3b8526203bcd90c712fdbdee81795d22020a91667f2c3c3d49f348b347a
      (flight2, "#1 = Scan Table [ Airports ] Predicate [ City = 'aberdeen' ] Output [ City ] ; #2 = Scan Table [ Flights ] Output [ Destairport, SourceAirport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.SourceAirport = #1.SourceAirport ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 5a1add434252fa8ef88afe242d0e6f6da6ebe21eab7ebb70940db2d4060acb6e
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id, line_1 ] ; #2 = Scan Table [ Students ] Output [ current_address_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.current_address_id = #1.address_id ] Output [ #1.current_address_id ] ; #4 = Aggregate [ #3 ] GroupBy [ current_address_id ] Output [ current_address_id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ current_address_id, Count_Star ]")
    , -- 6b4935ecf21e96347d09f914c1134d872dd90cea1d200906b8422cec79050abe
      (car1, "#1 = Scan Table [ Car_Names ] Predicate [ Make = 'amc hornet sportabout (sw)' ] Output [ Make, MakeId ] ; #2 = Scan Table [ Cars_Data ] Output [ Accelerate, Id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Id = #1.Id ] Output [ #1.Accelerate ]")
    , -- 61b6eaccc94d6d2900ca8a1d8163d9c358c6a9d2034e1abc1e0f04df540300a6
      (tvshow, "#1 = Scan Table [ TV_Series ] Predicate [ series_name ='sky radio' ] Output [ episode, id ]")
    , -- 76315f6ac3350f7af835b9f7f6a46ec89579cd792877b93f61a84ee2ad621932
      (network1, "#1 = Scan Table [ highschooler ] Predicate [ Name = 'kyle' ] Output [ Name, ID ] ; #2 = Scan Table [ friend ] Output [ Student_ID, Friend_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.ID ] Output [ #1.Friend_ID ]")
    , -- 1e794a6002b4eb201d69fd387733237b9ee039ee07e7e045ed7bcba1df37db8f
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ country, series_name ] ; #2 = Scan Table [ Cartoon ] Predicate [ directed_by = 'ben jones' AND directed_by ='michael chang' ] Output [ directed_by, channel ] ; #3 = Join [ #1, #2 ] Predicate [ #2.channel = #1.id ] Output [ #2.series_name, #2.country ]")
    , -- eb3cde0276a0fc8b1f8d2f8fafb35798919522c42a6092dd8e015b09b31af5f9
      (car1, "#1 = Scan Table [ Countries ] Output [ countryname, countryid ] ; #2 = Scan Table [ Car_Makers ] Output [ country ] ; #3 = Aggregate [ #2 ] GroupBy [ country ] Output [ countstar AS Count_Star, country ] ; #4 = Join [ #1, #3 ] Predicate [ #3.country = #1.countryid ] Output [ #1.countryname ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ countryname, Count_Star ]")
    , -- ec8b526c55f9a125041bfebfcd2a771dfccddcf370f22042f6b1147afdcaafe4
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID, PetID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.PetID ] ; #4 = Aggregate [ #3 ] GroupBy [ PetID ] Output [ PetID, countstar AS Count_Star ]")
    , -- 63bfffa86de5ddf9518ff92a308340dbf0884a3e273892bfb044d3f7c7fbe2a3
      (flight2, "#1 = Scan Table [ Airports ] Output [ AirportName, AirportCode ] ; #2 = Scan Table [ Flights ] Output [ SourceAirport ] ; #3 = Scan Table [ Airports ] Output [ AirportName, AirportCode ] ; #4 = Join [ #2, #3 ] Predicate [ #3.SourceAirport = #2.SourceAirport ] Output [ #3.AirportName ] ; #5 = Except [ #1, #4 ] Predicate [ #4.AirportName = #1.AirportName ] Output [ #1.AirportName ]")
    , -- d1f8533f2672bfc50cab0c09ffe4250953ede5126b08584e81b5315b1947af94
      (world1, "#1 = Scan Table [ country ] Output [ code, name ] ; #2 = Scan Table [ countrylanguage ] Predicate [ language < 'english' ] Output [ language, countrycode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.countrycode = #1.code ] Output [ #1.countrycode ]")
    , -- 134c01a812f1d002b8ec3b1bada53172b4e50778eb87d5b24cb776d6a94c731f
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Birth_Date, People_ID ] ; #2 = Scan Table [ poker_player ] Output [ Earnings, Poker_Player_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Poker_Player_ID = #1.Poker_Player_ID ] Output [ #1.Earnings ] ; #4 = Aggregate [ #3 ] GroupBy [ Earnings ] Output [ Earnings, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Earnings, Count_Star ]")
    , -- 997a9d9b23d45ca4e3b077ba7f5a6f03f5475311200c92805f200366cfc56736
      (voter1, "#1 = Scan Table [ Area_Code_State ] Output [ Area_Code, State ] ; #2 = Scan Table [ Contestants ] Predicate [ Contestant_Name = 'tabatha gheling' ] Output [ Contestant_Name, Contestant_Number ] ; #3 = Scan Table [ Votes ] Output [ Contestant_Number ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Contestant_Number = #2.Contestant_Number ] Output [ #3.Area_Code ] ; #5 = Join [ #1, #4 ] Predicate [ #4.Area_Code = #1.Area_Code ] Output [ #1.Area_Code ]")
    , -- cc65ca5065252da2020bf5040dd74af587bed02d69e4980d862e8216f0a767b3
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Series_Name ='sky radio' ] Output [ Series_Name, ID ] ; #2 = Scan Table [ Cartoon ] Output [ Title, ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.ID = #1.ID ] Output [ #1.Title ]")
    , -- 0236e60074389525ae99b74bd2a1c01b56e74854227b6ac59849d44d9a5c6c00
      (world1, "#1 = Scan Table [ city ] Distinct [ true ] Output [ name ] ; #2 = Scan Table [ country ] Predicate [ continent = 'asia' ] Output [ name, continent ] ; #3 = Scan Table [ countrylanguage ] Output [ language, isofficial ] ; #4 = Join [ #2, #3 ] Predicate [ #3.language = #2.language ] Distinct [ true ] Output [ #3.name ] ; #5 = Join [ #1, #4 ] Predicate [ #4.name = #1.name ] Distinct [ true ] Output [ #1.name ]")
    , -- 68a7c7be81a8bd9b48f9750cfc34bfa65110ac9eacce30055ad944d8300f8166
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Hometown ] ; #2 = Scan Table [ course_arrange ] Predicate [ Teacher_ID = 1 ] Output [ Teacher_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- 56d9b7569da6cfd36c31daac378eeebeed9acb76698e67c63f49a3fce4e8d187
      (network1, "#1 = Scan Table [ Highschooler ] Output [ Name, ID ] ; #2 = Scan Table [ Friend ] Output [ Student_ID ] ; #3 = Scan Table [ Likes ] Output [ Student_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Student_ID = #2.Student_ID ] Output [ #3.ID ] ; #5 = Join [ #1, #4 ] Predicate [ #4.ID = #1.ID ] Output [ #1.Name ]")
    , -- e6393c117f414da854c082eff60f93bd0300723381b35c6e2b65aaba840d0ea0
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ country, series_name, id ] ; #2 = Scan Table [ Cartoon ] Predicate [ directed_by ='michael chang' ] Output [ directed_by, channel ] ; #3 = Join [ #1, #2 ] Predicate [ #2.channel = #1.id ] Output [ #2.series_name, #2.country ]")
    , -- 1e89d560ac01a52205cd8edb1ad7d22d0084f87bb2d16c76405f82f6eed14cf0
      (pets1, "#1 = Scan Table [ Student ] Output [ Fname, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'dog' AND PetID = 'cat' ] Output [ PetID, StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Fname ]")
    , -- e0e10dd96631c9a039a0f6b68747d5eef73a3e9e37063de7381bdd2b09913603
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year, Concert_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Concert_ID = #1.Concert_ID ] Output [ #2.Name ]")
    , -- a72bc94122c8335bb8ef116a28ae80c1bcafdbcf89ef8fca8233fe7a04a89520
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ Professional_ID, Cell_Number ] ; #2 = Scan Table [ Treatments ] Output [ Professional_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Professional_ID = #1.Professional_ID ] Output [ #1.Cell_Number, #1.Professional_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Professional_ID ] Output [ Professional_ID, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Professional_ID, Cell_Number ]")
    , -- 3ef872547c3c849b72137303c2397e4ddfa5620f0a8444b059405f38009ac1b5
      (voter1, "#1 = Scan Table [ Contestants ] Predicate [ Contestant_Name = 'tabatha gheling' ] Output [ Contestant_Name, Contestant_Number ] ; #2 = Scan Table [ Votes ] Output [ State, Phone_Number, Created ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Contestant_Number = #1.Contestant_Number ] Output [ #2.State, #2.Phone_Number, #2.Created ]")
    , -- 18410d6eea9eaaa4ded15500a3cfd28e14e048a9c0b11d9c6c27f1ebd20ba32c
      (pets1, "#1 = Scan Table [ Student ] Output [ Fname, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' AND PetID = 'dog' ] Output [ PetID, StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Fname ]")
    , -- c07bf8a5269d2f7e7fb84ce9604b7842d48ec4c1986c122f1982a9ad675efea5
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID, Fname, Sex ] ; #2 = Scan Table [ Has_Pet ] Output [ StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Fname, #1.Sex, #1.StuID ] ; #4 = Aggregate [ #3 ] GroupBy [ StuID ] Output [ StuID, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ StuID, Count_Star, Fname, Sex ]")
    , -- 728498cf775875068b9bab8aa842056887ff0d7f89672525110cc65529a4fbef
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name, middle_name, last_name, student_id ] ; #2 = Scan Table [ Student_Enrolment ] Predicate [ semester_id = 1 ] Output [ student_id, degree_program_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.degree_program_id = #1.degree_program_id ] Output [ #2.student_id, #1.first_name, #1.middle_name, #1.last_name ] ; #4 = Aggregate [ #3 ] GroupBy [ first_name, middle_name, last_name ] Output [ first_name, middle_name, last_name, student_id ]")
    , -- cf7eea7b6f50c57390d38c86939bf535a224b057c31c25a666208629c5ce7a00
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ IsOfficial = 'french' ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Code ] Output [ #2.Name ]")
    , -- 1b4a7a6a4a6edbd99f288bea34b33440647837c357c6aaea4af04799805c576e
      (wta1, "#1 = Scan Table [ Players ] Predicate [ hand = 'left' ] Output [ hand, player_id ] ; #2 = Scan Table [ Matches ] Predicate [ tourney_name = 'wta championships' ] Output [ winner_hand, winner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_id = #1.player_id ] Distinct [ true ] Output [ #1.winner_hand ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 550e5e82df704280579aec36cce4557a6a0a38b91cf057b63a589c368210022a
      (singer, "#1 = Scan Table [ singer ] Distinct [ true ] Output [ Name, Citizenship ] ; #2 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name ]")
    , -- 0a0317dc30dddb0490383d219a1b1f2002d1ff2a27e96ed69090c468a73e9bcb
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ id, name, age ] ; #2 = Scan Table [ visit ] Output [ visitor_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.visitor_id = #1.id ] Output [ #1.name, #2.age, #1.id ] ; #4 = Aggregate [ #3 ] GroupBy [ id ] Output [ id, countstar AS Count_Star, name, age ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 1 ] Output [ id, name, age ]")
    , -- ed11ccc0c371befb3ffe3ea94cf16a1727cea5fdbd0c2379b78d4891bcd8f1a9
      (car1, "#1 = Scan Table [ Model_List ] Output [ model ] ; #2 = Scan Table [ Cars_Data ] Output [ horsepower ] ; #3 = Join [ #1, #2 ] Predicate [ #2.horsepower = #1.id ] Output [ #1.model ] ; #4 = Aggregate [ #3 ] GroupBy [ model ] Output [ model, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ model, Count_Star ]")
    , -- 950b12210f92f7fe8accf0f9ee01cdde5d5eddbb4ee55d11c62f35fcbd04a945
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Song_Name, Age ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Age DESC ] Output [ Song_Name, Age, Song_Release_Year ]")
    , -- 76aabb0a0ad501bbb8c847b9056b539fcd3780a5c7da5f754aee2fc436378746
      (world1, "#1 = Scan Table [ country ] Predicate [ HeadOfState = 'beatrix' ] Output [ HeadOfState, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Language ]")
    , -- 7e07965719bdc4b883c84663dcc9b66ffdf2d7e962e4fcf8cebbdc95bad61b70
      (car1, "#1 = Scan Table [ Car_Makers ] Predicate [ FullName = 'general motors' ] Output [ Maker, FullName ] ; #2 = Scan Table [ Model_List ] Output [ Maker, Model ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Maker = #1.Maker ] Distinct [ true ] Output [ #1.Model ]")
    , -- 67897312488350728a9012ddf25e860149ea5ed4025d589030cc862639fddb39
      (world1, "#1 = Scan Table [ country ] Predicate [ Region = 'dutch' OR Region = 'english' ] Output [ Region, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Region ] Output [ Region, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Region, Count_Star ]")
    , -- 41d3e92c786b0b23ab2969a8beed1284689a19b42473d98e6fdd654c6b4f7a2a
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Name, Location, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 OR Year = 2015 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #2.Location ]")
    , -- 67ad6ffc709d3e44ff5f84c9af0a4d2e16a89919d6c6f723b770165a6314e930
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Series_Name ='sky radio' ] Output [ Series_Name, ID ] ; #2 = Scan Table [ Cartoon ] Output [ Title, ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.ID = #1.ID ] Output [ #1.Title ]")
    , -- f23d812f404ef6bef6297f48075b5a591f9c60c9f97f36861c9b5abce2350a5f
      (car1, "#1 = Scan Table [ Countries ] Output [ CountryId, CountryName ] ; #2 = Scan Table [ Car_Makers ] Predicate [ Maker = 'fiat' ] Output [ Country, Maker ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Country = #1.CountryId ] Output [ #1.CountryName, #1.Id ] ; #4 = Aggregate [ #3 ] GroupBy [ CountryId ] Output [ CountryId, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 3 ] Output [ CountryId, CountryName ]")
    , -- 1e42d2900c9e527b66357dcab22aba24c3b4847d0413b659e3577639518175f7
      (world1, "#1 = Scan Table [ country ] Predicate [ name = 'aruba' ] Output [ name, code ] ; #2 = Scan Table [ countrylanguage ] Output [ language, percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.code ] Output [ #1.language ] ; #4 = Aggregate [ #3 ] GroupBy [ language ] Output [ language, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ language, Count_Star ]")
    , -- b502c155fba512cabb54000e371ee35e6737c6de75d89889c83254465c86e8c4
      (car1, "#1 = Scan Table [ Model_List ] Distinct [ true ] Output [ model ] ; #2 = Scan Table [ Car_Names ] Predicate [ make = 'ford motor company' ] Output [ model, make ] ; #3 = Join [ #1, #2 ] Predicate [ #2.model = #1.model ] Distinct [ true ] Output [ #1.model ] ; #4 = Scan Table [ Cars_Data ] Output [ weight, id ] ; #5 = Filter [ #4 ] Predicate [ weight < 3500 ] Output [ weight, id ] ; #6 = Join [ #3, #5 ] Predicate [ #5.id = #3.id ] Distinct [ true ] Output [ #5.weight ]")
    , -- 3a3c210329f066c16ae725a134bcf591f4cb70fa224a580ef0a2c17a0f9f0c2a
      (studentTranscriptsTracking, "#1 = Scan Table [ Student_Enrolment_Courses ] Output [ course_id, student_enrolment_id ] ; #2 = Scan Table [ Transcript_Contents ] Output [ student_course_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.student_course_id = #1.course_id ] Output [ #1.course_id, #1.transcript_id ] ; #4 = Aggregate [ #3 ] GroupBy [ course_id ] Output [ countstar AS Count_Star, course_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ course_id, Count_Star ]")
    , -- 78180afbb85c0ff5153d14edb5060ddbd3cc213bd221da87adef21a8d4c73e41
      (wta1, "#1 = Scan Table [ Players ] Output [ first_name, player_id ] ; #2 = Scan Table [ Rankings ] Output [ ranking_points, player_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.player_id = #1.player_id ] Output [ #1.ranking_points, #1.first_name ]")
    , -- 8b33d8ebee3c820fd9c6f45fa6f76eeda92b42b72cc32487f29cfa4b79175f7b
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ State = 'indiana' ] Output [ Professional_ID, Last_Name, Cell_Number, State ] ; #2 = Scan Table [ Treatments ] Output [ Professional_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Professional_ID = #1.Professional_ID ] Output [ #1.Last_Name, #2.Cell_Number ] ; #4 = Aggregate [ #3 ] GroupBy [ Last_Name ] Output [ Last_Name, Cell_Number, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Last_Name, Cell_Number, Count_Star ]")
    , -- 9185b99e6274a74f1074d9390674f68dc176f3bd9f95bc67ad3b09b878fccc3a
      (car1, "#1 = Scan Table [ Model_List ] Output [ Maker ] ; #2 = Aggregate [ #1 ] GroupBy [ Maker ] Output [ Maker, countstar AS Count_Star, Maker ]")
    , -- 1d2463926c06c0b305d781cd6e0713784fbcac3498b19ded257d886e67364acc
      (world1, "#1 = Scan Table [ country ] Predicate [ HeadOfState = 'beatrix' ] Output [ Name, HeadOfState ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Name ] Output [ #1.IsOfficial ]")
    , -- bc82973d8a4f671f6ef6a3b4e3a994c811d7f72d0410a6437d4195f8c5b8a0ce
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = Filter [ #2 ] Predicate [ Avg_Age >= 1 ] Output [ Song_Name ]")
    , -- bd50cd3346fb9f7ff49fe956873de002222ca6019f59ecc9c76a1e5b989eb493
      (car1, "#1 = Scan Table [ cars_data ] Output [ Weight ] ; #2 = Aggregate [ #1 ] Output [ AVG(Weight) AS Avg_Weight ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Weight DESC ] Output [ Weight, Avg_Weight ]")
    , -- d0a296f1837c86b98749f120148d725826c46b39b052aeb796e95d08240be359
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_program_id, degree_summary_name ] ; #2 = Aggregate [ #1 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star, degree_program_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_program_id, Count_Star, degree_summary_name ]")
    , -- 66ca5dbbeaf6330e1e4962deede1ffbb618a38a3ed59cf7c08d11c553f1497cb
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ owner_id, first_name, last_name ] ; #2 = Scan Table [ Dogs ] Output [ owner_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.owner_id, #1.first_name, #1.last_name ] ; #4 = Aggregate [ #3 ] GroupBy [ owner_id ] Output [ countstar AS Count_Star, owner_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ owner_id, Count_Star, first_name, last_name ]")
    , -- 287c13b7cc426c370cd220879683109522739aad32877db06c470639a03a973a
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Teacher_ID ] ; #2 = Scan Table [ course_arrange ] Output [ Teacher_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name, #2.Course_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ]")
    , -- 5ff7298e82e25f73402caec694fb894b9528e6e8552ae504972b448f45281a6b
      (world1, "#1 = Scan Table [ country ] Output [ Population, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ Language ='spainish' ] Output [ Language, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Population, #1.CountryCode ] ; #4 = Aggregate [ #3 ] GroupBy [ CountryCode ] Output [ CountryCode, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ CountryCode, Count_Star ]")
    , -- 751312a14e1b895457b1e3416dd352a7abcadef9679147be4cb3252af11101a7
      (network1, "#1 = Scan Table [ highschooler ] Output [ Name, ID ] ; #2 = Scan Table [ friend ] Output [ Student_ID ] ; #3 = Scan Table [ likes ] Output [ Student_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Student_ID = #2.Student_ID ] Output [ #3.Name ] ; #5 = Join [ #1, #4 ] Predicate [ #4.Name = #1.Name ] Output [ #1.Name ]")
    , -- eded0e3c6d25bb3895cd6104eb9495428d4b8d1a9186de3ce6786eedecc9a792
      (dogKennels, "#1 = Scan Table [ Owners ] Output [ First_name, Owner_ID ] ; #2 = Scan Table [ Dogs ] Output [ Name, Owner_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Owner_ID = #1.Owner_ID ] Output [ #1.Name, #1.First_name ]")
    , -- af31c2dbac0d1ab65d2339c0d55235dc257c160e670af45309e001bba3098cdd
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description, treatment_type_code ] ; #2 = Scan Table [ Professionals ] Output [ first_name, professional_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #1.first_name, #2.treatment_type_code ]")
    , -- e75d3a7f87b0a33d06fce6ca17196f4c588fc1be645276004b8fc026e5de12d8
      (singer, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ song ] Output [ Title, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Title, #2.Name ]")
    , -- 4e2a3009bf1eeef36db8e5fde67079e87dc569572f0683cc2aa31d95e6f5b471
      (car1, "#1 = Scan Table [ Cars_Data ] Distinct [ true ] Output [ Accelerate ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ Cylinders, MAX(Accelerate) AS Max_Accelerate ]")
    , -- 3d3eca8148eb50a89b259e7e52852f0bc74562a78e97347bc1fabc4ccd9f2592
      (creDocTemplateMgt, "#1 = Scan Table [ Documents ] Predicate [ Document_Name = 'welcome to ny' ] Output [ Document_ID, Document_Name ] ; #2 = Scan Table [ Paragraphs ] Output [ Document_ID, Paragraph_Text ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Document_ID = #1.Document_ID ] Output [ #2.Paragraph_Text, #2.Paragraph_ID ]")
    , -- d4a90c1eaa15edba9a6d3920f3e16b7bfa906ace797d675ad139dd1f1982ae08
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ shop_id, name ] ; #2 = Scan Table [ hiring ] Output [ shop_id, employee_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.shop_id = #1.shop_id ] Output [ #1.shop_id, #1.employee_id ] ; #4 = Aggregate [ #3 ] GroupBy [ shop_id ] Output [ shop_id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ shop_id, Count_Star, name ]")
    , -- 3527f8c88c2c02b87402400adb4ca1df78d5a8ed8137a2e68e5ae161490f83b2
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Height, People_ID ] ; #2 = Scan Table [ poker_player ] Output [ Money_Rank, People_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Money_Rank ] ; #4 = Aggregate [ #3 ] GroupBy [ Money_Rank ] Output [ Money_Rank, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Money_Rank, Count_Star ]")
    , -- fc6edbd3e37d50acc7d2b3f1a3c6d66eccec37a36afcf02f8f6a14bfc7f951bc
      (wta1, "#1 = Scan Table [ Players ] Output [ Player_ID, First_Name ] ; #2 = Scan Table [ Rankings ] Output [ Ranking_Points, Player_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Player_ID = #1.Player_ID ] Output [ #1.Ranking_Points, #1.First_Name ] ; #4 = Aggregate [ #3 ] GroupBy [ First_Name ] Output [ SUM(Ranking_Points) AS Sum_Ranking_Points, First_Name ]")
    , -- 64753597dc7d6d2a32db6eda3baa31e7ee2d2fb6ecd4b920fe5b970040457805
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country, Series_Name ] ; #2 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by, Channel ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Channel = #1.Series_Name ] Output [ #2.Country ]")
    , -- e24d36718f19f2c01300c0eb31b9ef1c7049290a48400f756e3898c3de1ba7cd
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' ] Distinct [ true ] Output [ StuID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.StuID ]")
    , -- 4ee8e06d6ea0494afddda0a73ba51a5f3c93bfded92d39d8fef5436b57c0689b
      (studentTranscriptsTracking, "#1 = Scan Table [ Student_Enrolment ] Output [ semester_id ] ; #2 = Aggregate [ #1 ] GroupBy [ semester_id ] Output [ countstar AS Count_Star, semester_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ semester_id, Count_Star, semester_name ]")
    , -- c8a261b56b3fd317715e20ae964633fe39d27e415421d119333cd698a3f48fb7
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ first_name, last_name, professional_id ] ; #2 = Scan Table [ Treatments ] Output [ cost_of_treatment, professional_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #1.cost_of_treatment, #1.first_name, #1.last_name ] ; #4 = Aggregate [ #3 ] GroupBy [ cost_of_treatment ] Output [ cost_of_treatment, AVG(cost_of_treatment) AS Avg_cost_of_treatment, first_name, last_name ]")
    , -- 5f825d0ca7aab228d5c0ae6793b47a6d6044a166df89612088071c3bbdf4a22e
      (wta1, "#1 = Scan Table [ matches ] Output [ Winner_Age ] ; #2 = TopSort [ #1 ] Rows [ 3 ] OrderBy [ Winner_Age DESC ] Output [ Winner_Age, Winner_Name, Winner_Rank ]")
    , -- bd21f664a846bc1fe7d88e638adb44527375b28722a48eb0c8675360b6696489
      (battleDeath, "#1 = Scan Table [ ship ] Predicate [ name = 'lettece' AND name = 'hms atalanta' ] Output [ lost_in_battle, name, id ] ; #2 = Scan Table [ battle ] Output [ name, date, id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #1.name, #1.date ]")
    , -- 9a73a6338b34f5e65b5cc27586bccdf5fe018eeda56c944a0b2b0b9f7e6ca09c
      (flight2, "#1 = Scan Table [ airports ] Output [ AirportName ] ; #2 = Scan Table [ flights ] Output [ SourceAirport ] ; #3 = Except [ #1, #2 ] Predicate [ #2.SourceAirport = #1.SourceAirport ] Output [ #1.AirportName ]")
    , -- d50de1020d3dcee5416196b209cf716fef84d0120bf108e9619ecbca20df62a3
      (flight2, "#1 = Scan Table [ airlines ] Predicate [ airline = 'united airlines' ] Output [ airline, uid ] ; #2 = Scan Table [ airports ] Predicate [ airportname = 'ahd' ] Output [ airportname, airportcode ] ; #3 = Scan Table [ flights ] Output [ sourceairport, airline ] ; #4 = Join [ #2, #3 ] Predicate [ #3.sourceairport = #2.sourceairport ] Output [ #3.airline ] ; #5 = Aggregate [ #4 ] Output [ countstar AS Count_Star ]")
    , -- c0a96b9f9d0925f4b25d2753c394e50199efd3b2e713af2553e63e9a993cd92f
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Predicate [ state_province_county = 'north carolina' ] Output [ state_province_county, address_id ] ; #2 = Scan Table [ Students ] Output [ last_name, student_id ] ; #3 = Except [ #1, #2 ] Predicate [ #2.student_id = #1.student_id ] Output [ #1.last_name ]")
    , -- 647d2db94feaabbbdd3eecac3a26c557b1fb2a27a9e69a1f852d55b418ac6428
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 ] Output [ Year, Concert_ID ] ; #3 = Scan Table [ singer_in_concert ] Output [ Singer_ID ] ; #4 = Join [ #2, #3 ] Predicate [ #3.Singer_ID = #2.Singer_ID ] Output [ #3.Name ]")
    , -- c3998b7c1feeb87bae4cca7d360728a072f24c52445c2355240738d9e27063b6
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline, uid ] ; #2 = Scan Table [ Airports ] Predicate [ airportName = 'ahd' ] Output [ airportName, airportCode ] ; #3 = Scan Table [ Flights ] Output [ airline, destairport ] ; #4 = Join [ #2, #3 ] Predicate [ #3.destairport = #2.destairport ] Output [ #3.airline ]")
    , -- 24a2b7acc32937966d07d1265d8dc136e4be76b7cfe7bf73b2ac90793d0c310b
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id, first_name, middle_name, last_name, student_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.student_id = #1.student_id ] Output [ #1.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star, student_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, student_id, first_name, middle_name, last_name, student_id ]")
    , -- 462c2d108962edbbd5ff717ecf50a4f519aa59429596a9368897cbebb5f5f36f
      (car1, "#1 = Scan Table [ Countries ] Output [ CountryName, CountryId ] ; #2 = Scan Table [ Car_Makers ] Output [ Country ] ; #3 = Aggregate [ #2 ] GroupBy [ Country ] Output [ Country, countstar AS Count_Star ] ; #4 = Join [ #1, #3 ] Predicate [ #3.Country = #1.CountryId ] Output [ #1.CountryName, #1.CountryId ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 1 ] Output [ CountryName, CountryId ]")
    , -- 34572d6690f52e3ae8b1930d673e5bb162d889950786a5123cf119a1dab9cc1e
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ degree_program_id, degree_summary_description ] ; #2 = Aggregate [ #1 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star, degree_program_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ degree_program_id, Count_Star, degree_summary_description ]")
    , -- 17831c8c47493e469a43da0b31f0b95d91ce356b726429b57d3929c4aa04974e
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_code, breed_name ] ; #2 = Scan Table [ Dogs ] Output [ breed_code, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #1.name, #2.breed_code ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_code ] Output [ breed_code, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ breed_code, Count_Star, name ]")
    , -- 9a5c03af4b83ba7b55e93a138b9c8711e265ee47ca1a1ffa85059523cee22920
      (employeeHireEvaluation, "#1 = Scan Table [ Hiring ] Output [ Shop_ID, Employee_ID ] ; #2 = Scan Table [ Evaluation ] Output [ Employee_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Employee_ID = #1.Shop_ID ] Output [ #1.Employee_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Shop_ID ] Output [ Shop_ID, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star = 0 ] Output [ Shop_ID, Count_Star ]")
    , -- 9eb49aca2584d05d0366be17ba34ccfb07f238dffed751db48a4e86346eb6789
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ first_name, middle_name, last_name ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ date_first_registered DESC ] Output [ first_name, middle_name, last_name ]")
    , -- 546ff06611de4b3ac4065c402b00c84c621762013d5a957cafdab6b13860ac83
      (pets1, "#1 = Scan Table [ Student ] Output [ LName, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ Pet_Age = 3 ] Output [ PetID, StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.LName ]")
    , -- 847022cb66cc94760f125822895688d689431d8dd110319a78dea3ac54d8e390
      (creDocTemplateMgt, "#1 = Scan Table [ Templates ] Output [ Template_Type_Code ] ; #2 = Scan Table [ Documents ] Output [ Template_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Template_ID = #1.Template_ID ] Output [ #1.Template_Type_Code ] ; #4 = Aggregate [ #3 ] GroupBy [ Template_Type_Code ] Output [ Template_Type_Code, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Template_Type_Code, Count_Star ]")
    , -- b42c56ca3986518a42d21d9a1861a788415493c0260395d2d232b10d6da2bb65
      (world1, "#1 = Scan Table [ country ] Output [ Name, Code ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, Percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #1.Language ] ; #4 = Aggregate [ #3 ] GroupBy [ Language ] Output [ Language, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Language, Count_Star ]")
    , -- a7ac46f6fac1b59f3e7af600f51d43c2cb3e999a65bed7a25b53c188b5ea89d5
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ Professional_ID, Cell_Number ] ; #2 = Scan Table [ Treatments ] Output [ Professional_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Professional_ID = #1.Professional_ID ] Output [ #1.Cell_Number, #1.Professional_ID ] ; #4 = Aggregate [ #3 ] GroupBy [ Professional_ID ] Output [ Professional_ID, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Professional_ID, Cell_Number ]")
    , -- 086087399d35549efbe7ca776ed64b5eb84b62ea11f7dc4585b96c2c26eb7d5a
      (wta1, "#1 = Scan Table [ Players ] Output [ first_name, player_id ] ; #2 = Scan Table [ Rankings ] Output [ ranking, player_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.player_id = #1.player_id ] Output [ #1.ranking, #1.first_name ] ; #4 = Aggregate [ #3 ] GroupBy [ first_name ] Output [ AVG(ranking) AS Avg_ranking, first_name ]")
    , -- df8e2eaea9db6a1d91940430669a0e36d2ac025433b2a3df977d949a20aefcd3
      (voter1, "#1 = Scan Table [ Contestants ] Output [ Contestant_Name, Contestant_Number ] ; #2 = Scan Table [ Votes ] Output [ Contestant_Number ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Contestant_Number = #1.Contestant_Number ] Output [ #1.Contestant_Name, #2.Contestant_Number ] ; #4 = Aggregate [ #3 ] GroupBy [ Contestant_Name ] Output [ Contestant_Name, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ Contestant_Name, Contestant_Number ]")
    , -- a6c5ac5f34c3767df7ecfa7d8e8fa26d6aa081e9ae9a06b31887b21badbbe39f
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ cell_mobile_number, first_name ] ; #2 = Scan Table [ Addresses ] Predicate [ country = 'haiti' ] Output [ country, address_id ] ; #3 = Scan Table [ Students ] Output [ cell_mobile_number, first_name ] ; #4 = Join [ #2, #3 ] Predicate [ #3.cell_mobile_number = #2.cell_mobile_number ] Output [ #3.first_name ]")
    , -- b95a8aefa5bfc0f7d9606648e7afb9ffe2f3381c9f6147255b4f9af1b166c581
      (car1, "#1 = Scan Table [ Cars_Data ] Predicate [ Cylinders = 3 ] Output [ Horsepower, Cylinders ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ MIN(Horsepower) AS Min_Horsepower, MAX(Horsepower) AS Max_Horsepower, MIN(Make) AS Max_Make ]")
    , -- 6fe75339376762c506c994080ce1289b6391db7a92fe1aad3b3a7528e9c66869
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID, LName, Fname ] ; #2 = Scan Table [ Has_Pet ] Predicate [ Pet_Age = 3 ] Output [ StuID, PetId ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.LName ]")
    , -- 77339ce451bff4db5fb89e5639a28995743d1ebb7b76c82c33c1f952c058812d
      (world1, "#1 = Scan Table [ country ] Output [ LifeExpectancy, Code ] ; #2 = Scan Table [ countrylanguage ] Predicate [ IsOfficial = 'english' ] Output [ IsOfficial, CountryCode ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Output [ #2.LifeExpectancy ] ; #4 = Aggregate [ #3 ] Output [ AVG(LifeExpectancy) AS Avg_LifeExpectancy ]")
    , -- 5c3b7fe9487dc73740aedb8cf7af43aa29068d1db0bd2ceb247e499df33f354c
      (pets1, "#1 = Scan Table [ Student ] Output [ Age, Fname, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'dog' ] Distinct [ true ] Output [ PetID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.PetID = #1.StuID ] Distinct [ true ] Output [ #1.Fname, #1.Age ]")
    , -- a1fd3e36763de62d67634d2be00cc30e68e90ed8288550458734eb39e0156e48
      (world1, "#1 = Scan Table [ country ] Predicate [ Language ='spain' ] Output [ Name, Population ] ; #2 = Scan Table [ countrylanguage ] Output [ Language, Percentage ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Language = #1.Name ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 0af2de205b31198e6eca3d7b0b73802ad3764080025941cb66a392eda65a9e13
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Hometown ] ; #2 = Scan Table [ course_arrange ] Predicate [ Teacher_ID = 1 ] Output [ Teacher_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Teacher_ID = #1.Teacher_ID ] Output [ #1.Name ]")
    , -- 512837d29318e63bfaec1474fb6fc4170733428b7d581c634116984533d750eb
      (flight2, "#1 = Scan Table [ airports ] Output [ city ] ; #2 = Scan Table [ flights ] Output [ sourceairport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.sourceairport = #1.city ] Output [ #1.sourceairport ] ; #4 = Aggregate [ #3 ] GroupBy [ sourceairport ] Output [ countstar AS Count_Star, city ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ city, Count_Star ]")
    , -- 018da303b9516c988e9c24f88bd456d97adba3d25ba308c366e8eaa9027a509f
      (car1, "#1 = Scan Table [ Model_List ] Output [ Maker ] ; #2 = Aggregate [ #1 ] GroupBy [ Maker ] Output [ Maker, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star > 3 ] Output [ Maker, Count_Star, FullName ]")
    , -- 411e3a9f339783dbf100ebab4a646a530bbbf7c0315e64cb7fc5982f87dd007e
      (world1, "#1 = Scan Table [ country ] Distinct [ true ] Output [ Code, GovernmentForm ] ; #2 = Scan Table [ countryLanguage ] Output [ CountryCode, Language ] ; #3 = Join [ #1, #2 ] Predicate [ #2.CountryCode = #1.Code ] Distinct [ true ] Output [ #1.Code ] ; #4 = Scan Table [ country ] Output [ Code, GovernmentForm ] ; #5 = Join [ #3, #4 ] Predicate [ #4.GovernmentForm = #3.GovernmentForm ] Distinct [ true ] Output [ #4.Code ]")
    , -- d8eacdf8a3d6a1f89099265b0457ac988f631378f30f90fd38ada84b418b65c0
      (network1, "#1 = Scan Table [ HighSchooler ] Predicate [ Name = 'kyle' ] Output [ Name, ID ] ; #2 = Scan Table [ Friend ] Output [ Student_ID, Friend_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.ID ] Output [ #1.Friend_ID ]")
    , -- 9468ef5d219c1fc8111244fca69f0d535063a6e7bc3bb6219ce500e89256e5d0
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description, treatment_type_code ] ; #2 = Scan Table [ Professionals ] Output [ first_name, professional_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.professional_id = #1.professional_id ] Output [ #1.first_name, #2.treatment_type_code ]")
    , -- b4b4ae10d25e46d7369817827ed4141e9c701e7046aefa27d6f88b73baff0a32
      (studentTranscriptsTracking, "#1 = Scan Table [ Transcripts ] Output [ Transcript_ID, Transcript_Date ] ; #2 = Aggregate [ #1 ] GroupBy [ Transcript_ID ] Output [ Transcript_ID, countstar AS Count_Star ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Transcript_ID, Count_Star, Transcript_Date ]")
    , -- e5944abdcf96b6c445082d7c73904e1a558fcf3e470659bf41d44f19d8842244
      (flight2, "#1 = Scan Table [ airports ] Predicate [ AirportName = 'asy' ] Output [ AirportName, AirportCode ] ; #2 = Scan Table [ flights ] Output [ SourceAirport, Airline ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Airline = #1.Airline ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- 35123af8dc9b9ee62fb89c900e54cbc078224381186a88392dae10e50a7427b8
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ id, name, level_of_membership ] ; #2 = Scan Table [ visit ] Output [ visitor_id, total_spent ] ; #3 = Join [ #1, #2 ] Predicate [ #2.visitor_id = #1.id ] Output [ #1.name, #2.level_of_membership, #1.total_spent ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ total_spent DESC ] Output [ id, name, level_of_membership, total_spent ]")
    , -- ff0a82c65d3f97565126fcc5ac049f4dbc79566d8ab0540c9d7d74e49940a317
      (flight2, "#1 = Scan Table [ airports ] Output [ city ] ; #2 = Scan Table [ flights ] Output [ destairport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.destairport = #1.city ] Output [ #1.destairport ] ; #4 = Aggregate [ #3 ] GroupBy [ city ] Output [ countstar AS Count_Star, city ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ city, Count_Star ]")
    , -- 0c75ccfe4d4b0ec47c5677e32113c1b28aaf51d4a93834a03fe8f1674d1f650d
      (tvshow, "#1 = Scan Table [ TV_Channel ] Output [ Country, ID ] ; #2 = Scan Table [ Cartoon ] Predicate [ Written_by = 'todd casey' ] Output [ Written_by, Channel ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Channel = #1.ID ] Output [ #2.Country ]")
    , -- 4081e5d7bc31db228a3c170e395df647ce46a1fd16e6f1ac5d2606249a8b1d37
      (world1, "#1 = Scan Table [ country ] Distinct [ true ] Output [ IndepYear ] ; #2 = Scan Table [ countrylanguage ] Distinct [ true ] Output [ IsOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.IsOfficial = #1.IndepYear ] Distinct [ true ] Output [ #1.IsOfficial ] ; #4 = Aggregate [ #3 ] Output [ COUNT(DISTINCT IsOfficial) AS Count_Dist_IsOfficial ]")
    , -- e42e09df5ba3b939399271de5fec1b7bcb6fd4f75c9a0ebc3b54f0823831ff38
      (orchestra, "#1 = Scan Table [ conductor ] Distinct [ true ] Output [ Name, Nationality ] ; #2 = Scan Table [ conductor ] Output [ Name, Conductor_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Conductor_ID = #1.Conductor_ID ] Output [ #1.Name ]")
    , -- 3060597756a5391c591fd7056a8c19f57f2d440c443ea414541bc487cacf96a2
      (car1, "#1 = Scan Table [ model_list ] Distinct [ true ] Output [ Model ] ; #2 = Scan Table [ cars_data ] Predicate [ Year > 1980 ] Output [ Year, Id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Id = #1.Id ] Distinct [ true ] Output [ #1.Model ]")
    , -- d01287301b3ab267c9011c0d72455a523c3ac26d89ed5a67dbe3e23e670b9d15
      (pokerPlayer, "#1 = Scan Table [ people ] Output [ Height, People_ID ] ; #2 = Scan Table [ poker_player ] Output [ Money_Rank, People_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.People_ID = #1.People_ID ] Output [ #1.Money_Rank ] ; #4 = Aggregate [ #3 ] GroupBy [ Money_Rank ] Output [ Money_Rank, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Money_Rank, Count_Star ]")
    , -- 55985502904668903fc70726bab09acf27f4a63cb38da420aac63d72edfcc8ac
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_code, breed_name ] ; #2 = Scan Table [ Dogs ] Output [ breed_code, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #1.name, #2.breed_code ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_code ] Output [ breed_code, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ breed_code, Count_Star, name ]")
    , -- 3def30b1ac991f058d5d2835e68edd88f98f0b397ec317e4db5c6ad6cacb91fb
      (dogKennels, "#1 = Scan Table [ Owners ] Predicate [ state = 'virginia' ] Output [ owner_id, first_name, state ] ; #2 = Scan Table [ Dogs ] Output [ owner_id, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.owner_id = #1.owner_id ] Output [ #1.name ]")
    , -- 1a6d7284f609f767a7d2bbc05f7e125020d7b13ecf4c7f2f2de8e63338e8f6fe
      (wta1, "#1 = Scan Table [ Players ] Output [ birth_date, first_name, country_code ] ; #2 = Scan Table [ Matches ] Output [ winner_rank_points ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_rank_points = #1.birth_date ] Output [ #1.first_name, #2.country_code, #1.winner_rank_points ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ birth_date, first_name, country_code, winner_rank_points ]")
    , -- f188a37bade4eaee7d3ab43541a2979675922644d5338853df3bf004604a9d03
      (pets1, "#1 = Scan Table [ Student ] Output [ StuID, Fname ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'dog' OR PetType = 'cat' ] Output [ PetID, StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Fname ]")
    , -- d435cfadf939ca48c701dd06598c00e6e2ef5bc5c0d70ad308404adeb96b8b4e
      (car1, "#1 = Scan Table [ car_makers ] Distinct [ true ] Output [ Maker ] ; #2 = Scan Table [ cars_data ] Predicate [ Year = 1970 ] Output [ Year, Id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Id = #1.Id ] Distinct [ true ] Output [ #1.Maker ]")
    , -- fc7d50c7b91da6ea233b30b07836fcf085ac0fcc1678f271d0c50c3ccb040ab8
      (flight2, "#1 = Scan Table [ airports ] Predicate [ city = 'aberdeen' ] Output [ city, airportCode ] ; #2 = Scan Table [ flights ] Output [ airline, sourceAirport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.sourceAirport = #1.sourceAirport ] Output [ 1 AS One ] ; #4 = Aggregate [ #3 ] Output [ countstar AS Count_Star ]")
    , -- e12cf91c771fa037e6783e5800ff94968bc131b55bf15a098ff231834fa087d0
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Location, Name, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year = 2014 AND Year = 2015 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #2.Name, #1.Location ]")
    , -- e75fca8acdfc313eda670c300d1d3931ee4ab7bc8f3ae5fd929fe9f48b3b1e4e
      (tvshow, "#1 = Scan Table [ TV_Channel ] Predicate [ Series_Name ='sky radio' ] Output [ Series_Name, ID ] ; #2 = Scan Table [ TV_Series ] Output [ Episode, ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.ID = #1.ID ] Output [ #1.Episode ]")
    , -- f9daf85575404c5b449d54a8baa0724475494e972fe99743b94ee039c21ade56
      (car1, "#1 = Scan Table [ cars_data ] Predicate [ Horsepower > 0 ] Output [ Cylinders, Horsepower ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ Cylinders, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 3 ] Output [ Cylinders, Count_Star, Make ]")
    , -- 96ecc85b71033293fa2c714428724abb820b7d37ef95d0c06006e19e54d286a8
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ date_departed, date_arrived ] ; #2 = Scan Table [ Treatments ] Output [ date_of_treatment, dog_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.dog_id = #1.dog_id ] Output [ #2.date_of_treatment, #1.date_arrived ]")
    , -- 6b4498103b5d61a19827ce25667aea3019ce7675511bd6745692252c786e1437
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Name, Capacity, Stadium_ID ] ; #2 = Scan Table [ concert ] Predicate [ Year > 2013 ] Output [ Stadium_ID, Year ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Stadium_ID = #1.Stadium_ID ] Output [ #1.Name, #1.Capacity ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star, Capacity ]")
    , -- 8ddb7c07d3458e79a1b0ab40bec542aa9573847464da7037e2e78d99b362b74d
      (singer, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ song ] Output [ Sales, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Sales ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, SUM(Sales) AS Sum_Sales ]")
    , -- 846e09f26beeee5ebb3abf7a28810861967194e38262b68ea53c0d47e8b2709e
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ role_code, first_name, professional_id ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star, professional_id ] ; #4 = Join [ #1, #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.first_name, #1.role_code, #1.professional_id ] ; #5 = Filter [ #4 ] Predicate [ Count_Star >= 2 ] Output [ first_name, role_code, professional_id ]")
    , -- b231dc84cc5a3164c7790160a3d477c445f337f31d5eb74b92fa01a38341a47c
      (pets1, "#1 = Scan Table [ Student ] Output [ Age, Major, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' ] Distinct [ true ] Output [ StuID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Age, #1.Major, #1.StuID ]")
    , -- ccad946be7d6d75013383b0a2dcc93dfd7c97d868dcafe7309b4e97793ad9e8c
      (flight2, "#1 = Scan Table [ airports ] Output [ city ] ; #2 = Scan Table [ flights ] Output [ destairport ] ; #3 = Join [ #1, #2 ] Predicate [ #2.destairport = #1.city ] Output [ #1.destairport ] ; #4 = Aggregate [ #3 ] GroupBy [ destairport ] Output [ countstar AS Count_Star, city ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ city, Count_Star ]")
    , -- 20aad5ec8be072a2fc801c6afcad66ba64d69ce743b9ab6f3f5237766dfde98f
      (car1, "#1 = Scan Table [ Cars_Data ] Predicate [ Model = 'volvo' ] Output [ Cylinders, Accelerate ] ; #2 = TopSort [ #1 ] Rows [ 1 ] OrderBy [ Accelerate DESC ] Output [ Cylinders, Accelerate ]")
    , -- 2d5aaf3ed4a87a7bfd3f47e80b31b63bc9cb52e1d5ab8aadfb5e21f80c15d4f4
      (dogKennels, "#1 = Scan Table [ Professionals ] Predicate [ State = 'indiana' ] Output [ Professional_ID, Last_Name, Cell_Number, State ] ; #2 = Scan Table [ Treatments ] Output [ Professional_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Professional_ID = #1.Professional_ID ] Output [ #1.Last_Name, #2.Cell_Number ] ; #4 = Aggregate [ #3 ] GroupBy [ Last_Name ] Output [ Last_Name, Cell_Number, countstar AS Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 2 ] Output [ Last_Name, Cell_Number, Count_Star ]")
    , -- 8257705ad9837960caf1153fa275f73bdb5e7c98cbbd9bd8f4d35ef3843d7e21
      (pets1, "#1 = Scan Table [ Student ] Output [ Fname, StuID ] ; #2 = Scan Table [ Has_Pet ] Predicate [ PetType = 'cat' OR PetType = 'dog' ] Output [ PetID, StuID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.StuID = #1.StuID ] Output [ #1.Fname ]")
    , -- b81b808b3e493817e0147dc7b225dd4243187c2fcb355ad2bced48ea5131cc90
      (studentTranscriptsTracking, "#1 = Scan Table [ Degree_Programs ] Output [ department_id ] ; #2 = Aggregate [ #1 ] GroupBy [ department_id ] Output [ countstar AS Count_Star, department_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ department_id, Count_Star, department_name ]")
    , -- 108ae9411be5efb3b8c13a863ccd27c25db8bb6f388e077086e5a293dfcddf27
      (wta1, "#1 = Scan Table [ Players ] Output [ Country_Code, Player_ID, First_Name ] ; #2 = Scan Table [ Rankings ] Output [ Tours, Player_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Player_ID = #1.Player_ID ] Output [ #1.Country_Code, #1.First_Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Country_Code ] Output [ Country_Code, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Country_Code, Count_Star, First_Name ]")
    , -- 0d84fb9681915bfd4ab3a629c27b5ce0af8fc3c65ff7132f2d4cee75b10a0153
      (world1, "#1 = Scan Table [ country ] Predicate [ continent = 'europe' ] Output [ name, continent ] ; #2 = Scan Table [ countrylanguage ] Predicate [ isOfficial = 'english' ] Output [ language, isOfficial ] ; #3 = Join [ #1, #2 ] Predicate [ #2.language = #1.language ] Output [ #2.name ]")
    , -- 702b793672d277ed4c482f92123e570d1e078e384702f2391b7b7bde241442cd
      (concertSinger, "#1 = Scan Table [ stadium ] Output [ Capacity, Location, Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Capacity ] Output [ Capacity, countstar AS Count_Star, Location ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 10000.0 ] Output [ Location, Name, Count_Star, Location, Name, Count_Star, Location, Count_Star, Location, Name, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Location, Count_Star, Count_Star, Location, Count_Star")
    , -- 0958c0b2d43af122aef2fbe2e3aa770ae881b8f5b43febf6c3f9a3b5cf13e025
      (network1, "#1 = Scan Table [ highschooler ] Predicate [ Grade > 5.0 ] Output [ Grade, Name ] ; #2 = Scan Table [ friend ] Output [ Student_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.Student_ID.Import().Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Import_Im")
    , -- 52e8fb837195616b49756027ccc6ca0ce0a8345e015fb0650c436258d6d84414
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ Date_Arrived, Date_Departed ] ; #2 = Scan Table [ Treatments ] Output [ Dog_ID, Date_of_Treatment ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Dog_ID = #1.Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treat")
    , -- 25e6219ead2bf27a2598b9113dc3d3af8c1960671ba08542f364e3d1cf519404
      (studentTranscriptsTracking, "#1 = Scan Table [ Student_Enrolment ] Output [ student_id, degree_program_id ] ; #2 = Aggregate [ #1 ] GroupBy [ degree_program_id ] Output [ countstar AS Count_Star, degree_program_id, student_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ student_id, Count_Star, degree_program_id, Count_Star ]")
    , -- efc3d6b583061fdac5b1192e6644f9c76d5ae824ba2e041fabcadee05b13cb63
      (battleDeath, "#1 = Scan Table [ death ] Output [ Caused_by_ship_id ] ; #2 = Aggregate [ #1 ] GroupBy [ Caused_by_ship_id ] Output [ countstar AS Count_Star, Caused_by_ship_id ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, Count_Star ]")
    , -- 769c4f1348155baa4d093eb503db38362725a9c83d68fe615b476ac3e3c2d803
      (dogKennels, "#1 = Scan Table [ Treatment_Types ] Output [ treatment_type_description, treatment_type_code ] ; #2 = Scan Table [ Treatments ] Output [ cost_of_treatment, treatment_type_code ] ; #3 = Join [ #1, #2 ] Predicate [ #2.treatment_type_code = #1.treatment_type_code ] Output [ #1.treatment_type_description ] ; #4 = Aggregate [ #3 ] GroupBy [ treatment_type_code ] Output [ treatment_type_description, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ treatment_type_description, Count_Star ]")
    , -- 0ab456f2fbc7de30a54a57287745b5f8e8c5e3b734a5144f44b1265e347fc73e
      (flight2, "#1 = Scan Table [ Airlines ] Output [ Country, Abbreviation, UID ] ; #2 = Scan Table [ Flights ] Output [ Airline ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Airline = #1.UID ] Output [ #1.Country, #1.Abbreviation ] ; #4 = Aggregate [ #3 ] GroupBy [ Country ] Output [ Country, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Country, Count_Star, Country ]")
    , -- 664f0c6f067262d02049ca69c3f9f7726e6d086c3325b29eca9eb11398448854
      (network1, "#1 = Scan Table [ Highschooler ] Predicate [ Grade > 5 ] Output [ Grade, Name ] ; #2 = Scan Table [ Friend ] Output [ Student_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Student_ID = #1.Student_ID.ID_MINNISTRATES_INDEX_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_SUM_S")
    , -- c61132133c0884369b3656e64742fefba5bafb269a5d2e9604eed2bd4d7792f7
      (studentTranscriptsTracking, "#1 = Scan Table [ Addresses ] Output [ address_id, line_1, line_2 ] ; #2 = Scan Table [ Students ] Output [ current_address_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.current_address_id = #1.address_id ] Output [ #1.address_id ] ; #4 = Aggregate [ #3 ] GroupBy [ address_id ] Output [ countstar AS Count_Star, address_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ address_id, Count_Star, address_id ]")
    , -- 08dc2bd47d43756549ebaa3fc4b93ef053b8ccb78cf36090fb8b63aa8b29c96f
      (car1, "#1 = Scan Table [ Model_List ] Output [ Model, ModelId ] ; #2 = Scan Table [ Cars_Data ] Output [ Weight ] ; #3 = Aggregate [ #2 ] Output [ AVG(Weight) AS Avg_Weight ] ; #4 = Scan Table [ Car_Names ] Output [ Model, MakeId ] ; #5 = Join [ #1, #4 ] Predicate [ #4.MakeId = #1.ModelId ] Output [ #1.Model ] ; #6 = Aggregate [ #5 ] Output [ AVG(Weight) AS Avg_Weight ]")
    , -- 1d303a4c9be0e889f0579981273206eb3953935055b14be901616cc6fc92ba5f
      (battleDeath, "#1 = Scan Table [ ship ] Output [ id, name, id ] ; #2 = Scan Table [ death ] Output [ injured, id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.id = #1.id ] Output [ #2.injured, #1.id ] ; #4 = Aggregate [ #3 ] GroupBy [ id ] Output [ id, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, id, id ]")
    , -- 6632e3ca9157ea891f945858d65d51a7c21b4b3beac8b3d957f92610d775da20
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline, uid ] ; #2 = Scan Table [ Airports ] Predicate [ airportName = 'apg' ] Output [ airportName, airportCode ] ; #3 = Scan Table [ Flights ] Predicate [ sourceAirport = 'cvo' ] Output [ airline, sourceAirport ] ; #4 = Join [ #2, #3 ] Predicate [ #3.sourceAirport = #2.sourceArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialArporMemorialAr")
    , -- d59fc2b348e4322ab55b3c0602d3c7281523c59e6cdc25eeba00a219ed306068
      (car1, "#1 = Scan Table [ Cars_Data ] Predicate [ Cylinders = 8 ] Distinct [ true ] Output [ Year, Cylinders ] ; #2 = Aggregate [ #1 ] Output [ MAX(MPG) AS Max_MPG ]")
    , -- 68a7c7be81a8bd9b48f9750cfc34bfa65110ac9eacce30055ad944d8300f8166
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Hometown ] ; #2 = Scan Table [ course_arrange ] Predicate [ Teacher_ID = 'little lever urban district' ] Output [ Teacher_ID, Teacher_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Teacher_ID IS NULL OR #1.Hometown = #2.Teacher_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star ]")
    , -- 6ae399e06f0727c2e17b66033a479df7c995fb6126ac67372fe9c15c6a115c23
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_Products ] ; #2 = Aggregate [ #1 ] GroupBy [ Number_Products ] Output [ countstar AS Count_Star, Number_Products ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, Count_Star ]")
    , -- bc82973d8a4f671f6ef6a3b4e3a994c811d7f72d0410a6437d4195f8c5b8a0ce
      (concertSinger, "#1 = Scan Table [ singer ] Output [ Age, Song_Name ] ; #2 = Aggregate [ #1 ] GroupBy [ Age ] Output [ Age, AVG(Age) AS Avg_Age ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Avg_Age DESC ] Output [ Song_Name, Avg_Age, Affect_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_")
    , -- 9e1d5ef6745da75269f01f2394f4be8f88a36f0f2f1760c4d6dd46ebc23dec81
      (employeeHireEvaluation, "#1 = Scan Table [ shop ] Output [ Number_Products ] ; #2 = Aggregate [ #1 ] GroupBy [ Number_Products ] Output [ countstar AS Count_Star, Number_Products ] ; #3 = TopSort [ #2 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, Count_Star ]")
    , -- 4e2a3009bf1eeef36db8e5fde67079e87dc569572f0683cc2aa31d95e6f5b471
      (car1, "#1 = Scan Table [ Cars_Data ] Distinct [ true ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ Cylinders, MAX(Accelerate) AS Max_Accelerate ]")
    , -- c3998b7c1feeb87bae4cca7d360728a072f24c52445c2355240738d9e27063b6
      (flight2, "#1 = Scan Table [ Airlines ] Output [ airline, uid ] ; #2 = Scan Table [ Airports ] Predicate [ airportName = 'ahd' ] Output [ airportName, airportCode ] ; #3 = Scan Table [ Flights ] Output [ airline, destairport ] ; #4 = Join [ #2, #3 ] Predicate [ #3.destairport = #2.ahd_aaa_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_ahd_a")
    , -- 24a2b7acc32937966d07d1265d8dc136e4be76b7cfe7bf73b2ac90793d0c310b
      (studentTranscriptsTracking, "#1 = Scan Table [ Students ] Output [ student_id, first_name, middle_name, last_name, student_id ] ; #2 = Scan Table [ Student_Enrolment ] Output [ student_id ] ; #3 = Join [ #1, #2 ] Predicate [ #2.student_id = #1.student_id ] Output [ #1.student_id ] ; #4 = Aggregate [ #3 ] GroupBy [ student_id ] Output [ countstar AS Count_Star, student_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Count_Star, student_id, Count_Star ]")
    , -- 17831c8c47493e469a43da0b31f0b95d91ce356b726429b57d3929c4aa04974e
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_name, breed_code ] ; #2 = Scan Table [ Dogs ] Output [ breed_code, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #2.name, #1.breed_code ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_code ] Output [ breed_code, countstar AS Count_Star, name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name, Count_Star, Count_Star ]")
    , -- 0af2de205b31198e6eca3d7b0b73802ad3764080025941cb66a392eda65a9e13
      (courseTeach, "#1 = Scan Table [ teacher ] Output [ Name, Hometown ] ; #2 = Scan Table [ course_arrange ] Predicate [ Teacher_ID = 'little lever urban district' ] Output [ Teacher_ID, Teacher_ID ] ; #3 = Except [ #1, #2 ] Predicate [ #2.Teacher_ID IS NULL OR #1.Hometown IS NULL ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ Name, Count_Star ]")
    , -- 35123af8dc9b9ee62fb89c900e54cbc078224381186a88392dae10e50a7427b8
      (museumVisit, "#1 = Scan Table [ visitor ] Output [ id, name, level_of_membership ] ; #2 = Scan Table [ visit ] Output [ visitor_id, total_spent ] ; #3 = Join [ #1, #2 ] Predicate [ #2.visitor_id = #1.id ] Output [ #1.level_of_membership, #1.id, #2.total_spent ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ total_spent DESC ] Output [ level_of_membership, level_of_membership, id ]")
    , -- 6cc665c83afd60499ff4e24745c41e5fb4724d43e9409a2e72f07d8b013a4814
      (world1, "#1 = Scan Table [ country ] Predicate [ continent = 'asia' ] Output [ continent, surfaceArea ] ; #2 = Scan Table [ country ] Predicate [ continent = 'europe' ] Output [ continent, surfaceArea ] ; #3 = Join [ #1, #2 ] Predicate [ #2.continent = #1.continent ] Output [ #2.surfaceArea ] ; #4 = Aggregate [ #3 ] GroupBy [ continent ] Output [ surfaceArea, countstar AS Count_Star ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ surfaceArea, Count_Star ]")
    , -- 55985502904668903fc70726bab09acf27f4a63cb38da420aac63d72edfcc8ac
      (dogKennels, "#1 = Scan Table [ Breeds ] Output [ breed_code, breed_name ] ; #2 = Scan Table [ Dogs ] Output [ breed_code, name ] ; #3 = Join [ #1, #2 ] Predicate [ #2.breed_code = #1.breed_code ] Output [ #2.name, #1.breed_code ] ; #4 = Aggregate [ #3 ] GroupBy [ breed_code ] Output [ breed_code, countstar AS Count_Star, name ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Star DESC ] Output [ name, Count_Star, name ]")
    , -- 1a6d7284f609f767a7d2bbc05f7e125020d7b13ecf4c7f2f2de8e63338e8f6fe
      (wta1, "#1 = Scan Table [ Players ] Output [ birth_date, first_name, country_code, player_id ] ; #2 = Scan Table [ Matches ] Output [ winner_rank_points ] ; #3 = Join [ #1, #2 ] Predicate [ #2.winner_rank_points = #1.birth_date ] Output [ #1.first_name, #1.country_code, #2.winner_rank_points ] ; #4 = TopSort [ #3 ] Rows [ 1 ] OrderBy [ winner_rank_points DESC ] Output [ first_name, country_code, winner_rank_points, country_code ]")
    , -- f9daf85575404c5b449d54a8baa0724475494e972fe99743b94ee039c21ade56
      (car1, "#1 = Scan Table [ Cars_Data ] Predicate [ Horsepower > 0 ] Distinct [ true ] Output [ Cylinders ] ; #2 = Aggregate [ #1 ] GroupBy [ Cylinders ] Output [ Cylinders, countstar AS Count_Star ] ; #3 = Filter [ #2 ] Predicate [ Count_Star < 3 ] Output [ Cylinders, Count_Star ] ; #4 = Filter [ #3 ] Predicate [ Count_Star > 0 ] Output [ Cylinders, Count_Star ] ; #5 = Filter [ #4 ] Predicate [ Count_Star > 0 ] Output [ Cylinders, Count_Star ] ; #6 = Join [ #4, #5, #6")
    , -- 96ecc85b71033293fa2c714428724abb820b7d37ef95d0c06006e19e54d286a8
      (dogKennels, "#1 = Scan Table [ Dogs ] Output [ Date_Arrived, Date_Departed ] ; #2 = Scan Table [ Treatments ] Output [ Dog_ID, Date_of_Treatment ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Dog_ID = #1.Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treatment_Id/Date_of_Treat")
    , -- 8ddb7c07d3458e79a1b0ab40bec542aa9573847464da7037e2e78d99b362b74d
      (singer, "#1 = Scan Table [ singer ] Output [ Name, Singer_ID ] ; #2 = Scan Table [ song ] Output [ Sales, Singer_ID ] ; #3 = Join [ #1, #2 ] Predicate [ #2.Singer_ID = #1.Singer_ID ] Output [ #1.Name ] ; #4 = Aggregate [ #3 ] GroupBy [ Name ] Output [ Name, SUM(Sales) AS Sum_Sales ]")
    , -- 846e09f26beeee5ebb3abf7a28810861967194e38262b68ea53c0d47e8b2709e
      (dogKennels, "#1 = Scan Table [ Professionals ] Output [ professional_id, role_code, first_name ] ; #2 = Scan Table [ Treatments ] Output [ professional_id ] ; #3 = Aggregate [ #2 ] GroupBy [ professional_id ] Output [ countstar AS Count_Star, professional_id ] ; #4 = Join [ #1, #3 ] Predicate [ #3.professional_id = #1.professional_id ] Output [ #1.first_name, #1.role_code, #1.professional_id ] ; #5 = TopSort [ #4 ] Rows [ 1 ] OrderBy [ Count_Count_Dist_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sort_Sor")
    ]
