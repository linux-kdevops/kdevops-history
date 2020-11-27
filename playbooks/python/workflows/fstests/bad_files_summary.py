#!/usr/bin/python3

# Generate expunge list based on results directory
#
# Given a directory path it finds all test failures and produces an
# expunge list you can use with fstests's check.sh -E option to let you
# then skip those tests.

import argparse
import os
import sys

def parse_results_ascii(sections, results, kernel, filesystem):
    sys.stdout.write("%s on %s\n" % (filesystem, kernel))
    for section in sections:
        sys.stdout.write("%s\n" % section)
        for test in results[section]:
            sys.stdout.write("\t%s\n" % test)

def parse_results_html(sections, results, kernel, filesystem):
    sys.stdout.write("<html><title>%s on %s</title><body>" % (filesystem, kernel))
    sys.stdout.write("<h1>%s on %s</h1>\n" % (filesystem, kernel))
    for section in sections:
        sys.stdout.write("<h2>%s</h2><p>\n" % section)
        sys.stdout.write("<table>\n")
        sys.stdout.write("<tr>\n")
        sys.stdout.write("<th>test name</th>")
        sys.stdout.write("</tr>\n")
        for test in results[section]:
            sys.stdout.write("<tr>\n")
            sys.stdout.write("<th>%s</th>\n" % test)
            sys.stdout.write("</tr>\n")
    sys.stdout.write("</table></body></html>")

def main():
    parser = argparse.ArgumentParser(description='generate html file from results')
    parser.add_argument('filesystem', metavar='<filesystem name>', type=str,
                        help='filesystem which was tested')
    parser.add_argument('results', metavar='<directory with results>', type=str,
                        help='directory with results file')
    parser.add_argument('--format', metavar='<output format>', type=str,
                        help='Output format: ascii html, the default is ascii',
                        default='txt')
    args = parser.parse_args()
    results = dict()
    sections = list()

    kernel = ""

    for root, dirs, all_files in os.walk(args.results):
        for fname in all_files:
            f = os.path.join(root, fname)
            #sys.stdout.write("%s\n" % f)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            if not f.endswith('.bad'):
                continue

            # f may be results/oscheck-xfs/4.19.0-4-amd64/xfs/generic/091.out.bad
            bad_file_list = f.split("/")
            bad_file_list_len = len(bad_file_list) - 1
            bad_file = bad_file_list[bad_file_list_len]
            test_type = bad_file_list[bad_file_list_len-1]
            section = bad_file_list[bad_file_list_len-2]
            kernel = bad_file_list[bad_file_list_len-3]

            bad_file_parts = bad_file.split(".")
            bad_file_part_len = len(bad_file_parts) - 1
            bad_file_test_number = bad_file_parts[bad_file_part_len - 2]
            # This is like for example generic/091
            test_failure_line = test_type + '/' + bad_file_test_number

            test_section = results.get(section)
            if not test_section:
                results[section] = list()
                sections.append(section)
                results[section].append(test_failure_line)
            else:
                results[section].append(test_failure_line)

    if args.format == "html":
        parse_results_html(sections, results, kernel, args.filesystem)
    else:
        parse_results_ascii(sections, results, kernel, args.filesystem)

if __name__ == '__main__':
    main()
