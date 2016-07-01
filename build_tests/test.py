import sys
import json
import logging
import subprocess
import argparse
import os
import os.path as osp


LOG = logging.getLogger('cppskeleton')

# {{{ Utils

class WorkcppException(Exception):
    pass

def skip_line(line):
    return len(line) == 0 or line[0] == "#"

def load_file(name):
    f = open(name, 'r')
    cmds = json.load(f)
    f.close()
    return cmds

# }}}
# {{{ Check / NoCheck

def check_expected(e, out):
    LOG.debug("Checking %s", e)
    # TODO use a regex bcs TOTO will match TOTO and TOTODUDU
    # and we don't want that
    if out.find(e) == -1:
        LOG.info(out)
        LOG.critical("Not found '%s'", e)
        raise WorkcppException()
    return 0

def check_noexpected(e, out):
    LOG.debug("NoChecking %s", e)
    if out.find(e) != -1:
        LOG.info(out)
        LOG.critical("Found '%s'", e)
        raise WorkcppException()
    return 0

# }}}
# {{{ Run Test

def process_cmds(cmd):
    try:
        LOG.info("%s", cmd["cmd"])
        out = subprocess.check_output(cmd["cmd"],
                                      stderr=subprocess.STDOUT,
                                      shell=True)
        if len(cmd["expect"]) == 0:
            return 0
        #TODO Add an expect_once
        for e in cmd["expect"]:
            if skip_line(e):
                continue
            check_expected(e, out)
        for e in cmd["noexpect"]:
            if skip_line(e):
                continue
            check_noexpected(e, out)
        print out
    except subprocess.CalledProcessError as e:
        LOG.critical("Command '%s' ('%s') failed with status: %s "\
                     "and output:\n %s", cmd["cmd"], e.cmd,
                     e.returncode, e.output)
        return 1
    except WorkcppException:
        return 1

def run_test(name):
    cmds = load_file(name)
    LOG.info('Test: %s', cmds["desc"])
    LOG.info('List of commands that will be executed:')
    for cmd in cmds["commands"]:
        LOG.info("\t - %s", cmd["cmd"])
    LOG.info('------------------------------------------------')
    for cmd in cmds["commands"]:
        if process_cmds(cmd):
            return 1
    return 0

# }}}
# {{{ Logger

def init_logger(lvl=logging.INFO):
    stream = logging.StreamHandler()
    stream.setLevel(lvl)
    try:
        import colorlog
        stream.setFormatter(colorlog.ColoredFormatter(
            '%(log_color)s%(levelname)8s > %(message_log_color)s%(message)s',
            secondary_log_colors={
                'message':{
                    'DEBUG'   : 'blue',
                    'INFO'    : 'green',
                    'ERROR'   : 'red',
                    'WARNING' : 'yellow',
                    'CRITICAL': 'bold_white,fg_bold_white,bg_red'
                }
            }
        ))
    except ImportError:
        pass
    LOG.setLevel(lvl)
    LOG.addHandler(stream)
    return LOG

# }}}}
# {{{ List

def get_tests(dir_name):
    all_files = []
    for root, _, files in os.walk(dir_name):
        for f in files:
            all_files.append(osp.join(root, f))
    ret = []
    for f in all_files:
        test = load_file(f)
        test['path'] = f
        ret.append(test)
    return ret


def pretty_print_tests(cmds):
    LOG.info('List of available tests:')
    i = 0
    for cmd in cmds:
        i = i + 1
        LOG.info('%2d - %s - %s', i, cmd['name'], cmd['desc'])

# }}}
# {{{ Arguments

def arguments():
    parser = argparse.ArgumentParser(description='')
    sub = parser.add_subparsers(metavar='<commands>', dest='commands')

    run = sub.add_parser(
        'run',
        help='run a single test'
    )
    run.add_argument('name', action='store', metavar='TEST_NAME',
                     help='Name of the test to run')

    run_id = sub.add_parser(
        'run-id',
        help='run a test given its id'
    )
    run_id.add_argument('id', action='store', metavar='TEST_ID',
                        help='Id of the test to run', type=int)

    sub.add_parser(
        'list',
        help='list all the available test'
    )

    sub.add_parser(
        'run-all',
        help='Run all the tests'
    )

    return parser

# }}}

def main():
    init_logger()
    parser = arguments()
    args = parser.parse_args()

    tests = get_tests("build_tests/tests/")
    print args
    if args.commands == 'run':
        for cmd in tests:
            if cmd['name'] == args.name:
                return run_test(cmd['path'])
        LOG.error("Test '%s' not found", args.name)
        pretty_print_tests(tests)
        return 1
    if args.commands == 'run-id':
        if args.id > len(tests):
            LOG.error("Test '%s' not found", args.id)
            pretty_print_tests(tests)
            return 1
        return run_test(tests[args.id - 1]['path'])
    if args.commands == 'run-all':
        i = 0
        for cmd in tests:
            i = i + 1
            LOG.info("Running test '%d'", i)
            if run_test(cmd['path']):
                return 1
    if args.commands == 'list':
        pretty_print_tests(tests)
    return 0

if __name__ == '__main__':
    sys.exit(main())
