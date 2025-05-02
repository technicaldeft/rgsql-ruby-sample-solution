import sys

try:
    import psycopg2
    import psycopg2.extras

except ImportError:
    print(
        'Please install the psycopg2 package to run the tests against a PostgreSQL database')
    sys.exit(1)


class PostgresClient:
    ERROR_CODES_TO_ERROR_TYPES = {
        '22012': 'division_by_zero_error',
        '42704': 'parsing_error',  # undefined column type
        '42601': 'parsing_error',  # general syntax error
        '42P07': 'validation_error',  # duplicate table
        '42701': 'validation_error',  # duplicate columns in create
        '42P01': 'validation_error',  # table doesn't exist
        '42883': 'validation_error',  # undefined function
        '42804': 'validation_error',  # datatype mismatch
        '42703': 'validation_error',  # column doesn't exist
        '42P10': 'validation_error',  # invalid column reference (e.g. limit)
        '42702': 'validation_error',  # ambiguous column
        '42712': 'validation_error',  # duplicate alias
        '42803': 'validation_error'  # grouping error
    }

    def __init__(self, postgres_connection):
        self.connection = psycopg2.connect(postgres_connection)
        self.connection.set_session(autocommit=True)
        self.cursor = self.connection.cursor(
            cursor_factory=psycopg2.extras.DictCursor)
        self.cursor.execute('SET client_min_messages TO WARNING;')

    def error_type(self, error):
        error_code = error.pgcode
        error_type = self.ERROR_CODES_TO_ERROR_TYPES.get(error_code)
        if error_type is None:
            raise ValueError(
                f"Unmapped error code: {error_code}, error: {error.pgerror}")

        if error_code == '42601' and 'INSERT has more expressions than target columns' in error.pgerror:
            return 'validation_error'
        return error_type

    def run(self, sql):
        try:
            self.cursor.execute(sql)
            if self.cursor.description is None:
                return {'status': 'ok'}
            else:
                result = self.cursor.fetchall()
                column_names = [desc[0] for desc in self.cursor.description]
                return {'rows': result, 'column_names': column_names, 'status': 'ok'}
        except psycopg2.Error as e:
            return {'status': 'error', 'error_type': self.error_type(e)}
