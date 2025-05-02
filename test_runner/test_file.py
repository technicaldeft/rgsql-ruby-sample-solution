import traceback
import inspect
import os
from test_runner.test_error import TestError
from test_runner.utils import print_red, print_green, indent
from test_runner.log_manager import LogManager


class TestFile:
    def assert_true(self, condition, message):
        if not condition:
            raise TestError(message)

    def assert_no_errors(self, server):
        self.assert_true(
            not LogManager.any_errors(),
            'Expected server to not print anything to standard error'
        )

    def run(self, runner, line):
        for method_name, _ in self.load_test_methods(line):
            method = getattr(self, method_name)
            nice_method_name = method_name.replace(
                'test_', 'Check that ').replace("_", " ")
            file = os.path.basename(inspect.getsourcefile(method))
            line = inspect.getsourcelines(method)[1]
            try:
                method()
                print_green(".", end="", flush=True)
                LogManager.print_logs()
                runner.record_pass((file, nice_method_name))
            except TestError as e:
                print_red("F")
                LogManager.print_logs()
                print("")
                self.print_summary(nice_method_name, file, line)
                print(indent(str(e)))
                print('')
                rerun = f"Command to run only this test: ./run-tests tests/{file}:{line}"
                runner.failure(rerun=rerun)
            except Exception as e:
                print_red("E")
                LogManager.print_logs()
                print("")
                self.print_summary(nice_method_name, file, line)
                print(indent("An unexpected error has occurred:"))
                print(indent(traceback.format_exc(), 4))
                print("")
                rerun = f"Command to run only this test: ./run-tests tests/{file}:{line}"
                runner.failure(rerun=rerun)

    def print_summary(self, nice_method_name, file, line):
        print_red(f"A test has failed in {file} on line {line}:")
        print(f"  {nice_method_name}")
        print("")

    def filter_to_line(self, methods, line):
        if not line:
            return methods

        before_line = list(filter(lambda t: t[1] <= line, methods))

        if before_line:
            return [before_line[-1]]
        else:
            return [methods[0]]

    def load_test_methods(self, line):
        test_methods = [
            method for method in dir(self)
            if method.startswith('test_') and callable(getattr(self, method))
        ]

        method_lines = [
            (method, inspect.getsourcelines(getattr(self, method))[1]) for method in test_methods
        ]

        ordered_methods = sorted(method_lines, key=lambda x: x[1])
        return self.filter_to_line(ordered_methods, line)
