BEGIN TRANSACTION;
GO
USE spider;
GO
CREATE TABLE [baseball_1].player (
    player_id VARCHAR(255) PRIMARY KEY,
    birth_year INT,
    birth_month INT,
    birth_day INT,
    birth_country NVARCHAR(MAX),
    birth_state NVARCHAR(MAX),
    birth_city NVARCHAR(MAX),
    death_year INT,
    death_month INT,
    death_day INT,
    death_country NVARCHAR(MAX),
    death_state NVARCHAR(MAX),
    death_city NVARCHAR(MAX),
    name_first NVARCHAR(MAX),
    name_last NVARCHAR(MAX),
    name_given NVARCHAR(MAX),
    weight INT,
    height INT,
    bats NVARCHAR(MAX),
    throws NVARCHAR(MAX),
    debut NVARCHAR(MAX),
    final_game NVARCHAR(MAX),
    retro_id NVARCHAR(MAX),
    bbref_id NVARCHAR(MAX));
GO
CREATE TABLE [baseball_1].team (
    year INTEGER,
    league_id NVARCHAR(MAX),
    team_id VARCHAR(255) PRIMARY KEY,
    franchise_id NVARCHAR(MAX),
    div_id NVARCHAR(MAX),
    rank INTEGER,
    g INTEGER,
    ghome INT,
    w INTEGER,
    l INTEGER,
    div_win NVARCHAR(MAX),
    wc_win NVARCHAR(MAX),
    lg_win NVARCHAR(MAX),
    ws_win NVARCHAR(MAX),
    r INTEGER,
    ab INTEGER,
    h INTEGER,
    [double] INTEGER,
    triple INTEGER,
    hr INTEGER,
    bb INTEGER,
    so INT,
    sb INT,
    cs INT,
    hbp INT,
    sf INT,
    ra INTEGER,
    er INTEGER,
    era NUMERIC,
    cg INTEGER,
    sho INTEGER,
    sv INTEGER,
    ipouts INTEGER,
    ha INTEGER,
    hra INTEGER,
    bba INTEGER,
    soa INTEGER,
    e INTEGER,
    dp INT,
    fp NUMERIC,
    name VARCHAR(40),
    park NVARCHAR(MAX),
    attendance INT,
    bpf INTEGER,
    ppf INTEGER,
    team_id_br CHAR(3),
    team_id_lahman45 NVARCHAR(MAX),
    team_id_retro NVARCHAR(MAX));
GO
CREATE TABLE [baseball_1].all_star (
    player_id VARCHAR(255),
    year INTEGER,
    game_num INTEGER,
    game_id NVARCHAR(MAX),
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    gp INT,
    starting_pos INT,
    foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].appearances (
    year INTEGER,
    team_id VARCHAR(255),
    league_id NVARCHAR(MAX),
    player_id VARCHAR(255),
    g_all INT,
    gs INT,
    g_batting INTEGER,
    g_defense INT,
    g_p INTEGER,
    g_c INTEGER,
    g_1b INTEGER,
    g_2b INTEGER,
    g_3b INTEGER,
    g_ss INTEGER,
    g_lf INTEGER,
    g_cf INTEGER,
    g_rf INTEGER,
    g_of INTEGER,
    g_dh INT,
    g_ph INT,
    g_pr INT,
    foreign key (team_id) references [baseball_1].team(team_id),
    foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].manager_award (
    player_id VARCHAR(255),
    award_id NVARCHAR(MAX),
    year INTEGER,
    league_id NVARCHAR(MAX),
    tie NVARCHAR(MAX),
    notes INT,
    foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].player_award ( 
	player_id VARCHAR(255), 
	award_id NVARCHAR(MAX), 
	year INTEGER, 
	league_id NVARCHAR(MAX),
    	tie NVARCHAR(MAX),
    	notes NVARCHAR(MAX),
	foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].manager_award_vote (
    award_id NVARCHAR(MAX),
    year INTEGER,
    league_id NVARCHAR(MAX),
    player_id NVARCHAR(MAX),
    points_won INTEGER,
    points_max INTEGER,
    votes_first INTEGER);
GO
CREATE TABLE [baseball_1].player_award_vote (
    award_id NVARCHAR(MAX),
    year INTEGER,
    league_id NVARCHAR(MAX),
    player_id VARCHAR(255),
    points_won NUMERIC,
    points_max INTEGER,
    votes_first VARCHAR(4),
   foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].batting (
    player_id VARCHAR(255),
    year INTEGER,
    stint INTEGER,
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    g INTEGER,
    ab INT,
    r INT,
    h INT,
    [double] INT,
    triple INT,
    hr INT,
    rbi INT,
    sb INT,
    cs INT,
    bb INT,
    so INT,
    ibb INT,
    hbp INT,
    sh INT,
    sf INT,
    g_idp INT,
foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].batting_postseason (
    year INTEGER,
    round NVARCHAR(MAX),
    player_id VARCHAR(255),
    team_id VARCHAR(255),
    league_id NVARCHAR(MAX),
    g INTEGER,
    ab INTEGER,
    r INTEGER,
    h INTEGER,
    [double] INTEGER,
    triple INTEGER,
    hr INTEGER,
    rbi INT,
    sb INT,
    cs INT,
    bb INTEGER,
    so INTEGER,
    ibb INT,
    hbp INT,
    sh INT,
    sf INT,
    g_idp INT,
	foreign key (player_id) references [baseball_1].player(player_id),
	foreign key (team_id) references [baseball_1].team(team_id)
);
GO
CREATE TABLE [baseball_1].college (
    college_id VARCHAR(255) PRIMARY KEY,
    name_full NVARCHAR(MAX),
    city NVARCHAR(MAX),
    state NVARCHAR(MAX),
    country NVARCHAR(MAX));
GO
CREATE TABLE [baseball_1].player_college ( player_id VARCHAR(255),
    college_id VARCHAR(255),
    year INTEGER,
	foreign key (player_id) references [baseball_1].player(player_id),
	foreign key (college_id) references [baseball_1].college(college_id)
);
GO
CREATE TABLE [baseball_1].fielding (
    player_id VARCHAR(255),
    year INTEGER,
    stint INTEGER,
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    pos NVARCHAR(MAX),
    g INTEGER,
    gs INT,
    inn_outs INT,
    po INT,
    a INT,
    e INT,
    dp INT,
    pb INT,
    wp INT,
    sb INT,
    cs INT,
    zr INT,
	foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].fielding_outfield (
    player_id VARCHAR(255),
    year INTEGER,
    stint INTEGER,
    glf INT,
    gcf INT,
    grf INT,
	foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].fielding_postseason (
    player_id VARCHAR(255),
    year INTEGER,
    team_id VARCHAR(255),
    league_id NVARCHAR(MAX),
    round NVARCHAR(MAX),
    pos NVARCHAR(MAX),
    g INTEGER,
    gs INT,
    inn_outs INT,
    po INTEGER,
    a INTEGER,
    e INTEGER,
    dp INTEGER,
    tp INTEGER,
    pb INT,
    sb INT,
    cs INT,
	foreign key (player_id) references [baseball_1].player(player_id),
	foreign key (team_id) references [baseball_1].team(team_id)
);
GO
CREATE TABLE [baseball_1].hall_of_fame (
    player_id VARCHAR(255),
    yearid INTEGER,
    votedby NVARCHAR(MAX),
    ballots INT,
    needed INT,
    votes INT,
    inducted NVARCHAR(MAX),
    category NVARCHAR(MAX),
    needed_note NVARCHAR(MAX),
	foreign key (player_id) references [baseball_1].player(player_id)
);
GO
CREATE TABLE [baseball_1].park (
    park_id VARCHAR(255) PRIMARY KEY,
    park_name NVARCHAR(MAX),
    park_alias NVARCHAR(MAX),
    city NVARCHAR(MAX),
    state NVARCHAR(MAX),
    country NVARCHAR(MAX));
GO
CREATE TABLE [baseball_1].home_game (
    year INTEGER,
    league_id NVARCHAR(MAX),
    team_id VARCHAR(255),
    park_id VARCHAR(255),
    span_first NVARCHAR(MAX),
    span_last NVARCHAR(MAX),
    games INTEGER,
    openings INTEGER,
    attendance INTEGER,
	foreign key (team_id) references [baseball_1].team(team_id),
	foreign key (park_id) references [baseball_1].park(park_id)
);
GO
CREATE TABLE [baseball_1].manager (
    player_id VARCHAR(255),
    year INTEGER,
    team_id VARCHAR(255),
    league_id NVARCHAR(MAX),
    inseason INTEGER,
    g INTEGER,
    w INTEGER,
    l INTEGER,
    rank INT,
    plyr_mgr NVARCHAR(MAX),
	foreign key (team_id) references [baseball_1].team(team_id)
);
GO
CREATE TABLE [baseball_1].manager_half (
    player_id VARCHAR(255),
    year INTEGER,
    team_id VARCHAR(255),
    league_id NVARCHAR(MAX),
    inseason INTEGER,
    half INTEGER,
    g INTEGER,
    w INTEGER,
    l INTEGER,
    rank INTEGER,
	foreign key (team_id) references [baseball_1].team(team_id)
);
GO
CREATE TABLE [baseball_1].pitching (
    player_id NVARCHAR(MAX),
    year INTEGER,
    stint INTEGER,
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    w INTEGER,
    l INTEGER,
    g INTEGER,
    gs INTEGER,
    cg INTEGER,
    sho INTEGER,
    sv INTEGER,
    ipouts INT,
    h INTEGER,
    er INTEGER,
    hr INTEGER,
    bb INTEGER,
    so INTEGER,
    baopp INT,
    era DECIMAL,
    ibb INT,
    wp INT,
    hbp INT,
    bk INTEGER,
    bfp INT,
    gf INT,
    r INTEGER,
    sh INT,
    sf INT,
    g_idp INT);
GO
CREATE TABLE [baseball_1].pitching_postseason (
    player_id NVARCHAR(MAX),
    year INTEGER,
    round NVARCHAR(MAX),
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    w INTEGER,
    l INTEGER,
    g INTEGER,
    gs INTEGER,
    cg INTEGER,
    sho INTEGER,
    sv INTEGER,
    ipouts INTEGER,
    h INTEGER,
    er INTEGER,
    hr INTEGER,
    bb INTEGER,
    so INTEGER,
    baopp VARCHAR(5),
    era DECIMAL,
    ibb INT,
    wp INT,
    hbp INT,
    bk INT,
    bfp INT,
    gf INTEGER,
    r INTEGER,
    sh INT,
    sf INT,
    g_idp INT);
GO
CREATE TABLE [baseball_1].salary (
    year INTEGER,
    team_id NVARCHAR(MAX),
    league_id NVARCHAR(MAX),
    player_id NVARCHAR(MAX),
    salary INTEGER);
GO
CREATE TABLE [baseball_1].postseason (
    year INTEGER,
    round NVARCHAR(MAX),
    team_id_winner CHAR(3),
    league_id_winner NVARCHAR(MAX),
    team_id_loser CHAR(3),
    league_id_loser NVARCHAR(MAX),
    wins INTEGER,
    losses INTEGER,
    ties INTEGER);
GO
CREATE TABLE [baseball_1].team_franchise (
    franchise_id NVARCHAR(MAX),
    franchise_name NVARCHAR(MAX),
    active NVARCHAR(MAX),
    na_assoc NVARCHAR(MAX));
GO
CREATE TABLE [baseball_1].team_half (
    year INTEGER,
    league_id NVARCHAR(MAX),
    team_id NVARCHAR(MAX),
    half INTEGER,
    div_id NVARCHAR(MAX),
    div_win NVARCHAR(MAX),
    rank INTEGER,
    g INTEGER,
    w INTEGER,
    l INTEGER);
GO
COMMIT;
