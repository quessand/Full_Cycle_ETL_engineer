import json
import os
import psycopg2

from src.utils.constants import *

class Database:
    def __init__(self, user):
        self.user = user
        self.db_name = 'postgres_local'
        self.db_connect = json.loads(open(get_project_root_dir() + '\src\config\db_connection.json').read().strip())
        self.db_credentials = json.loads(open(get_project_root_dir() + '\src\config\db_credentials.json').read().strip())

    def create_connection(self):
        connection_string = f"postgresql://{self.db_credentials[self.user]['login']}:{self.db_credentials[self.user]['password']}@{self.db_connect[self.db_name]['host']}:{self.db_connect[self.db_name]['port']}/{self.db_connect[self.db_name]['db']}"
        conn = psycopg2.connect(connection_string)

        return conn