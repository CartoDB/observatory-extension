import os
import psycopg2

DB_CONN = psycopg2.connect('postgres://{user}:{password}@{host}:{port}/{database}'.format(
    user=os.environ.get('PGUSER', 'postgres'),
    password=os.environ.get('PGPASSWORD', ''),
    host=os.environ.get('PGHOST', 'localhost'),
    port=os.environ.get('PGPORT', '5432'),
    database=os.environ.get('PGDATABASE', 'postgres'),
))
CURSOR = DB_CONN.cursor()


def query(q):
    '''
    Query the database.
    '''
    try:
        CURSOR.execute(q)
        return CURSOR
    except:
        DB_CONN.rollback()
        raise


def commit():
    try:
        DB_CONN.commit()
    except:
        DB_CONN.rollback()
        raise
