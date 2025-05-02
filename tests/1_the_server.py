from test_runner.server_manager import ServerManager
from test_runner.rgsql_client import RgSqlClient
from test_runner.test_file import TestFile
from test_runner.settings import Settings
import time


class TheServer(TestFile):
    def test_server_command_is_configured(self):
        command = Settings.get('server_command')
        self.assert_true(
            len(command.strip()) > 0,
            "You must configure the 'server_command' setting in settings.ini"
        )

    def test_server_can_be_started_and_stopped(self):
        server = ServerManager.ensure_server_running()

        time.sleep(0.2)

        self.assert_true(
            server.running(),
            'Expected server to be running after starting'
        )

        server.stop()

        self.assert_true(
            not server.running(),
            'Expected server to be stopped after sending TERM signal'
        )

        self.assert_no_errors(server)

    def test_server_can_be_connected_to_over_tcp(self):
        server = ServerManager.ensure_server_running()

        RgSqlClient()

        server.stop()
        self.assert_no_errors(server)

    def test_server_can_accept_and_respond_to_a_command(self):
        server = ServerManager.ensure_server_running()
        client = RgSqlClient()
        client.send_message("SELECT 1;\0")

        response = client.receive_message()

        self.assert_true(
            response.endswith("\0"),
            'Expected response to end with a null byte'
        )

        server.stop()
        self.assert_no_errors(server)

    def test_server_waits_for_null_terminated_string_before_responding(self):
        server = ServerManager.ensure_server_running()
        client = RgSqlClient()

        client.send_message("SEL")
        response = client.receive_message(
            timeout=0.2, raise_on_no_response=False)

        self.assert_true(
            response == "",
            f"Expected no response when message is incomplete, but was '{response}'"
        )

        client.send_message("ECT 1;\0")
        response = client.receive_message()

        server.stop()
        self.assert_no_errors(server)

    def test_server_can_accept_and_respond_to_multiple_commands(self):
        server = ServerManager.ensure_server_running()
        client = RgSqlClient()

        for i in range(3):
            client.send_message("SELECT 1;\0")
            response = client.receive_message()

            self.assert_true(
                response.endswith("\0"),
                f'Message {i} does not end with a null byte'
            )

        server.stop()
        self.assert_no_errors(server)
