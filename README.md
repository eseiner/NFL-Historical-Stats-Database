# NFL-Historical-Stats-Database
A SQL database of NFL Historical Statistics. Completed as part of Caltech's CS121: Intro to Relational Databases course.

Csv files with our nfl data attained from kaggle dataset: https://www.kaggle.com/kendallgillies/nflstatistics.
To load this data, access the cleaned csv files given by us. In our load-data file, we access the csv files locally, but have put them on our Github and uploaded them on CodePost. Next, to load the data from the command-line into MySQL run the following commands:
$ cd files:
$ mysql --local-infile=1 -u root -p
mysql> source setup.sql;
mysql> source load-data.sql;
mysql> source setup-passwords.sql;
mysql> source setup-routines.sql;
mysql> source grant-permissions.sql;
mysql> source queries.sql; (for queries)
mysql> quit;
$ python3 app-admin.py
OR
$ python3 app-client.py

Now, you should either be in the admin or the client program.
For admin:
(l) - log into the app with admin information
(d) - add new data to the NFL database (passing table for simplicity)
(q) - quit the python program

For client:
(a) - view all the hall of fame players
(t) - view all hall of fame players and their corresponding teams (includes players who played for multiple teams)
(c) - view teams with most hall of fame players
(q) - quit the python program
