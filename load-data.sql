-- CS 121 Winter 2022 Final Project
-- Commands to load provided CSV files into your 6 tables.

SET GLOBAL local_infile = 1; 

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/player.csv' INTO TABLE player
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/player_info.csv' INTO TABLE player_info
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/defense.csv' INTO TABLE defense
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/passing.csv' INTO TABLE passing
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/receiving.csv' INTO TABLE receiving
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/halleblend/Desktop/Caltech/sophmore/term2/cs121/finalproject/csvfiles/rushing.csv' INTO TABLE rushing
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
