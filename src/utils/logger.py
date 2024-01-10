import time
import os
import sys
from datetime import datetime as dt

project_dir = os.getcwd().rsplit('\\',1)[0]
sys.path.insert(0, project_dir)

from src.utils.database import Database

class Logger:
    def __init__(self):
        self.logger_conn = Database('logger').create_connection()

    def upload_start(self, table_name):
        datetime = dt.fromtimestamp(time.time()).strftime("%Y-%m-%d %H:%M:%S")
        process_status = 'START'

        query = \
            f'''
            INSERT INTO logs.data_upload_log (table_name, datetime, process_status)
            VALUES ('{table_name}', '{datetime}', '{process_status}')
            '''

        self.logger_conn.cursor().execute(query)
        self.logger_conn.commit()

    def upload_end(self, table_name, rows_count, upload_status):
        datetime = dt.fromtimestamp(time.time()).strftime("%Y-%m-%d %H:%M:%S")
        process_status = 'END'
        
        if upload_status == 'FAILED':
            rows_count = 0

        query = \
            f'''
            INSERT INTO logs.data_upload_log (table_name, datetime, process_status, rows_count, upload_status)
            VALUES ('{table_name}', '{datetime}', '{process_status}', {rows_count}, '{upload_status}')
            '''

        self.logger_conn.cursor().execute(query)
        self.logger_conn.commit()

