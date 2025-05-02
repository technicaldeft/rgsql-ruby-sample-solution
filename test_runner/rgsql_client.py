import json
import socket
import time

from test_runner.test_error import TestError
from test_runner.settings import Settings


class RgSqlClient:
    def __init__(self):
        self.connection = self.connect()

    def connect(self):
        time_taken = 0
        address = ('localhost', self.port())
        while True:
            try:
                return socket.create_connection(address)
            except ConnectionRefusedError:
                time.sleep(0.02)
                time_taken += 0.02
                if time_taken > self.connection_timeout():
                    raise TestError(
                        f"Could not connect to socket on port {self.port()} within {self.connection_timeout()} seconds"
                    )

    def run(self, sql):
        self.send_message(f"{sql}\0")
        response = self.receive_message().rstrip("\0")
        return self.decode_response(response)

    def send_message(self, message):
        self.connection.sendall(message.encode('utf-8'))

    def receive_message(self, timeout=None, raise_on_no_response=True):
        response = b''
        timeout = timeout or self.response_timeout()
        start_time = time.time()
        self.connection.settimeout(timeout)

        while True:
            try:
                ready = self.connection.recv(4096)
            except socket.timeout:
                if raise_on_no_response:
                    raise TestError(self.timeout_message(response))
                else:
                    return response.decode('utf-8')
            except ConnectionResetError:
                raise TestError(
                    "Connection reset error. The server may have exited or closed it's connection.")
            except ConnectionAbortedError:
                raise TestError(
                    "Connection aborted error. The server may have exited or closed it's connection.")

            if ready:
                response += ready
                if response.endswith(b'\0'):
                    return response.decode('utf-8')

            if (time.time() - start_time) > timeout:
                if raise_on_no_response:
                    raise TestError(self.timeout_message(response))
                else:
                    return response.decode('utf-8')

    def timeout_message(self, response):
        if len(response) > 0:
            response = response.decode('utf-8')
            return (
                f"Did not receive null-terminated response within {self.response_timeout()}s, "
                f"received {repr(response)}\n"
            )
        else:
            return f"Did not receive a response within {self.response_timeout()}s"

    def response_timeout(self):
        return int(Settings.get('response_timeout'))

    def connection_timeout(self):
        return int(Settings.get('server_startup_timeout'))

    def port(self):
        return int(Settings.get('server_port'))

    def decode_response(self, response):
        try:
            result = json.loads(response)
        except json.JSONDecodeError:
            raise TestError(f"Cannot parse JSON from server: {response}")

        if 'status' not in result:
            raise TestError(
                f"Server response does not contain a 'status' key: {response}")

        if result['status'] == 'error':
            if 'error_type' not in result:
                raise TestError(
                    f"Server response is 'error' but is missing 'error_type' key: {response}")
        elif result['status'] == 'ok':
            if 'rows' in result:
                rows = result['rows']
                if not isinstance(rows, list):
                    raise TestError(
                        f"Expected 'rows' to contain an array of rows: {response}")
                for row in rows:
                    if not isinstance(row, list):
                        raise TestError(
                            f"Expected each row to contain an array of values: {response}")
                    for value in row:
                        if not isinstance(value, (int, bool, str, type(None))):
                            raise TestError(
                                f"Expected each value to be a integer, boolean, string or null: {response}")
        else:
            raise TestError(
                f"Unexpected status in response from server: {result['status']}")

        return result
