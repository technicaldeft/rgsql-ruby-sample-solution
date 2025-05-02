import os
import sys

from test_runner.server_manager import ServerManager
from test_runner.rgsql_client import RgSqlClient
from test_runner.example_runner import ExampleRunner
from test_runner.example_loader import ExampleLoader
from test_runner.utils import import_module_by_path
import test_runner.passed_reporter as passed_reporter
from test_runner.test_error import TestError

current_dir = os.path.dirname(__file__)
tests_dir = os.path.join(current_dir, '..', 'tests')

server_test_path = os.path.join(tests_dir, '1_the_server.py')
ServerTest = import_module_by_path('the_server', server_test_path, 'TheServer')


class Suite:
    def __init__(self, options, filtered_files):
        self.postgres_connection = options['POSTGRES_CONNECTION']
        self.manual = options['MANUAL']
        self.skip_server_tests = options['SKIP_SERVER_TESTS'] or self.manual
        self.passed_reporter = passed_reporter.build(self.postgres_connection)

        if len(filtered_files) > 1:
            raise ValueError("Only one file can be provided")
        if filtered_files:
            split = filtered_files[0].split(":")
            self.filtered_file_path = split[0]
            self.filtered_file_line = int(split[1]) if len(split) > 1 else None
        else:
            self.filtered_file_path = None
            self.filtered_file_line = None

        self.loader = ExampleLoader(
            self.filtered_file_path,
            self.filtered_file_line
        )

    def record_pass(self, details):
        self.passed_reporter.report_pass(details)

    def create_client(self):
        if self.postgres_connection:
            from test_runner.postgres_client import PostgresClient
            return PostgresClient(self.postgres_connection)
        else:
            try:
                return RgSqlClient()
            except TestError as e:
                print(str(e))
                sys.exit(1)

    def run(self):
        try:
            self.run_server_tests()
            self.run_sql_test_files()
        finally:
            print("", end="", flush=True)
            ServerManager.ensure_server_stopped()

    def run_sql_test_files(self):
        if not self.postgres_connection and not self.manual:
            ServerManager.ensure_server_running()

        client = self.create_client()
        runner = ExampleRunner(self, client)

        for example in self.loader.examples():
            if example.should_drop_tables() or self.postgres_connection:
                self.drop_tables(client)
            runner.run(example)

        print("")
        self.passed_reporter.create_report()
        print("All tests passed!")

    def drop_tables(self, client):
        try:
            client.run("DROP TABLE IF EXISTS t1;")
            client.run("DROP TABLE IF EXISTS t2;")
            client.run("DROP TABLE IF EXISTS t3;")
            client.run("DROP TABLE IF EXISTS t4;")
            client.run("DROP TABLE IF EXISTS t5;")
        except TestError as e:
            print("There was an error dropping tables before a test")
            print(str(e))
            sys.exit(1)

    def run_server_tests(self):
        if self.postgres_connection or self.skip_server_tests:
            return
        if self.filtered_file_path and not os.path.samefile(self.filtered_file_path, server_test_path):
            return

        ServerTest().run(self, self.filtered_file_line)

    def failure(self, e=None, rerun=None):
        self.passed_reporter.create_report()
        if rerun:
            print(rerun)
        if e:
            raise e
        else:
            sys.exit(1)
