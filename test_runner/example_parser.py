from test_runner.example import Example
from test_runner.result_row_parser import ResultRowParser
from test_runner.column_parser import ColumnParser


class ExampleParser:
    def __init__(self, file, lines):
        self.lines = lines
        self.line_count = 0
        self.file = file
        self.examples = []

    def next_line_starts_with(self, string):
        return self.lines and self.lines[0].startswith(string)

    def pop_line(self):
        self.line_count += 1
        return self.lines.pop(0)

    def parse(self):
        group_description = None

        while self.lines:
            line = self.pop_line()
            if line.startswith('---- '):
                group_description = line.strip('\n- ')
            elif line.strip() == '':
                continue
            elif line.startswith('--- '):
                title = line[4:].strip()
                self.parse_examples(title, group_description)

        return self.examples

    def parse_examples(self, title, group_description):
        chained_example = False
        while self.lines and not self.lines[0].startswith('---'):
            if self.lines[0].strip() == '':
                self.pop_line()
            else:
                self.parse_example(title, group_description, chained_example)
                chained_example = True

    def parse_example(self, title, group_description, chained_example):
        line = self.line_count

        sql = self.parse_sql()
        (ordered, result) = self.parse_result()
        self.parse_status()
        columns = self.parse_column()
        error = self.parse_error()

        example = Example(
            title=title,
            file=self.file,
            group_description=group_description,
            sql=sql,
            result=result,
            columns=columns,
            error=error,
            line=line,
            ordered=ordered,
        )

        if chained_example:
            self.examples[-1].chained_examples.append(example)
        else:
            self.examples.append(example)

    def parse_status(self):
        if self.next_line_starts_with('--- returns status ok'):
            self.pop_line()

    def parse_error(self):
        if self.next_line_starts_with('--- returns error:'):
            self.pop_line()
            return self.pop_line().strip()

    def parse_column(self):
        if self.next_line_starts_with('--- with columns:'):
            self.pop_line()
            column_string = self.pop_line().strip()
            return ColumnParser(column_string).parse()

    def parse_result(self):
        ordered = False
        result = []
        if self.next_line_starts_with('--- returns:') or self.next_line_starts_with('--- returns in order:'):
            line = self.pop_line()
            if line.startswith('--- returns in order:'):
                ordered = True
            while self.lines and self.lines[0].strip() != '' and not self.next_line_starts_with('--- '):
                row = self.pop_line().strip()
                values = ResultRowParser(row).parse()
                result.append(values)

            return ordered, result
        elif self.next_line_starts_with('--- returns no rows'):
            self.pop_line()
            return ordered, []
        else:
            return ordered, None

    def parse_sql(self):
        sql_lines = []
        statements = []

        while self.lines and (not self.next_line_starts_with('--- ')):
            line = self.pop_line().rstrip("\n")
            sql_lines.append(line)

        buffer = []
        for line in sql_lines:
            buffer.append(line)
            if line.strip().endswith(';'):
                statements.append('\n'.join(buffer))
                buffer = []

        if buffer:
            statements.append('\n'.join(buffer))

        return statements
