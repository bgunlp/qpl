BEGIN TRANSACTION;
GO
USE spider;
GO
CREATE TABLE [wta_1].players(
    [player_id] INT PRIMARY KEY,
    [first_name] VARCHAR(40),
    [last_name] TEXT,
    [hand] CHAR(1),
    [birth_date] INTEGER,
    [country_code] VARCHAR(3)
);
GO
CREATE TABLE [wta_1].matches(
  [best_of] INT,
  [draw_size] INT,
  [loser_age] FLOAT,
  [loser_entry] TEXT,
  [loser_hand] TEXT,
  [loser_ht] INT,
  [loser_id] INT,
  [loser_ioc] TEXT,
  [loser_name] VARCHAR(30),
  [loser_rank] INT,
  [loser_rank_points] INT,
  [loser_seed] INT,
  [match_num] INT,
  [minutes] INT,
  [round] TEXT,
  [score] TEXT,
  [surface] TEXT,
  [tourney_date] INTEGER,
  [tourney_id] TEXT,
  [tourney_level] TEXT,
  [tourney_name] VARCHAR(20),
  [winner_age] FLOAT,
  [winner_entry] TEXT,
  [winner_hand] CHAR(1),
  [winner_ht] INT,
  [winner_id] INT,
  [winner_ioc] TEXT,
  [winner_name] VARCHAR(30),
  [winner_rank] INT,
  [winner_rank_points] INT,
  [winner_seed] INT,
  [year] INT,
  FOREIGN KEY(loser_id) REFERENCES [wta_1].players(player_id),
  FOREIGN KEY(winner_id) REFERENCES [wta_1].players(player_id)
);
GO
CREATE TABLE [wta_1].qualifying_matches(
  [best_of] INT,
  [draw_size] INT,
  [l_1stIn] TEXT,
  [l_1stWon] TEXT,
  [l_2ndWon] TEXT,
  [l_SvGms] TEXT,
  [l_ace] TEXT,
  [l_bpFaced] TEXT,
  [l_bpSaved] TEXT,
  [l_df] TEXT,
  [l_svpt] TEXT,
  [loser_age] FLOAT,
  [loser_entry] TEXT,
  [loser_hand] TEXT,
  [loser_ht] INT,
  [loser_id] INT,
  [loser_ioc] TEXT,
  [loser_name] TEXT,
  [loser_rank] INT,
  [loser_rank_points] INT,
  [loser_seed] INT,
  [match_num] INT,
  [minutes] INT,
  [round] TEXT,
  [score] TEXT,
  [surface] TEXT,
  [tourney_date] DATE,
  [tourney_id] TEXT,
  [tourney_level] TEXT,
  [tourney_name] TEXT,
  [w_1stIn] TEXT,
  [w_1stWon] TEXT,
  [w_2ndWon] TEXT,
  [w_SvGms] TEXT,
  [w_ace] TEXT,
  [w_bpFaced] TEXT,
  [w_bpSaved] TEXT,
  [w_df] TEXT,
  [w_svpt] TEXT,
  [winner_age] FLOAT,
  [winner_entry] TEXT,
  [winner_hand] CHAR(1),
  [winner_ht] INT,
  [winner_id] INT,
  [winner_ioc] TEXT,
  [winner_name] VARCHAR(30),
  [winner_rank] INT,
  [winner_rank_points] INT,
  [winner_seed] INT,
  [year] INT,
  FOREIGN KEY(loser_id) REFERENCES [wta_1].players(player_id),
  FOREIGN KEY(winner_id) REFERENCES [wta_1].players(player_id)
);
GO
CREATE TABLE [wta_1].rankings(
  [ranking_date] INT,
  [ranking] INT,
  [player_id] INT,
  [ranking_points] INT,
  [tours] INT,
  FOREIGN KEY(player_id) REFERENCES [wta_1].players(player_id)
);
COMMIT