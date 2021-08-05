from utils import *

# Create log file
logging.basicConfig(filename='log_file.log', format='%(asctime)s :: %(name)s :: %(levelname)s :: %(message)s',
					level=logging.INFO)
logger = logging.getLogger('automatic_processing')

# Connect to PostgreSQL

try:
	logger.info('Connected to PostgreSQL')
	schema, path = config_parser()

	# Check existence of the directory
	if os.path.exists(path):
		tables_list = os.listdir(path)
		sort_tables = get_sort_tables(tables_list, path)[0]
		for i in range(len(sort_tables)):
			full_path = path + sort_tables[i]
			# Remove the file extension
			table_index_extension = sort_tables[i].rindex('.')
			table_name = str(sort_tables[i][:table_index_extension].lower().strip('_'))

			full_table_name = schema + '.' + table_name
			cursor.execute(
				"SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_name = '" + table_name + "')")
			table_exists = bool(cursor.fetchone()[0])
			# Check existence the table in DB
			if table_exists:
				logger.info(f'Loading data to the table {table_name}')

				max_tb_populate_amount = 5
				tb_populate_amount = 0

				while tb_populate_amount < (max_tb_populate_amount + 1):

					try:

						# Read CSV
						read_csv(full_path, full_table_name, cursor)
						tb_populate_amount += 1
						break

					except (Exception, psycopg2.DatabaseError, psycopg2.OperationalError) as error:

						tb_populate_amount += 1
						logger.exception(error)
						conn = None
						conn = db_connect(conn, max_db_connect_amount)
						cursor = conn.cursor()
						logger.info(f'Trying to load data to the database {tb_populate_amount} times')

						if tb_populate_amount == max_tb_populate_amount:
							logger.exception(error)
							logger.info('___________________________________________________')
							logger.info('Cannot load data to the database. Timeout exception')
							sys.exit(1)
			else:
				logger.error(f'Cannot find table {table_name} in the database.')
				if os.path.exists('insert_records_hard_code.py'):
					logger.info('Run the second Python script for manual processing.')
					exec(open('insert_records_hard_code.py').read())
					sys.exit(1)
				else:
					logger.error(f'Cannot find the second Python script for manual processing')
					sys.exit(1)
		cursor.close()

	else:
		logger.error('Cannot find the directory. Please, check the path of directory with tables in the config file')

except (Exception, psycopg2.DatabaseError) as error:
	logger.exception(error)

# close the communication with the PostgreSQL
finally:
	if conn is not None:
		conn.close()
		logger.info('Database connection closed.')
