import importlib.util
from sys import stdin
from test_runner.settings import Settings


def indent(string, spaces=2):
    return "\n".join((" " * spaces) + line for line in string.splitlines())


def to_bool(string):
    return string.lower() in ['true', '1', 't', 'y', 'yes']


def print_green(string, **kwargs):
    print_color(string, 32, **kwargs)


def print_red(string, **kwargs):
    print_color(string, 31, **kwargs)


def print_color(string, color, **kwargs):
    if to_bool(Settings.get('test_colors')) and stdin.isatty():
        print(f"\033[{color}m{string}\033[0m", **kwargs)
    else:
        print(string, **kwargs)


def import_module_by_path(module_name, file_path, class_name):
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return getattr(module, class_name)
