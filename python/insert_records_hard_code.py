import psycopg2
from psycopg2 import sql
import os
import csv
import json
import logging
import base64
from utils import *

logging.basicConfig(filename='log_file.log', format='%(asctime)s :: %(name)s :: %(levelname)s :: %(message)s',
                    level=logging.INFO)
log = logging.getLogger('manual_processing')

schema, path = config_parser()
tables_list = os.listdir(path)
sort_tables = get_sort_tables(tables_list, path)[1]

file_list = [i.capitalize() + '.csv' for i in sort_tables]
json_file_list = [i.capitalize() + '.json' for i in sort_tables]
table_list = [i.lower() for i in sort_tables]

path_maker = lambda files: os.path.join(path, files)

file_list = list(map(path_maker, file_list))
json_file_list = list(map(path_maker, json_file_list))


def check_table_exists(conn, table_name, schema):
    if conn is not None:
        cur = conn.cursor()
        cur.execute("SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name=%s and table_schema=%s)",
                    (table_name, schema))
        if cur.fetchone()[0]:
            return True


def csv_to_json(csv_file, json_file):
    json_list = []

    try:
        with open(csv_file, encoding='utf-8') as csv_f:
            csv_reader = csv.DictReader(csv_f)

            for row in csv_reader:
                row = {key.lower(): (None if value == "" else value) for key, value in row.items()}
                json_list.append(row)
    except Exception:
        log.exception("csv file ERROR")

    with open(json_file, 'w', encoding='utf-8') as json_f:
        json_string = json.dumps(json_list, sort_keys=True, indent=4)
        json_f.write(json_string)


def get_columns_names(table):
    columns = []
    col_cursor = conn.cursor()

    col_names_str = f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table}'\nORDER BY column_name"

    try:
        sql_object = sql.SQL(col_names_str).format(sql.Identifier(table))

        col_cursor.execute(sql_object)
        col_names = (col_cursor.fetchall())

        for tup in col_names:
            columns += [tup[0]]

        col_cursor.close()

    except Exception:
        log.exception("get_columns_names ERROR")

    return columns


def insert_records(file_name, schema, table_name):
    with open(file_name) as json_data:
        record_list = json.load(json_data)

        sql_string = 'INSERT INTO {}.{} '.format(schema, table_name)

        columns = get_columns_names(table_name)

        sql_string += "(" + ', '.join(columns) + ")\nVALUES "

        for i, record_dict in enumerate(record_list):
            values = []
            for col_names, val in record_dict.items():
                if type(val) == str:
                    val = val.replace("'", "''").strip()
                    val = "'" + val + "'"
                    val = val.replace("'$None$'", "NULL")
                values += [str(val)]
            sql_string += "(" + ', '.join(values) + "),\n"
        sql_string = sql_string[:-2] + ";"
    return sql_string


for file in file_list:
    if os.path.exists(file):
        log.info(f"{file} exists")
    else:
        log.error(f"{file} doesn't exist")
csv_to_json_list = list(zip(file_list, json_file_list))

for table in table_list:
    if check_table_exists(conn, table, schema):
        log.info(f"{schema}.{table} exists")
    else:
        log.error(f"{schema}.{table} doesn't exist")

for lst in csv_to_json_list:
    csv_to_json(lst[0], lst[1])

table_file_list = list(zip(json_file_list, table_list))

if conn is not None:
    cur = conn.cursor()
    try:
        for lst in table_file_list:
            cur.execute('TRUNCATE TABLE {}.{} CASCADE'.format(schema, lst[1]))
            cur.execute(insert_records(lst[0], schema, lst[1]))
            conn.commit()
            log.info('{}.{} was successfully truncated'.format(schema, lst[1]))
            log.info('{}.{} was successfully populated with data'.format(schema, lst[1]))
    except Exception:
        log.exception("Insert records into table ERROR")

    finally:
        cur.close()
        conn.close()
