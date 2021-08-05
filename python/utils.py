import csv
import os
import sys
import configparser
import logging
import psycopg2
import pyodbc
import time

max_db_connect_amount = 50  # number of connections to the DB
conn = None


# Function - reads config file
def config(file_name, section_name):
    config_parser = configparser.ConfigParser()
    config_parser.read(file_name)
    if config_parser.has_section(section_name):
        params = config_parser.items(section_name)
        db = dict((x, y) for x, y in params)
    else:
        logger.error(f'Cannot find the section {section_name} in config file. Please, check the config file.')
        sys.exit(1)
    return db


# Function - connects to DB, after failed "db_connect_amount" times it stops
def db_connect(conn, max_db_connect_amount):
    db_params = config('Config.ini', 'PostgreSQL')
    db_connect_amount = 0
    while db_connect_amount <= max_db_connect_amount:
        try:
            conn = psycopg2.connect(**db_params, connect_timeout=10)
            db_connect_amount += 1
            return conn
        except (Exception, psycopg2.OperationalError, pyodbc.OperationalError) as error:
            db_connect_amount += 1
            logger.exception(error)
            logger.info(f'Trying to connect to the database {db_connect_amount} times')
            time.sleep(10)
            if db_connect_amount == max_db_connect_amount:
                logger.exception(error)
                logger.info('_________________________________________________')
                logger.info('Cannot connect to the database. Timeout exception')
                sys.exit(1)


logging.basicConfig(filename='log_file.log', format='%(asctime)s :: %(name)s :: %(levelname)s :: %(message)s',
                    level=logging.INFO)
logger = logging.getLogger('automatic_processing')


def config_parser():
    schema = config('Config.ini', 'DB').get('schema')
    path = config('Config.ini', 'CSV').get('path')

    # Add '\' to the end of the path in config file, if it doesn't exist
    if not path:
        path = os.path.join(os.path.dirname(os.getcwd()), 'Northwind_csv\\')

    if path[-1] != "\\":
        path = path + "\\"
    return schema, path


# Function - reads CSV
def read_csv(full_path, full_table_name, cursor):
    try:
        with open(full_path, 'r') as file:
            reader = csv.reader(file, quoting=csv.QUOTE_ALL)

            # Count the number of columns
            col_num = len(next(reader))
            val = ['%s' for j in range(col_num)]
            values = ",".join(val)
            data = []

            # Truncate the tables before populating
            cursor.execute("TRUNCATE TABLE " + full_table_name + " CASCADE")
            for row in reader:
                # Processing of NULL values
                row = [None if null_val == '' else null_val.strip() for null_val in row]
                data.append(tuple(row))

            # Populate only if dataset is not empty
            if data != []:
                args_str = ','.join(str(cursor.mogrify("(" + values + ")", x).decode('utf8')) for x in data)
                cursor.execute("INSERT INTO " + full_table_name + " VALUES " + args_str)
                conn.commit()

        logger.info(f'Data has been successfully loaded into the table {full_table_name}')
    except Exception:
        logger.exception("The file is not CSV. Please, check the file.")


# Function - gets all tables with FK and sorts into 2 groups:
# middle tables - have FK in the tables without FK
# last tables - have FK in the middle tables
def get_last_tables():
    # Query - Get all FK tables with the connection tables.
    query = """SELECT tc.table_name,
        ccu.table_name AS foreign_table_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage 
        AS kcu ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage 
        AS ccu ON ccu.constraint_name = tc.constraint_name
        WHERE constraint_type = 'FOREIGN KEY';
        """

    cursor.execute(str(query))
    fk_with_conn_tables = cursor.fetchall()
    middle_tables = []
    last_tables = []
    fk_tables = []
    sort_fk_tables = ()

    # Get all tables with FK
    for tup in fk_with_conn_tables:
        fk_tables += [tup[0]]

    # Sort FK tables into middle and last tables
    for tup in fk_with_conn_tables:

        if (tup[1] in fk_tables) & (tup[0] not in last_tables):
            last_tables.append(tup[0])

        elif (tup[1] not in fk_tables) & (tup[0] not in middle_tables) & (tup[0] not in last_tables):
            middle_tables.append(tup[0])

    sort_fk_tables = (middle_tables, last_tables)
    return sort_fk_tables


# Function - sort all tables in the order: tables without FK, middle tables, last tables
def get_sort_tables(tables_list, path):
    sort_tables = []
    sort_fk_tables = []
    last_tables = get_last_tables()
    fk_tables = last_tables[0] + last_tables[1]
    table_search_list = list()

    for table in tables_list:
        full_path = path + table
        # Check existance of file
        if (os.path.isfile(full_path)):

            # Remove the file extension
            table_index_extension = table.rindex('.')
            table_search = str(table[:table_index_extension].lower().strip('_'))
            table_search_list.append(table_search)
            if table_search in fk_tables:
                if table_search in last_tables[0]:
                    sort_fk_tables.insert(0, table)
                else:
                    sort_fk_tables.append(table)
            else:
                sort_tables.insert(0, table)

            sort = sort_tables + sort_fk_tables
        else:
            logger.error(f'Cannot find the file: {table}. Please, check the file in the directory: {path}')
    return sort, sorted(set(table_search_list))


logger.info('Trying to connect to PostgreSQL')
conn = db_connect(conn, max_db_connect_amount)
cursor = conn.cursor()
