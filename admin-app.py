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
logged_in = False

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
          user='nfladmin',
          port='3306',
          password='12345678',
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
def add_data():
    """
    Adds data to the player, player_info, and passing tables.
    """
    cursor = conn.cursor()
    id = input('Enter player_id: ')
    position = input('Enter player position: ')
    status = input('Enter player status: ')
    experience = input('Enter player experience: ')

    name = input('Enter player name: ')
    birth_place = input('Enter birth place of player: ')
    birth_date = input('Enter player birth date: ')
    college = input('Enter player college: ')
    height = input('Enter player height in inches: ')
    weight = input('Enter player weight: ')

    # only able to add to passing for simplicity
    year = input('Enter year: ')
    curr_team = input('Enter year: ')
    games_played = input('Enter games played: ')
    pass_attempt = input('Enter passes attempted: ')
    pass_complete = input('Enter passes completed: ')
    td_passes = input('Enter no. of touchdown passes: ')
    interceptions = input('Enter interceptions count: ')
    passes_over_twenty = input('Enter passes over 20 yds: ')
    passes_over_forty = input('Enter passes over 40 yds: ')
    sacks = input('Enter no. of sacks: ')
    passer_rating = input('Enter passer rating: ')

    args1 = (id, position, status, experience)
    args2 = (id, name, birth_place, birth_date, college, height, weight)
    args3 = (id, year, curr_team, games_played, pass_attempt, pass_complete, td_passes, interceptions, passes_over_twenty, passes_over_forty, sacks, passer_rating)

    try:
        sql = "INSERT INTO player VALUES (%s,%s,%s,%s);"
        cursor.execute(sql, params=args1)
        conn.commit()

        sql = "INSERT INTO player_info VALUES (%s,%s,%s,%s,%s,%s,%s);"
        cursor.execute(sql, params=args2)
        conn.commit()

        sql = "INSERT INTO passing VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);"
        cursor.execute(sql, params=args3)
        conn.commit()

        print(cursor.rowcount, "record inserted.")
        return
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred.')

# ----------------------------------------------------------------------
# Functions for Logging Users In
# ----------------------------------------------------------------------
def log_in():
    """
    Prompts the user to log in to the database.
    """
    cursor = conn.cursor()
    username = input('Username: ')
    password = input('Password: ')
    func = "SELECT authenticate(%s, %s);"
    try:
        cursor.execute(func, (username, password))
        logged_in = True
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred.')

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------

def show_admin_options():
    """
    Displays options specific for admins, such as adding new data <x>,
    modifying <x> based on a given id, removing <x>, etc.
    """
    print('What would you like to do? ')
    print('  (l) login')
    print('  (d) add new data')
    print('  (q) quit')
    print()
    while True:
        ans = input('Enter an option: ')[0].lower()
        if ans == 'q':
            quit_ui()
        elif ans == 'l':
            log_in()
        elif ans == 'd':
            if (logged_in):
                add_data()
            else:
                print('You need to log in first.')
        else:
            print('Unkown option')


def quit_ui():
    """
    Quits the app.
    """
    print('Thanks.')
    exit()



if __name__ == '__main__':
    conn = get_conn()
    show_admin_options()
