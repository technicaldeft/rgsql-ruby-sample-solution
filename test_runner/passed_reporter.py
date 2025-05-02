import os
from collections import OrderedDict
import test_runner.utils as utils
from test_runner.settings import Settings

current_dir = os.path.dirname(__file__)
root = os.path.join(current_dir, '..')

passed_test_path = os.path.join(root, '.passed_tests')


def format_details(details):
    return '~'.join(details)


def build(using_postgres):
    if os.getenv('CI') or (Settings.get('report_first_passes') == 'false') or using_postgres:
        return NullReporter()
    else:
        return PassedReporter()


class NullReporter:
    def report_pass(self, details):
        pass

    def create_report(self):
        pass


class PassedReporter:
    def __init__(self):
        self.newly_passed = []
        self.load_previously_passed()

    def report_pass(self, details):
        if format_details(details) not in self.previously_passed:
            self.newly_passed.append(details)

    def create_report(self):
        self.record_newly_passed()
        headings = {}

        if self.newly_passed:
            utils.print_green(
                f"There are {len(self.newly_passed)} tests that have passed for the first time:")
        for details in self.newly_passed:
            for index, detail in enumerate(details):
                if headings.get(index) != detail:
                    headings[index] = detail
                    for key in list(headings.keys()):
                        if key > index:
                            del headings[key]
                    print(utils.indent(detail, (index + 1) * 2))

        if self.newly_passed:
            print("")

    def load_previously_passed(self):
        self.previously_passed = OrderedDict()
        open(passed_test_path, 'a+').close()
        with open(passed_test_path, 'r') as file:
            for line in file:
                self.previously_passed[line.strip()] = None

    def record_newly_passed(self):
        with open(passed_test_path, 'a') as file:
            for details in self.newly_passed:
                file.write(f"{format_details(details)}\n")
