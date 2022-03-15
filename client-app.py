"""
This is a template you may start with for your Final Project application.
You may choose to modify it, or you may start with the example function
stubs (most of which are incomplete). An example is also posted
from Lecture 19 on Canvas.
For full credit, remove any irrelevant comments, which are included in the
template to help you get started. Replace this program overview with a
brief overview of your application as well (including your name/partners name).
Some sections are provided as recommended program breakdowns, but are optional
to keep, and you will probably want to extend them based on your application's
features.
"""
import sys
import mysql.connector
import mysql.connector.errorcode as errorcode

DEBUG = True

# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='nflclient',
          port='3306',
          password='password',
          database='nfl'
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------
def hall_of_fame_names_query():
    """

    """
    cursor = conn.cursor()
    sql = """
SELECT name
FROM mv_hall_of_fame;
"""
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for name in rows:
            print('Name: ', f'"{name}"')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

def get_hof_by_team():
    """

    """
    cursor = conn.cursor()
    sql = """WITH
  defense_hof AS (SELECT DISTINCT name, curr_team
                    FROM defense NATURAL JOIN mv_hall_of_fame),
  passing_hof AS (SELECT name, curr_team
                    FROM passing NATURAL JOIN mv_hall_of_fame),
  receiving_hof AS (SELECT name, curr_team
                      FROM receiving NATURAL JOIN mv_hall_of_fame),
  rushing_hof AS (SELECT name, curr_team
                    FROM rushing NATURAL JOIN mv_hall_of_fame)
SELECT *
FROM (SELECT *
      FROM defense_hof
  UNION (SELECT *
         FROM passing_hof)
  UNION (SELECT *
         FROM rushing_hof)
  UNION (SELECT *
         FROM receiving_hof)) AS players
         ORDER BY curr_team;"""
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            (name, curr_team) = row
            print('Name: ', f'"{name}"', 'Team: ', f'({curr_team})')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred.')

def team_hof_count():
    """

    """
    cursor = conn.cursor()
    sql = """WITH
  defense_hof AS (SELECT DISTINCT name, curr_team
                    FROM defense NATURAL JOIN mv_hall_of_fame),
  passing_hof AS (SELECT name, curr_team
                    FROM passing NATURAL JOIN mv_hall_of_fame),
  receiving_hof AS (SELECT name, curr_team
                      FROM receiving NATURAL JOIN mv_hall_of_fame),
  rushing_hof AS (SELECT name, curr_team
                    FROM rushing NATURAL JOIN mv_hall_of_fame),
  players AS (SELECT *
      FROM defense_hof
  UNION (SELECT *
         FROM passing_hof)
  UNION (SELECT *
         FROM rushing_hof)
  UNION (SELECT *
         FROM receiving_hof))
SELECT curr_team, COUNT(name) AS player_count
FROM players
GROUP BY curr_team
ORDER BY player_count DESC;
"""
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            (curr_team, player_count) = row
            print('Team: ', f'"{curr_team}"',':', f'({player_count})', 'Players')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred.')

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def show_options():
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """
    print('What would you like to do? ')
    # print('  (l) login')
    print('  (a) view all hall of fame players')
    print('  (t) view all hall of fame players and their corresponding teams (includes players who played for multiple teams)')
    print('  (c) view teams with most hall of fame players')
    print('  (q) - quit')
    print()
    while True:
        ans = input('Enter an option: ')[0].lower()
        if ans == 'q':
            quit_ui()
        elif ans == 'a':
            hall_of_fame_names_query()
        elif ans == 't':
            get_hof_by_team()
        elif ans == 'c':
            team_hof_count()
        else:
            print('Try again.')

def quit_ui():
    """
    Quits the app.
    """
    print('Thanks!')
    exit()


if __name__ == '__main__':
    conn = get_conn()
    show_options()