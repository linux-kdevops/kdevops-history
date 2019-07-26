#!/usr/bin/env python

import argparse
import sys
import os
import re
from shutil import copyfile

def key_val(line):
    no_comment = line.split("#")[0]
    return [x.strip() for x in re.split(r"\s+", no_comment.strip(), 1)]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('ssh_config', help='ssh configuration file to process')
    parser.add_argument('--remove',
                        help='Comma separated list of host entries to remove')
    parser.add_argument('--backup_file',
                        help='Use this file as the backup')
    parser.add_argument('--nobackup',
                        const=True, default=False, action="store_const",
                        help='Do not use a backup file')
    args = parser.parse_args()

    if not args.remove:
        print "Must specify comma separated list of hosts to remove"
        sys.exit(0)

    if not os.path.isfile(args.ssh_config):
        sys.exit(0)

    backup_file = args.ssh_config + '.kdevops.bk'
    if args.backup_file:
        backup_file = args.backup_file
    if args.nobackup:
        backup_file = None

    remove_hosts = args.remove.split(",")

    f = open(args.ssh_config, "r")
    lines = f.read().splitlines()
    f.close()
    new_lines = list()
    file_modified = False
    rm_this_host = False
    for line in lines:
        kv = key_val(line)
        if len(kv) > 1:
          key, value = kv
          if key.lower() == "host":
              if value in remove_hosts:
                  file_modified = True
                  rm_this_host = True
                  continue
              else:
                  rm_this_host = False
                  new_lines.append(line)
          else:
              if not rm_this_host:
                  new_lines.append(line)
        else:
          new_lines.append(line)

    if not file_modified:
        sys.exit(0)

    if backup_file:
        copyfile(args.ssh_config, backup_file)

    f = open(args.ssh_config, "w")
    f.write("\n".join([x for x in new_lines]) + "\n")
    f.close()

if __name__ == "__main__":
    main()
