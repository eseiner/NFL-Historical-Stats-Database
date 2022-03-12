-- Queries for CS121 Final Project

-- Query 1 (Relational Algebra question 1)
-- Get a list of all colleges and the number of defensive players
-- that have attended the corresponding college.
SELECT college, COUNT(DISTINCT player_id) AS players
FROM defense NATURAL JOIN player_info
GROUP BY college;

-- Query 2 (Relational Algebra question 2)
-- Write a query that returns the names of NFL players
-- that have both receiving statistics and defensive statistics.
SELECT player_id, name
FROM defense NATURAL JOIN receiving NATURAL JOIN player_info
GROUP BY player_id;

-- Query 3
-- Search for all quarterbacks who passed for at least 10 Touchdowns in a
-- season who played for the Dallas Cowboys, ordered by number of
-- touchdown passes (descending)
SELECT name, td_passes, year
FROM passing NATURAL JOIN player_info
WHERE curr_team='Dallas Cowboys' AND td_passes > 10
ORDER BY td_passes DESC;

-- Query 4
-- Search for the total number of rushing touchdowns
-- scored by each team throughout their history, ordered
-- by the number of touchdowns scored (descending).
SELECT curr_team, SUM(rush_tds) AS touchdowns
FROM rushing
GROUP BY curr_team
ORDER BY touchdowns DESC;

-- Query 5
-- Search for the total number of receptions longer
-- than 40 yards for each player in their career ordered
-- by the number of receptions (descending).
SELECT name, SUM(reception_over_forty) AS forty_yds
FROM player_info NATURAL JOIN receiving
GROUP BY player_id
ORDER BY forty_yds DESC;

-- Query 6
-- Search for all players of any position (offensive or defensive)
-- who played more than 200 career games, ordered by the number of
-- games played (descending).
WITH
  defense_games AS (SELECT name, SUM(games_played) AS career_games
                    FROM defense NATURAL JOIN player_info
                    GROUP BY player_id),
  passing_games AS (SELECT name, SUM(games_played) AS career_games
                    FROM passing NATURAL JOIN player_info
                    GROUP BY player_id),
  receiving_games AS (SELECT name, SUM(games_played) AS career_games
                      FROM receiving NATURAL JOIN player_info
                      GROUP BY player_id),
  rushing_games AS (SELECT name, SUM(games_played) AS career_games
                    FROM rushing NATURAL JOIN player_info
                    GROUP BY player_id)
SELECT *
FROM (SELECT *
      FROM defense_games
  UNION (SELECT *
         FROM passing_games)
  UNION (SELECT *
         FROM rushing_games)
  UNION (SELECT *
         FROM receiving_games)) AS players
WHERE career_games > 200
ORDER BY career_games DESC;