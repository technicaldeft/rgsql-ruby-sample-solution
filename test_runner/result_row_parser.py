import re


class ResultRowParser:
    def __init__(self, row):
        self.row = row
        self.last_match = None

    def parse(self):
        values = []
        while self.row:
            value = self.parse_value()
            values.append(value)

            comma = self.consume(r',')
            if not comma and self.row:
                raise Exception('Unexpected result row value: ' + self.row)

            if comma and not self.row:
                raise Exception('Unexpected end of result row')

        return values

    def parse_value(self):
        if self.consume(r'^NULL'):
            return None
        elif self.consume(r'^TRUE'):
            return True
        elif self.consume(r'^FALSE'):
            return False
        elif (self.consume(r'^(-?\d+)')):
            return int(self.last_match)
        else:
            raise Exception('Unexpected result row value: ' + self.row)

    def consume(self, regex):
        regex = re.compile(regex)
        match = regex.match(self.row)
        if match:
            self.row = self.row[match.end():].strip()
            self.last_match = match.group()
            return self.last_match
