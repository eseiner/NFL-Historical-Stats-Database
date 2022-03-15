-- CS 121 Final Project Routines Setup (UDF, Procedure, and Triggers)

-- Hall of Fame UDF
-- Indicates whether a player, given their stats and their position, has strong enough
-- career statistics to be eligible for the Hall of Fame.
-- Will make a player rating and if the rating is above a threshold, then the player
-- is eligible for the Hall of Fame.

DROP FUNCTION IF EXISTS eligible_for_hof;
DELIMITER !

CREATE FUNCTION eligible_for_hof (
    player_id INT -- player_id
) RETURNS BOOL DETERMINISTIC
BEGIN
    DECLARE defense_rating INTEGER DEFAULT 0; -- defense rating 
	DECLARE passing_rating INTEGER DEFAULT 0; -- passing rating 
    DECLARE rushing_rating INTEGER DEFAULT 0; -- rushing rating 
    DECLARE receiving_rating INTEGER DEFAULT 0; -- receiving rating
    
    DECLARE tackles INTEGER;
    DECLARE sacks INTEGER;
    DECLARE intercepts INTEGER;
    
	DECLARE tds INTEGER;
    DECLARE percent FLOAT;
    
	DECLARE rush_yds INTEGER;
    DECLARE rush_tds INTEGER;
    
	DECLARE rec_yds INTEGER;
    DECLARE rec_tds INTEGER;
    
    DECLARE hof_eligible BOOL; -- holds if the player is induted into the hall of fame
    SET hof_eligible = 0; -- initially set to false

    -- Check if individual stats are good enough for the Hall of Fame (defense)
    SET tackles = (SELECT SUM(solo_tackles) + SUM(assist_tackles) AS tot_tackles
	FROM defense AS d
    WHERE d.player_id = player_id);
    
	SET sacks = (SELECT SUM(sacks) AS tot_sacks
	FROM defense AS d
    WHERE d.player_id = player_id);
    
	SET intercepts = (SELECT SUM(interceptions) AS tot_interceptions
	FROM defense AS d
    WHERE d.player_id = player_id);
    
    IF tackles > 500 THEN
        SET defense_rating = defense_rating + 1; 
    END IF;
    IF sacks > 50 THEN
        SET defense_rating = defense_rating + 1;
	END IF;
    IF intercepts > 50 THEN
        SET defense_rating = defense_rating + 1;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (passing)
    SET tds = (SELECT SUM(td_passes) AS tot_td_passes
	FROM passing AS p
	WHERE p.player_id = player_id);
    
    SET percent = (SELECT SUM(pass_complete) / SUM(pass_attempt)
                     AS pass_percent
	FROM passing AS p
	WHERE p.player_id = player_id);
    
    IF percent > .60 THEN
        SET passing_rating = passing_rating + 1.5;
    END IF;
    IF tds > 200 THEN
        SET passing_rating = passing_rating + 1.5;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (rushing)
    SET rush_yds = (SELECT SUM(rush_yards) / SUM(rush_attempt) AS yard_per_rush
	FROM rushing AS ru
    WHERE ru.player_id = player_id);
    
	SET rush_tds = (SELECT SUM(rush_tds) AS tot_rush_tds
	FROM rushing AS ru
    WHERE ru.player_id = player_id);
	
    IF rush_tds > 50 THEN
        SET rushing_rating = rushing_rating + 1.5;
	END IF;
    IF rush_yds > 6000 THEN
        SET rushing_rating = rushing_rating + 1.5;
	END IF;

    -- Check if individual stats are good enough for the Hall of Fame (receiving)
    SET rec_yds = (SELECT SUM(receiving_yrds) AS tot_receiveing_yrds
    FROM receiving AS re
    WHERE re.player_id = player_id);
    
	SET rec_tds = (SELECT SUM(receiving_tds) AS tot_receiving_tds
    FROM receiving AS re
    WHERE re.player_id = player_id);
    
    
    IF rec_yds > 3500 THEN
        SET receiving_rating = receiving_rating + 1.5;
    END IF;
    IF rec_tds > 50 THEN
        SET receiving_rating = receiving_rating + 1.5;
    END IF;
    
    -- If the player has a high enough rating, then induct them into the Hall of Fame
    -- (set hof_eligible to 1 or true)
    IF defense_rating >= 1.5 THEN
        SET hof_eligible = 1;
	END IF;
	IF passing_rating >= 1.5 THEN
		SET hof_eligible = 1;
	END IF;
	IF rushing_rating >= 1.5 THEN
		SET hof_eligible = 1;
	END IF;
    IF receiving_rating >= 1.5 THEN
		SET hof_eligible = 1;
	END IF;
	RETURN hof_eligible;
END !
DELIMITER ;

-- Table for materialized hall of fame information
DROP TABLE mv_hall_of_fame;
CREATE TABLE mv_hall_of_fame (
    player_id        INT,
    name             CHAR(30),
    position         CHAR(3),
	status           CHAR(7),
    experience       INT,
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
DROP VIEW hall_of_fame;
CREATE VIEW hall_of_fame AS
    SELECT player_id, name, position,
           status, experience
    FROM mv_hall_of_fame;

-- A procedure to execute when updating the hall of fame 
-- materialized view (eligigble_for_hof).
DELIMITER !

-- DROP PROCEDURE sp_hof_update;
CREATE PROCEDURE sp_hof_update(
    IN id VARCHAR(15),
    IN name VARCHAR(50),
    IN position VARCHAR(3),
    IN status VARCHAR(10),
    IN experience INTEGER
)
BEGIN 
    -- Handles adding players to the Hall of Fame
    IF eligible_for_hof(id) = 1 THEN
        INSERT INTO mv_hall_of_fame
            VALUES(id, name, position, status, experience);
-- 	    ON DUPLICATE KEY UPDATE
--             OLD.status = NEW.status,
--             OLD.experience = NEW.experience;
	END IF;
    -- Handles removing players from the Hall of Fame
    IF eligible_for_hof(id) = 0 THEN
      DELETE FROM mv_hall_of_fame
          WHERE player_id = id;
	END IF;
END !

-- Handles new rows added to the Hall of Fame table, updates stats accordingly
-- DROP TRIGGER trg_hof_insert;
CREATE TRIGGER trg_hof_insert AFTER INSERT
       ON passing FOR EACH ROW
BEGIN
-- Only add to passing table after adding to player and player_info tables.
	DECLARE name VARCHAR(50);
    DECLARE position VARCHAR(3);
    DECLARE status VARCHAR(10);
    DECLARE experience INTEGER;
    
    SET name = (SELECT name FROM player_info
               WHERE player_id = NEW.player_id);
	SET position = (SELECT position FROM player
               WHERE player_id = NEW.player_id);
	SET status = (SELECT status FROM player
                    WHERE player_id = NEW.player_id);
	SET experience = (SELECT experience FROM player
				      WHERE player_id = NEW.player_id);

    CALL sp_hof_update(NEW.player_id, name, position, status, experience);
END !

-- Handles rows deleted from the Hall of Fame table, updates stats accordingly
DROP TRIGGER IF EXISTS trg_hof_defense;
CREATE TRIGGER trg_hof_defense AFTER INSERT
       ON defense FOR EACH ROW
BEGIN
    DECLARE name VARCHAR(50);
    DECLARE position VARCHAR(3);
    DECLARE status VARCHAR(10);
    DECLARE experience INTEGER;
    
    SET name = (SELECT name FROM player_info
               WHERE player_id = NEW.player_id);
	SET position = (SELECT position FROM player
               WHERE player_id = NEW.player_id);
	SET status = (SELECT status FROM player
                    WHERE player_id = NEW.player_id);
	SET experience = (SELECT experience FROM player
				      WHERE player_id = NEW.player_id);

    CALL sp_hof_update(NEW.player_id, name, position, status, experience);
END !
DELIMITER ;
