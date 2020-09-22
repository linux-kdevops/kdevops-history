#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

import argparse
import sys
import os
import re
from shutil import copyfile

def key_val(line):
    no_comment = line.split("#")[0]
    return [x.strip() for x in re.split(r"\s+", no_comment.strip(), 1)]


def remove_hosts(args):
    hosts = args.remove.split(",")

    f = open(args.ssh_config, "r")
    lines = f.read().splitlines()
    f.close()
    new_lines = list()
    rm_this_host = False
    for line in lines:
        kv = key_val(line)
        if len(kv) > 1:
            key, value = kv
            if key.lower() == "host":
                if value in hosts:
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

    f = open(args.ssh_config, "w")
    f.write("\n".join([x for x in new_lines]) + "\n")
    f.close()


def add_host(args):
    hosts = args.addhost.split(",")
    new_lines = list()
    hostnames = list()
    ports = list()
    count = 0

    if args.hostname:
        hostnames = args.hostname.split(",")

    if len(hosts) > 1 and len(hostnames) > 1:
        if len(hosts) != len(hostnames):
            sys.stdout.write("Number of shorthosts must match number of " +
                             "hostnames\n")
            sys.exit(1)

    if args.port:
        ports = args.port.split(",")

    if len(hosts) > 1 and len(ports) > 1:
        if len(hosts) != len(ports):
            sys.stdout.write("Number of shorthosts must match number of " +
                             "ports\n")
            sys.exit(1)

    for host in hosts:
        host_port = host.split(":")
        hostname = ""
        port = ""
        if len(host_port) > 1:
            host, port = host_port
        if port == "" and args.port:
            if len(ports) > 1:
                port = ports[count]
            else:
                port = args.port
        new_lines.append("Host %s\n" % (host))
        if len(hostnames) > 1:
            hostname = hostnames[count]
        elif args.hostname:
            hostname = args.hostname
        if hostname:
            new_lines.append("\tHostName %s\n" % (hostname))
        if port == "" and args.port:
            port = args.port
        if args.username:
            new_lines.append("\tUser %s\n" % (args.username))
        if port != "":
            new_lines.append("\tPort %s\n" % (port))
        if args.identity:
            new_lines.append("\tIdentityFile %s\n" % (args.identity))
        if args.addstrict:
            new_lines.append("\tUserKnownHostsFile /dev/null\n")
            new_lines.append("\tStrictHostKeyChecking no\n")
            new_lines.append("\tPasswordAuthentication no\n")
            new_lines.append("\tIdentitiesOnly yes\n")
            new_lines.append("\tLogLevel FATAL\n")
        count = count + 1

    f = open(args.ssh_config, "a")
    f.write("".join([x for x in new_lines]))
    f.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('ssh_config', help='ssh configuration file to process')
    parser.add_argument('--addhost',
                        help='The host shortcut name you are adding. This ' +
                        'can be a comma separated set of hosts and each host ' +
                        'can have a port specified with a colon, if set it ' +
                        'will override override the port set by --port. This ' +
                        'will let you set a default port if non specified ' +
                        'but allow you to override ports per host. We refer ' +
                        'this entry as the shorthost.')
    parser.add_argument('--hostname',
                        help='Used only on addition, the hostname to use for ' +
                        'this entry. If the shorhost specified was a comma ' +
                        'separated list of hosts, then this can also be a ' +
                        'comma separated list, in which case each shorthost ' +
                        'index represents the hostname for that shorthost, ' +
                        'and the number of both shorthosts and hostname must ' +
                        'match.')
    parser.add_argument('--port',
                        help='Used only on addition, the port to use, ' +
                        'by default none is specified')
    parser.add_argument('--username',
                        help='Used only on addition, the username to use, ' +
                        'default is none, so ssh will assumes your localhost ' +
                        'username')
    parser.add_argument('--identity',
                        help='Used only on addition, the host key to ' +
                        'use, the default is empty and so no file is provided')
    parser.add_argument('--addstrict',
                        const=True, default=False, action="store_const",
                        help='Used only on addition, if set some extra ' +
                        'sensible strict defaults will be added to the host ' +
                        'entry, disabled by default')
    parser.add_argument('--remove',
                        help='Comma separated list of host entries to remove')
    parser.add_argument('--backup_file',
                        help='Use this file as the backup')
    parser.add_argument('--nobackup',
                        const=True, default=False, action="store_const",
                        help='Do not use a backup file')
    args = parser.parse_args()

    if not args.remove and not args.addhost:
        print("Must specify addition or removal request")
        sys.exit(0)

    if not os.path.isfile(args.ssh_config):
        sys.exit(0)

    backup_file = args.ssh_config + '.kdevops.bk'
    if args.backup_file:
        backup_file = args.backup_file
    if args.nobackup:
        backup_file = None

    if backup_file:
        copyfile(args.ssh_config, backup_file)

    if args.remove:
        remove_hosts(args)

    if args.addhost:
        add_host(args)


if __name__ == "__main__":
    main()
