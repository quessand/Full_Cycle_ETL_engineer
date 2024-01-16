import os
import sys

project_dir = os.getcwd().rsplit('\\',0)[0]
sys.path.insert(0, project_dir)

from src.utils.database import Database
from src.utils.constants import *

def main():
    etl_conn = Database('admin').create_connection()

    create_schema = open(get_project_root_dir() + '\\1.2 Data mart\\sql_scripts\\create_schema_dm.sql', mode='r', encoding='utf-8-sig').read()
    fill_tables = open(get_project_root_dir() + '\\1.2 Data mart\\sql_scripts\\fill_tables_dm.sql', mode='r', encoding='utf-8-sig').read()

    etl_conn.cursor().execute(create_schema)
    print('Schema created')

    etl_conn.cursor().execute(fill_tables)
    print('Data ready')

    etl_conn.commit()
    etl_conn.close()

if __name__ == '__main__':
    main()