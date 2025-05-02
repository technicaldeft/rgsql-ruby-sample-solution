import os
import glob
import re


from test_runner.example_parser import ExampleParser


def path_sort_key(path):
    file_name = os.path.basename(path)
    return [int(re.match(r'^(\d+)', file_name).group(1)), file_name]


current_dir = os.path.dirname(__file__)
tests_dir = os.path.join(current_dir, '..', 'tests')
sql_test_files = glob.glob(os.path.join(tests_dir, '*.sql'))
sql_test_files = sorted(sql_test_files, key=path_sort_key)


class ExampleLoader:
    def __init__(self, filtered_path, filtered_line):
        self.filtered_path = filtered_path
        self.filtered_line = filtered_line

    def examples(self):
        for path in self.filtered_paths():
            for example in self.load_examples(path):
                yield example

    def filtered_paths(self):
        if self.filtered_path:
            return [file for file in sql_test_files if os.path.samefile(file, self.filtered_path)]
        else:
            return sql_test_files

    def filter_to_line(self, examples, line):
        if not line:
            return examples

        before_line = list(filter(lambda e: e.line <= line, examples))
        if before_line:
            return [before_line[-1]]
        else:
            return [examples[0]]

    def load_examples(self, path):
        with open(path, 'r') as file:
            lines = file.readlines()

        examples = ExampleParser(path, lines).parse()
        return self.filter_to_line(examples, self.filtered_line)
