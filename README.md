# Educational-Project-Team-3

## Python script `populate_tables.py`:

The Python script `populate_tables.py` inserts data from CSV files into database tables.

All configuration parameters for connecting to PostgreSQL, path to directory with CSV files and database schema are located and set in configuration file `Config.ini`. Before launching the script, you need to enter your values into this file.

The configuration file `Config.ini` consists of:

+ Settings for PostgreSQL (must be filled in `[PostgreSQL]` block):
	+ **Host:** PostgreSQL host address
	+ **Port:** PostgreSQL port
	+ **Database:** DB name
	+ **User:** DB username
	+ **Password:** user's password

Example of settings for PostgreSQL (empty fields by default):
```sh
[PostgreSQL]
Host = 127.0.0.1
Port = 5432
Database = db_example
User = username_example
Password = password_example
```

+ **Path:** path to the CSV file directory (must be filled in `[CSV]` block).

Example of filling in the `Path` (empty by default):
```sh
[CSV]
Path = C:\Folder_name\
```

+ **Schema:** schema of the database with the tables into which the data is populated (must be filled in `[DB]` block).

Example of filling in the `Schema` (empty by default):
```sh
[DB]
Schema = public
```


### Steps to start the solution:
+ Set your values in the `Config.ini` configuration file.
+ Run `populate_tables.py` (can be via command line):
    + If the table(s) in the specified directory do not exist in the database in the specified schema, the second python script `insert_records_hard_code.py` will be run automatically (Please, make sure it exists in the same directory as `populate_tables.py`)
+ All information about the actions and errors encountered will be in the `log_file.log` file, which will be created automatically. The logs relating to `populate_tables.py` will be in the `log_file.log` file marked `automatic_processing`, if the second script `insert_records_hard_code.py` is running, its logs will be marked `manual_processing`.
+ Check that the tables in the database are populated.
