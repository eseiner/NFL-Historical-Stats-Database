-- Drop tables
DROP TABLE IF EXISTS receiving;
DROP TABLE IF EXISTS rushing;
DROP TABLE IF EXISTS passing;
DROP TABLE IF EXISTS defense;
DROP TABLE IF EXISTS player_info;
DROP TABLE IF EXISTS player;

-- NFL Database Table Definitions

-- Basic information for all players
CREATE TABLE player (
    -- Unique ID for the player
    player_id     INT,
    -- Position of the player
    position      CHAR(3),
    -- If the player is retired or still playing
    status        CHAR(7),
    -- How many years the player has played
    experience    INT,
    -- Player_id is the only primary key
    PRIMARY KEY (player_id),
    CHECK (status in ('Active', 'Retired'))
);

-- Background information for all players
CREATE TABLE player_info (
    -- Unique ID for the player
    player_id     INT,
    -- First and last name of the player
    name          CHAR(30),
    -- The place the player was born
    birth_place   CHAR(50),
    -- The player's birthday
    birthday      DATE,
    -- The college the player went to
    college       CHAR(25),
    -- The height of the player in inches
    height_in     INTEGER,
    -- The weight of the player in pounds
    weight_lbs    INTEGER,
    -- Player_id is the only primary key
    PRIMARY KEY (player_id),
    -- player_info references player_id from the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
                            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Defensive career statistics for players
CREATE TABLE defense (
    -- Unique ID for the player
    player_id INTEGER,
    -- Year the stats were taken
    year YEAR,
    -- Current team of the player
    curr_team             VARCHAR(30),
    -- Number of games played in a year
    games_played          INT,
    -- Number of solo tackles
    solo_tackles          INTEGER,
    -- Number of assisted tackles
    assist_tackles        INTEGER,
    -- Total number of sacks
    sacks                 FLOAT,
    -- Total number of safeties
    safeties              INTEGER,
    -- Number of passes defended
    pass_defended         INTEGER,
    -- Total number of interceptions caught
    interceptions         INTEGER,
    -- Total number of interceptions run to a touchdown
    interception_to_td    INTEGER,
    -- Number of yards for all interceptions
    interception_yrds     INTEGER,
    -- Player_id, year, and curr_team are the primary keys
    PRIMARY KEY (player_id, year, curr_team),
    -- player_info references player_id from the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
                            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Passing career statistics for players
CREATE TABLE passing (
    -- Unique ID for the player
    player_id            INTEGER,
    -- Year the stats were taken
    year                 YEAR,
    -- Current team of the player
    curr_team            VARCHAR(30),
    -- Number of games played in a year
    games_played         INT,
    -- Number of passes attempted
    pass_attempt         INTEGER,
    -- Number of completed passes
    pass_complete        INTEGER,
    -- Number of passes to a touchdown
    td_passes            INTEGER,
    -- Number of interceptions
    interceptions        INTEGER,
    -- Passes for more than twenty yards
    passes_over_twenty   INTEGER,
    -- Passes for more than forty yards
    passes_over_forty    INTEGER,
    -- Number of times sacked
    sacks                INTEGER,
    -- Passer rating
    passer_rating        FLOAT,
    -- Player_id, year, and curr_team are the primary keys
    PRIMARY KEY (player_id, year, curr_team),
    -- player_info references player_id from the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
                            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Rushing career statistics for players
CREATE TABLE rushing (
    -- Unique ID for the player
    player_id          INTEGER,
    -- Year the stats were taken
    year               YEAR,
    -- Current team of the player
    curr_team          VARCHAR(30),
    -- Number of games played in a year
    games_played       INT,
    -- Total number of rush attempts
    rush_attempt       INTEGER,
    -- Total number of rushing yards
    rush_yards         INTEGER,
    -- Total number of rush touchdowns
    rush_tds           INTEGER,
    -- Number of first downs from rushing
    rush_first_down    INTEGER,
    -- Numbers of rushes over twenty yards
    rush_over_twenty   INTEGER,
    -- Number of rushes over forty yards
    rush_over_forty    INTEGER,
    -- Number of fumbles while rushing
    rush_fumbles       INTEGER,
    -- Player_id, year, and curr_team are the primary keys
    PRIMARY KEY (player_id, year, curr_team),
    -- player_info references player_id from the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
                            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Receiving career statistics for players
CREATE TABLE receiving (
    -- Unique ID for the player
    player_id               INTEGER,
    -- Year the stats were taken
    year                    YEAR,
    -- Current team of the player
    curr_team               VARCHAR(30),
    -- Number of games played in a year
    games_played            INT,
    -- Number of receptions
    receptions              INTEGER,
    -- Total number of receiving yards
    receiving_yrds          INTEGER,
    -- Number of receptions to touchdowns
    receiving_tds           INTEGER,
    -- Number of receptions over twenty yards
    reception_over_twenty   INTEGER,
    -- Number of receptions over forty yards
    reception_over_forty    INTEGER,
    -- Number of receptions for a first down
    reception_first_down    INTEGER,
    -- Total number of fumbles
    receive_fumbles         INTEGER,
    -- Player_id, year, and curr_team are the primary keys
    PRIMARY KEY (player_id, year, curr_team),
    -- player_info references player_id from the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
                            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index on fileset that speeds up our query
-- Index to make looking up touchdown passes faster, a common stat for passing
CREATE INDEX idx_nfl_passing ON passing (td_passes);
-- Index to make looking up a player's former college faster
CREATE INDEX idx_nfl_college ON player_info (college);
