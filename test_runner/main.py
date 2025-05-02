import sys

if sys.version_info < (3, 6):
    print("Python 3.6 or later is required. Please install Python 3.6 or later.")
    sys.exit(1)

from test_runner.suite import Suite
from optparse import OptionParser


def main():
    usage = "usage: ./run-tests [options] [FILE]"
    parser = OptionParser(usage=usage)
    parser.add_option("-p", "--postgres-connection",
                      dest="POSTGRES_CONNECTION",
                      metavar="CONNECTION",
                      help="Run tests against a PostgreSQL database by providing a connection string e.g. postgres://localhost/mydb",
                      default=None)

    parser.add_option("-s", "--skip-server-tests",
                      dest="SKIP_SERVER_TESTS",
                      action="store_true",
                      help="Skip the slower tests that check the server can be started and stopped",
                      default=False)

    parser.add_option("-m", "--manual-mode",
                      dest="MANUAL",
                      action="store_true",
                      help="Manage starting and stopping the server yourself. Also skips the server tests.",
                      default=False
                      )

    (options, args) = parser.parse_args()

    Suite(vars(options), args).run()


if __name__ == "__main__":
    main()
