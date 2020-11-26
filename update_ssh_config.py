#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

import argparse
import sys
import os
import re
import subprocess
from shutil import copyfile


class VagrantError(Exception):
    pass


class ExecutionError(VagrantError):
    def __init__(self, errcode):
        self.error_code = errcode


def _check(process):
    if process.returncode != 0:
        raise ExecutionError(process.returncode)


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


def add_vagrant_hosts(args):
    lines = None
    if args.emulatevagrantinput:
        f = open(args.emulatevagrantinput, "r")
        lines = f.read().splitlines()
        f.close()
    else:
        process = subprocess.Popen(['vagrant', 'ssh-config'],
                                   stdout=subprocess.PIPE,
                                   close_fds=True, universal_newlines=True)
        stdout = process.communicate()[0]
        process.wait()
        _check(process)
        lines = stdout.splitlines()

    addhost = ""
    hostname = ""
    username = ""
    port = ""
    identity = ""
    kexalgorithms = None

    # All vagrant hosts are strict, which allows us to skip checking all of
    # the parameters which define this.
    addstrict = True

    last_host_added = ""
    newhost = None

    if args.kexalgorithms and args.kexalgorithms is not None:
        kexalgorithms = args.kexalgorithms

    for line in lines:
        if not line:
            continue
        kv = key_val(line)
        if len(kv) > 1:
            key, value = kv
            if key.lower() == "host":
                if addhost != "":
                    newhost = SshHost(args.ssh_config, addhost, hostname,
                                      username, port, identity, addstrict,
                                      kexalgorithms)
                    newhost.call_add_host()
                    last_host_added = addhost
                addhost = value
                hostname = ""
                username = ""
                port = ""
                identity = ""
                addstrict = True
            if key.lower() == "hostname":
                hostname = value
            elif key.lower() == "user":
                username = value
            elif key.lower() == "port":
                port = value
            elif key.lower() == "identityfile":
                identity = value

    if last_host_added != addhost:
        newhost = SshHost(args.ssh_config, addhost, hostname, username, port,
                          identity, addstrict, kexalgorithms)
        newhost.call_add_host()


# We extend the SshHost with the variables which we add to our ArgumentParser
# and which we use on this function so that we can pass to this function either
# an ArgumentParser object or one of our SshHost objects
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
        if len(hostnames) > 1:
            hostname = hostnames[count]
        elif args.hostname:
            hostname = args.hostname
        if hostname:
            new_lines.append("Host %s %s\n" % (host, hostname))
            new_lines.append("\tHostName %s\n" % (hostname))
        else:
            new_lines.append("Host %s\n" % (host))
        if port == "" and args.port:
            port = args.port
        if args.username:
            new_lines.append("\tUser %s\n" % (args.username))
        if port != "":
            new_lines.append("\tPort %s\n" % (port))
        if args.identity:
            new_lines.append("\tIdentityFile %s\n" % (args.identity))
        if args.kexalgorithms and args.kexalgorithms is not None:
            new_lines.append("\tKexAlgorithms %s\n" % (args.kexalgorithms))
        if args.addstrict:
            new_lines.append("\tUserKnownHostsFile /dev/null\n")
            new_lines.append("\tStrictHostKeyChecking no\n")
            new_lines.append("\tPasswordAuthentication no\n")
            new_lines.append("\tIdentitiesOnly yes\n")
            new_lines.append("\tLogLevel FATAL\n")
        count = count + 1

    with open(args.ssh_config, 'r') as original: data = original.read()
    new_data = "".join([x for x in new_lines])
    with open(args.ssh_config, 'w') as modified: modified.write(new_data + data)

class SshHost:
    def __init__(self, ssh_config, name, hostname, username, port, identity,
                 strict, kexalgorithms):
        self.ssh_config = ssh_config
        self.addhost = name
        self.hostname = hostname
        self.username = username
        self.port = port
        self.identity = identity
        self.addstrict = strict
        self.kexalgorithms = kexalgorithms

    def call_add_host(self):
        add_host(self)

    def call_remove_hosts(self):
        remove_hosts(self)


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument('ssh_config', help='ssh configuration file to process')
    parser.add_argument('--addhost',
                        help='The host shortcut name you are adding. This ' +
                        'can be a comma separated set of hosts and each host' +
                        'can have a port specified with a colon, if set ' +
                        'it will override override the port set by --port. ' +
                        'will let you set a default port if non specified ' +
                        'but allow you to override ports per host. We refer ' +
                        'this entry as the shorthost.')
    parser.add_argument('--addvagranthosts',
                        const=True, default=False, action="store_const",
                        help='Use this if you are want to add or augment ' +
                        'the entries found from the output of the command ' +
                        'vagrant ssh-config. You would typically use this ' +
                        'if you are working with vagrant, and are in the ' +
                        'vagrant directory. Only a few parameters are ' +
                        'supported when augmenting the information ' +
                        'installed per host, those are entries which ' +
                        'vagrant does not add which you may need, for ' +
                        'instance on older hosts')
    parser.add_argument('--emulatevagrantinput',
                        help='Used for testing purposes only,' +
                        'where we do not want to run vagrant ssh-config.' +
                        'The parameter passed is an input file which ' +
                        'emulates the command')
    parser.add_argument('--hostname',
                        help='Used only on addition, the hostname to use ' +
                        'for this entry. If the shorhost specified was a ' +
                        'comma separated list of hosts, then this can also ' +
                        'be a comma separated list, in which case each ' +
                        'shorthost index represents the hostname for that ' +
                        'shorthost, and the number of both shorthosts and ' +
                        'hostname must match.')
    parser.add_argument('--port',
                        help='Used only on addition, the port to use, ' +
                        'by default none is specified')
    parser.add_argument('--username',
                        help='Used only on addition, the username to use, ' +
                        'default is none, so ssh will assumes your ' +
                        'localhost username')
    parser.add_argument('--identity',
                        help='Used only on addition, the host key to ' +
                        'use, the default is empty and so no file is provided')
    parser.add_argument('--kexalgorithms',
                        help='Use this if you have a custom KexAlgorithms ' +
                        'entry you want to add for the host entries. ' +
                        'This is typically useful for older hosts.')
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
    return parser.parse_args(args)


def run_args(args):
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

    if args.addvagranthosts:
        add_vagrant_hosts(args)
    elif args.addhost:
        add_host(args)


def main():
    args = parse_args(sys.argv[1:])
    run_args(args)


if __name__ == "__main__":
    main()
