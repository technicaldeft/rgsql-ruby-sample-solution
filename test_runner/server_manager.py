import subprocess
import atexit
import os
import time

from test_runner.settings import Settings
from test_runner.test_error import TestError
from test_runner.log_manager import LogManager


class ServerManager:
    _singleton = None

    @classmethod
    def ensure_server_running(cls):
        if cls._singleton is None:
            cls._singleton = cls()
            cls._singleton.start_server()
        elif not cls._singleton.running():
            cls._singleton.start_server()
        return cls._singleton

    @classmethod
    def ensure_server_stopped(cls):
        if cls._singleton is not None:
            cls._singleton.stop()
            cls._singleton = None

    @classmethod
    def print_server_logs(cls):
        if cls._singleton is not None:
            cls._singleton.print_logs()

    def __init__(self):
        self.process = None
        self.stop_event = None
        atexit.register(self.stop)

    def running(self):
        if self.process and self.process.poll() is None:
            return True
        return False

    def stop(self):
        if self.process:
            self.terminate_process()
            self.process = None

    def terminate_process(self):
        start_time = time.time()
        try:
            pgid = os.getpgid(self.process.pid)
            os.killpg(pgid, 15)
        except ProcessLookupError:
            return

        while True:
            if (time.time() - start_time) > 3:
                raise TestError('Could not stop server within 3 seconds')
            try:
                os.waitpid(-pgid, 0)
                time.sleep(0.02)
            except ChildProcessError:
                return

    def start_server(self):
        if self.running():
            return

        self.process = subprocess.Popen(
            Settings.get('server_command'),
            stdout=LogManager.get_output_file_writer(),
            stderr=LogManager.get_error_file_writer(),
            universal_newlines=True,
            shell=True,
            start_new_session=True
        )
