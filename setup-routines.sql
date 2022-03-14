-- CS 121 Final Project Routines Setup (UDF, Procedure, and Triggers)

-- Hall of Fame UDF
-- Indicates whether a player, given their stats and their position, has strong enough
-- career statistics to be eligible for the Hall of Fame.
-- Will make a player rating and if the rating is above a threshold, then the player
-- is eligible for the Hall of Fame.

-- DROP FUNCTION eligible_for_hof;
DELIMITER !

CREATE FUNCTION eligible_for_hof (
    player_id INT -- player_id
) RETURNS BOOL DETERMINISTIC
BEGIN
    DECLARE defense_rating INTEGER DEFAULT 0; -- defense rating 
	DECLARE passing_rating INTEGER DEFAULT 0; -- passing rating 
    DECLARE rushing_rating INTEGER DEFAULT 0; -- rushing rating 
    DECLARE receiving_rating INTEGER DEFAULT 0; -- receiving rating 

    DECLARE hof_eligible BOOL; -- holds if the player is induted into the hall of fame
    SET hof_eligible = 0; -- initially set to false

    -- Check if individual stats are good enough for the Hall of Fame (defense)
    SELECT SUM(solo_tackles) + SUM(assist_tackles) AS tot_tackles,
           SUM(sacks) AS tot_sacks, SUM(safeties) AS tot_safeties,
           SUM(interceptions) AS tot_interceptions,
           SUM(interception_yrds) AS tot_interception_yrds
	FROM defense AS d
    WHERE d.player_id = player_id;
    IF tot_tackles > 500 THEN
        SET defense_rating = defense_rating + 1; 
    END IF;
    IF tot_sacks > 50 THEN
        SET defense_rating = defense_rating + 1;
	END IF;
    IF tot_safeties > 1 THEN
        SET defense_rating = defense_rating + 1;
	END IF;
    IF tot_interceptions > 50 THEN
        SET defense_rating = defense_rating + 1;
	END IF;
    IF tot_incerception_yrds > 200 THEN
        SET defense_rating = defense_rating + 1;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (passing)
    SELECT SUM(pass_complete) / SUM(pass_attempt) AS pass_percent,
           SUM(td_passes) AS tot_td_passes, SUM(interceptions) AS tot_interceptions, 
           SUM(passes_over_twenty) AS tot_over_twenty,
           SUM(passes_over_forty) AS tot_over_forty
	FROM passing AS p
	WHERE p.player_id = player_id;
    IF pass_percent > .60 THEN
        SET passing_rating = passing_rating + 1.5;
    END IF;
    IF tot_td_passes > 200 THEN
        SET passing_rating = passing_rating + 1.5;
	END IF;
    IF tot_interceptions > 75 THEN
        SET passing_rating = passing_rating - 0.5;
	END IF;
    IF tot_over_twenty > 100 THEN
        SET passing_rating = passing_rating + 1;
	END IF;
    IF tot_over_forty > 50 THEN
        SET passing_rating = passing_rating + 1;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (rushing)
    SELECT SUM(rush_yards) / SUM(rush_attempt) AS yard_per_rush,
           SUM(rush_tds) AS tot_rush_tds, SUM(rush_first_down) AS tot_first_down,
           SUM(rush_over_twenty) AS tot_over_twenty, SUM(rush_fumbles) AS tot_rush_fumbles
	FROM rushing AS ru
    WHERE ru.player_id = player_id;
    IF yard_per_rush > 25 THEN
        SET rushing_rating = rushing_rating + 1.5;
    END IF;
    IF tot_rush_tds > 50 THEN
        SET rushing_rating = rushing_rating + 1.5;
	END IF;
    IF tot_first_down > 75 THEN
        SET rushing_rating = rushing_rating + 1;
	END IF;
    IF tot_over_twenty > 75 THEN
        SET rushing_rating = rushing_rating + 1;
	END IF;
    IF tot_rush_fumbles > 40 THEN
        SET rushing_rating = rushing_rating - 0.5;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (receiving)
    SELECT SUM(receiving_yrds) AS tot_receiveing_yrds, SUM(receiving_tds) AS tot_receiving_tds,
           SUM(reception_first_down) AS tot_reception_first_down,
           SUM(reception_over_forty) AS tot_over_forty,
           SUM(receive_fumbles) AS tot_receive_fumbles
    FROM receiving AS re
    WHERE re.player_id = player_id;
    IF tot_receiving_yrds > 500 THEN
        SET receiving_rating = receiving_rating + 1.5;
    END IF;
    IF tot_receiving_tds > 50 THEN
        SET receiving_rating = receiving_rating + 1.5;
    END IF;
    IF tot_reception_first_down > 100 THEN
        SET receiving_rating = receiving_rating + 1;
    END IF;
    IF tot_over_forty > 50 THEN
        SET receiving_rating = receiving_rating + 1;
    END IF;
    IF tot_receive_fumbles > 50 THEN
        SET receiving_rating = receiving_rating - 0.5;
    END IF;
    
    -- If the player has a high enough rating, then induct them into the Hall of Fame
    -- (set hof_eligible to 1 or true)
    IF defense_rating > 4 THEN
        SET hof_eligible = 1;
	END IF;
	IF passing_rating > 4 THEN
		SET hof_eligible = 1;
	END IF;
	IF rushing_rating > 4 THEN
		SET hof_eligible = 1;
	END IF;
    IF receiving_rating > 4 THEN
		SET hof_eligible = 1;
	END IF;
	RETURN hof_eligible;
END !
DELIMITER ;

-- Table for materialized hall of fame information
CREATE TABLE mv_hall_of_fame (
    player_id        INT,
    name             CHAR(30),
    position         CHAR(3),
	status           CHAR(7),
    experience       INT,
    player_rating    INTEGER,
    PRIMARY KEY (player_id)
);

-- Populates the initial state of this materialized view
INSERT INTO mv_hall_of_fame (
    SELECT player_id, name, position,
        status, experience
    FROM player NATURAL JOIN player_info
    ORDER BY player_id
);

-- Materialized view of the hall of fame
CREATE VIEW hall_of_fame AS
    SELECT player_id, name, position,
           status, experience, player_rating
    FROM mv_hall_of_fame;

-- A procedure to execute when updating the hall of fame 
-- materialized view (eligigble_for_hof).
-- If a player is already in view, its current information is updated.
DELIMITER !

CREATE PROCEDURE sp_hof_update(
    new_player_id INT
)
BEGIN 
    -- Handles adding players to the Hall of Fame
    -- Also updates player information if the player is already in the view
    IF hof_eligible = 1 THEN
        INSERT INTO mv_hall_of_fame
            VALUES(playr_id, name, position, status, experience, player_rating)
	    ON DUPLICATE KEY UPDATE
            status = status,
            experience = experience,
            player_rating = player_rating;
	END IF;
    -- Handles removing players from the Hall of Fame
    DELETE FROM mv_hall_of_fame
        WHERE player_id = player_id;
END !

-- Handles new rows added to the Hall of Fame table, updates stats accordingly
CREATE TRIGGER trg_hof_insert AFTER INSERT
       ON mv_hall_of_fame FOR EACH ROW
BEGIN
    CALL sp_hof_update(NEW.player_id, NEW.player_rating);
END !

-- Handles rows deleted from the Hall of Fame table, updates stats accordingly
CREATE TRIGGER trg_hof_delete AFTER DELETE
       ON mv_hall_of_fame FOR EACH ROW
BEGIN
    CALL sp_hof_update(OLD.player_id, OLD.player_rating);
END !
DELIMITER ;
