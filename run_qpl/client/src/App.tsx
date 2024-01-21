import React, { useState } from "react";

type QplResponse =
  | { error: string }
  | { cte: string; result: Record<string, string>[] };

const App = () => {
  const dbIds = [
    "academic",
    "activity_1",
    "aircraft",
    "allergy_1",
    "apartment_rentals",
    "architecture",
    "assets_maintenance",
    "baseball_1",
    "battle_death",
    "behavior_monitoring",
    "bike_1",
    "body_builder",
    "book_2",
    "browser_web",
    "candidate_poll",
    "car_1",
    "car_11",
    "chinook_1",
    "cinema",
    "city_record",
    "climbing",
    "club_1",
    "coffee_shop",
    "college_1",
    "college_2",
    "college_3",
    "company_1",
    "company_employee",
    "company_office",
    "concert_singer",
    "county_public_safety",
    "course_teach",
    "cre_Doc_Control_Systems",
    "cre_Doc_Template_Mgt",
    "cre_Doc_Tracking_DB",
    "cre_Docs_and_Epenses",
    "cre_Drama_Workshop_Groups",
    "cre_Theme_park",
    "csu_1",
    "culture_company",
    "customer_complaints",
    "customer_deliveries",
    "customers_and_addresses",
    "customers_and_invoices",
    "customers_and_products_contacts",
    "customers_campaigns_ecommerce",
    "customers_card_transactions",
    "debate",
    "decoration_competition",
    "department_management",
    "department_store",
    "device",
    "document_management",
    "dog_kennels",
    "dorm_1",
    "driving_school",
    "e_government",
    "e_learning",
    "election",
    "election_representative",
    "employee_hire_evaluation",
    "entertainment_awards",
    "entrepreneur",
    "epinions_1",
    "farm",
    "film_rank",
    "flight_1",
    "flight_2",
    "flight_4",
    "flight_company",
    "formula_1",
    "game_1",
    "game_injury",
    "gas_company",
    "geo",
    "gymnast",
    "hospital_1",
    "hr_1",
    "icfp_1",
    "imdb",
    "inn_1",
    "insurance_and_eClaims",
    "insurance_fnol",
    "insurance_policies",
    "journal_committee",
    "loan_1",
    "local_govt_and_lot",
    "local_govt_in_alabama",
    "local_govt_mdm",
    "machine_repair",
    "manufactory_1",
    "manufacturer",
    "match_season",
    "medicine_enzyme_interaction",
    "mountain_photos",
    "movie_1",
    "museum_visit",
    "music_1",
    "music_2",
    "music_4",
    "musical",
    "network_1",
    "network_2",
    "news_report",
    "orchestra",
    "party_host",
    "party_people",
    "performance_attendance",
    "perpetrator",
    "pets_1",
    "phone_1",
    "phone_market",
    "pilot_record",
    "poker_player",
    "product_catalog",
    "products_for_hire",
    "products_gen_characteristics",
    "program_share",
    "protein_institute",
    "race_track",
    "railway",
    "real_estate_properties",
    "restaurant_1",
    "restaurants",
    "riding_club",
    "roller_coaster",
    "sakila_1",
    "scholar",
    "school_bus",
    "school_finance",
    "school_player",
    "scientist_1",
    "ship_1",
    "ship_mission",
    "shop_membership",
    "singer",
    "small_bank_1",
    "soccer_1",
    "soccer_2",
    "solvency_ii",
    "sports_competition",
    "station_weather",
    "store_1",
    "store_product",
    "storm_record",
    "student_1",
    "student_assessment",
    "student_transcripts_tracking",
    "swimming",
    "theme_gallery",
    "tracking_grants_for_research",
    "tracking_orders",
    "tracking_share_transactions",
    "tracking_software_problems",
    "train_station",
    "tvshow",
    "twitter_1",
    "university_basketball",
    "voter_1",
    "voter_2",
    "wedding",
    "wine_1",
    "workshop_paper",
    "world_1",
    "world_11",
    "wrestler",
    "wta_1",
    "wta_11",
    "yelp",
  ];

  const [dbId, setDbId] = useState(dbIds[0]);
  const [qpl, setQpl] = useState("");
  const [err, setErr] = useState("");
  const [cte, setCte] = useState("");
  const [data, setData] = useState<Record<string, string>[]>([]);
  const [isValid, setIsValid] = useState<"none" | "valid" | "invalid">("none");

  const onSubmitHandler: React.FormEventHandler<HTMLButtonElement> = async (
    event,
  ) => {
    event.preventDefault();
    const response = await fetch(`http://localhost:8000/${dbId}/qpl`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(qpl.split("\n")),
    });
    const json: QplResponse = await response.json();
    if ("error" in json) {
      setCte("");
      setData([]);
      setErr(json.error);
    } else {
      setErr("");
      setCte(json.cte);
      setData(json.result);
    }
  };

  const onValidateHandler: React.FormEventHandler<HTMLButtonElement> = async (
    event,
  ) => {
    event.preventDefault();
    const response = await fetch(`http://localhost:8000/validate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        qpl: `${dbId} | ${qpl.split("\n").join(" ; ")}`,
      }),
    });
    const result = await response.json();
    setIsValid(result ? "valid" : "invalid");
    setData([]);
    setErr("");
    setCte("");
  };

  return (
    <>
      <form>
        <label>
          Schema Name (<code>db_id</code>)
        </label>
        <br />
        <select value={dbId} onChange={(event) => setDbId(event.target.value)}>
          {dbIds.map((i) => (
            <option value={i}>{i}</option>
          ))}
        </select>
        <br />
        <br />
        <br />
        <label>QPL</label>
        <br />
        <textarea
          rows={13}
          cols={120}
          onChange={(event) => setQpl(event.target.value)}
        />
        <br />
        <button type="button" onClick={onSubmitHandler}>
          Submit
        </button>
        <button type="button" onClick={onValidateHandler}>
          Validate
        </button>
      </form>

      {isValid === "none" ? null : isValid === "valid" ? (
        <pre style={{ color: "green" }}>{isValid.toUpperCase()}</pre>
      ) : (
        <pre style={{ color: "red" }}>{isValid.toUpperCase()}</pre>
      )}

      {err.length === 0 ? null : <pre style={{ color: "red" }}>{err}</pre>}

      {cte.length === 0 ? null : <pre>{cte}</pre>}

      {data.length === 0 ? null : (
        <table>
          <thead style={{ borderBottom: "2px solid" }}>
            {Object.keys(data[0]).map((n) => (
              <th>{n}</th>
            ))}
          </thead>
          <tbody>
            {data.map((row) => (
              <tr>
                {Object.values(row).map((v) => (
                  <td>{v}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  );
};

export default App;
