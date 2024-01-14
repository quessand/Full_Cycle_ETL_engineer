import os
import sys

project_dir = os.getcwd().rsplit('\\',0)[0]
sys.path.insert(0, project_dir)

from src.utils.database import Database
from src.utils.constants import *

def main():
    etl_conn = Database('admin').create_connection()

    sql = open(get_project_root_dir() + '\\1.1 Data upload\\sql_scripts\\create_schema.sql', mode='r', encoding='utf-8-sig').read()

    etl_conn.cursor().execute(sql)
    etl_conn.commit()
    etl_conn.close()

    print('Schema created')

if __name__ == '__main__':
    main()