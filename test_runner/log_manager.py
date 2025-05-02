from test_runner.utils import indent
import atexit


class LogManager:
    output_file_writer = open('server_output.log', 'w')
    error_file_writer = open('server_error.log', 'w')

    output_file_reader = open('server_output.log', 'r')
    error_file_reader = open('server_error.log', 'r')

    @classmethod
    def get_output_file_writer(cls):
        return cls.output_file_writer

    @classmethod
    def get_error_file_writer(cls):
        return cls.error_file_writer

    @classmethod
    def close_files(cls):
        cls.output_file_writer.close()
        cls.error_file_writer.close()
        cls.output_file_reader.close()
        cls.error_file_reader.close()

    @classmethod
    def print_logs(cls):
        cls.print_log(cls.output_file_reader, 'Server output:')
        cls.print_log(cls.error_file_reader, 'Server error: ')

    @classmethod
    def any_errors(cls):
        current_position = cls.error_file_reader.tell()
        cls.error_file_reader.seek(0, 2)
        end_position = cls.error_file_reader.tell()
        cls.error_file_reader.seek(current_position)
        return current_position != end_position

    @staticmethod
    def print_log(file, title):
        printedTitle = False

        for line in file:
            if not printedTitle:
                print()
                print(title)
                printedTitle = True
            print(indent(line), flush=True)


atexit.register(LogManager.close_files)
