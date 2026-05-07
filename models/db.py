import mysql.connector
from mysql.connector import pooling
from config import Config

# Initialize connection pool
try:
    db_pool = mysql.connector.pooling.MySQLConnectionPool(
        pool_name="recruitment_pool",
        pool_size=5,
        pool_reset_session=True,
        host=Config.DB_HOST,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        database=Config.DB_NAME
    )
    print("Database connection pool established.")
except mysql.connector.Error as err:
    print(f"Error creating connection pool: {err}")
    db_pool = None

def get_db_connection():
    """Get a connection from the pool."""
    if db_pool:
        return db_pool.get_connection()
    raise Exception("Database connection pool not initialized")

def call_procedure_out(proc_name, args):

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    results = []
    args_list = list(args)
    try:
        out_args = cursor.callproc(proc_name, args_list)
        db.commit()
        
        for result in cursor.stored_results():
            results.extend(result.fetchall())
            
        if isinstance(out_args, dict):
            args_list = list(out_args.values())
        elif isinstance(out_args, (list, tuple)):
            args_list = list(out_args)
            
    except Exception as e:
        db.rollback()
        print(f"Error executing procedure {proc_name}: {e}")
        raise e
    finally:
        cursor.close()
        db.close()
        
    return results, args_list

def query_db(query, args=(), one=False):
    """Executes a simple SELECT query."""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    try:
        cursor.execute(query, args)
        results = cursor.fetchall()
        return (results[0] if results else None) if one else results
    finally:
        cursor.close()
        db.close()
