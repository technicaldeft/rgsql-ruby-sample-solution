import os
import re
from test_runner.utils import print_red


class Example:
    def __init__(self, title, file, group_description, sql, result, columns, error, line, ordered):
        self.title = title
        self.file = file
        self.group_description = group_description
        self.sql = sql
        self.result = result
        self.columns = columns
        self.error = error
        self.line = line
        self.ordered = ordered
        self.chained_examples = []

    def print_summary(self):
        description = f"{self.group_description}: " if self.group_description else ""

        print_red(
            f"A test has failed in {self.file_name()} on line {self.line}:")
        print(f"  {description}{self.title}\n")

    def rerun(self):
        return f"Command to run only this test: ./run-tests tests/{self.file_name()}:{self.line}"

    def file_name(self):
        *_, tail = os.path.split(self.file)
        return tail

    def should_drop_tables(self):
        if re.search(r"^[12][^\d]", self.file_name()):
            return False
        elif self.file_name().startswith("3_"):
            return self.group_description != "Creating and dropping tables"
        else:
            return True
