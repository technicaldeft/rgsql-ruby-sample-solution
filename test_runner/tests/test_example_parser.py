import unittest

from test_runner.example_parser import ExampleParser


class TestExampleParser(unittest.TestCase):

    def test_parse_example_with_return(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, FALSE, 3;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()

        self.assertEqual(len(examples), 1)
        example = examples[0]
        self.assertEqual(example.title, 'can select multiple items')
        self.assertEqual(example.sql, ['SELECT 1, FALSE, 3;'])
        self.assertEqual(example.result, [[1, False, 3]])
        self.assertEqual(example.ordered, False)

    def test_parse_with_result_ordered(self):
        example = ("--- can select multiple items\n"
                   "SELECT a from t1;\n"
                   "--- returns in order:\n"
                   "1\n"
                   "2\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].ordered, True)

    def test_parse_example_with_multiple_statements(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1;\n"
                   "SELECT 2;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].sql, ['SELECT 1;', 'SELECT 2;'])

    def test_parse_example_keeps_comments(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1;\n"
                   "-- keep this comment\n"
                   "SELECT 2;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].sql, [
            'SELECT 1;', '-- keep this comment\nSELECT 2;'
        ])

    def test_parse_example_with_multiple_return_rows(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, FALSE, 3;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   "NULL, TRUE, 32\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].result, [[1, False, 3], [None, True, 32]])

    def test_parse_example_returning_no_rows(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, FALSE, 3;\n"
                   "--- returns no rows"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].result, [])

    def test_parse_multiple_examples_with_group_description(self):
        example = ("---- selecting numbers ----\n"
                   "--- can select 1\n"
                   "SELECT 1;\n"
                   "--- returns:\n"
                   "1\n"
                   "\n"
                   "--- can select 2\n"
                   "SELECT 2;\n"
                   "--- returns:\n"
                   "2\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(len(examples), 2)
        self.assertEqual(examples[0].title, 'can select 1')
        self.assertEqual(examples[0].group_description, 'selecting numbers')
        self.assertEqual(examples[0].sql, ['SELECT 1;'])
        self.assertEqual(examples[0].result, [[1]])

        self.assertEqual(examples[1].title, 'can select 2')
        self.assertEqual(examples[1].group_description, 'selecting numbers')
        self.assertEqual(examples[1].sql, ['SELECT 2;'])
        self.assertEqual(examples[1].result, [[2]])

    def test_parse_continuing_examples_with_shared_title(self):
        example = ("--- can select numbers\n"
                   "SELECT 1;\n"
                   "--- returns:\n"
                   "1\n"
                   "\n"
                   "SELECT 2;\n"
                   "--- returns:\n"
                   "2\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(len(examples), 1)
        example = examples[0]
        self.assertEqual(example.title, 'can select numbers')
        self.assertEqual(example.sql, ['SELECT 1;'])
        self.assertEqual(example.result, [[1]])

        self.assertEqual(len(example.chained_examples), 1)
        chained_example = example.chained_examples[0]
        self.assertEqual(chained_example.title, 'can select numbers')
        self.assertEqual(chained_example.sql, ['SELECT 2;'])
        self.assertEqual(chained_example.result, [[2]])

    def test_parse_statements_over_multiple_lines(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1,\n"
                   "FALSE,\n"
                   "3;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].sql, ['SELECT 1,\nFALSE,\n3;'])

    def test_parse_statements_with_comments(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, -- this is a comment\n"
                   "-- another comment\n"
                   "3;\n"
                   "--- returns:\n"
                   "1, FALSE, 3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()
        self.assertEqual(examples[0].sql, [
                         'SELECT 1, -- this is a comment\n-- another comment\n3;'
                         ])

    def test_parse_columns(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, 2;\n"
                   "--- returns:\n"
                   "1, 2\n"
                   "--- with columns:\n"
                   "col_1, col_2,COL_3\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()

        self.assertEqual(len(examples), 1)
        self.assertEqual(examples[0].columns, ["col_1", "col_2", "COL_3"])

    def test_parse_quoted_columns(self):
        example = ("--- can select multiple items\n"
                   'SELECT "a b", "c 😎", "quote_""_", "comma,comma";\n'
                   "--- returns:\n"
                   "1, 2\n"
                   "--- with columns:\n"
                   '"a b", "c 😎", "quote_""_", "comma,comma"\n'
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()

        self.assertEqual(len(examples), 1)
        self.assertEqual(examples[0].columns, [
            "a b", "c 😎", 'quote_"_', 'comma,comma'
        ])

    def test_parse_return_status_ok(self):
        example = ("--- can select multiple items\n"
                   "SELECT 1, FALSE, 3;\n"
                   "--- returns status ok\n"
                   ).split("\n")
        examples = ExampleParser("1.sql", example).parse()

        self.assertEqual(len(examples), 1)
        example = examples[0]
        self.assertEqual(example.title, 'can select multiple items')
        self.assertEqual(example.sql, ['SELECT 1, FALSE, 3;'])
        self.assertEqual(example.result, None)


if __name__ == '__main__':
    unittest.main()
