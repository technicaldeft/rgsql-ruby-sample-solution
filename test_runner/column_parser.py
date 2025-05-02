import re


class ColumnParser:
    def __init__(self, columns):
        self.columns = columns
        self.last_match = None

    def parse(self):
        values = []
        while self.columns:
            value = self.parse_column()
            values.append(value)
            comma = self.consume(r'(,)')
            if not comma and self.columns:
                raise Exception('Unexpected column names: ' + self.columns)

            if comma and not self.columns:
                raise Exception('Unexpected end of column names')

        return values

    def parse_column(self):
        if self.consume(r'^([a-zA-Z_][\.\w]*)'):
            return self.last_match
        elif self.consume(r'^"((?:[^"]|"")*)"'):
            return self.last_match.replace('""', '"')
        else:
            raise Exception('Unexpected column names: ' + self.columns)

    def consume(self, regex):
        regex = re.compile(regex)
        match = regex.match(self.columns)
        if match:
            self.columns = self.columns[match.end():].strip()
            self.last_match = match.group(1)
            return self.last_match
