from utils import *

max_db_connect_amount = 3  # number of connections to the DB
conn = db_connect(None, max_db_connect_amount)
cursor = conn.cursor()


def main(conn, cursor):
    try:
        logger.info('Connected to PostgreSQL')
        schema, path = parse_config()
        if os.path.exists(path):
            tables_list = os.listdir(path)
            sort_tables = get_sort_tables(conn, tables_list, path)[0]
            for i in range(len(sort_tables)):
                full_path = path + sort_tables[i]
                # Remove the file extension
                table_index_extension = sort_tables[i].rindex('.')
                table_name = str(sort_tables[i][:table_index_extension].lower().strip('_'))

                full_table_name = schema + '.' + table_name
                cursor.execute(
                    f"SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_name = '{table_name}')")
                table_exists = bool(cursor.fetchone()[0])
                # Check existence the table in DB
                if table_exists:
                    logger.info(f'Loading data to the table {table_name}')
                    max_tb_populate_amount = 5
                    tb_populate_amount = 0

                    while tb_populate_amount < (max_tb_populate_amount + 1):
                        try:
                            # Read CSV
                            read_csv(conn, full_path, full_table_name)
                            tb_populate_amount += 1
                            break
                        except (Exception, psycopg2.DatabaseError, psycopg2.OperationalError) as error:

                            tb_populate_amount += 1
                            logger.exception(error)
                            logger.info(f'Trying to load data to the database {tb_populate_amount} times')

                            if tb_populate_amount == max_tb_populate_amount:
                                logger.exception(error)
                                logger.info('___________________________________________________')
                                logger.info('Cannot load data to the database. Timeout exception')
                                sys.exit(1)
                else:
                    logger.error(f'Cannot find table {table_name} in the database.')
                    print(f'Cannot find table {table_name} in the database.')
                    sys.exit(1)
            cursor.close()

        else:
            print('Cannot find the directory. Please, check the path of directory with tables in the config file')
            logger.error(
                'Cannot find the directory. Please, check the path of directory with tables in the config file')

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        logger.exception(error)

    # close the communication with the PostgreSQL
    finally:
        if conn is not None:
            conn.close()
            logger.info('Database connection closed.')


if __name__ == "__main__":
    main(conn, cursor)
