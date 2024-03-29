#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1
#
# Generates mirror systemd service and timer files

import argparse
import yaml
import json
import sys
import pprint
import subprocess
import time
import os
from pathlib import Path

topdir = os.environ.get('TOPDIR', '.')
yaml_dir = topdir + "/playbooks/roles/linux-mirror/linux-mirror-systemd/"
default_mirrors_yaml = yaml_dir + 'mirrors.yaml'

service_template = """[Unit]
Description={short_name} mirror [{target}]
Documentation=man:git(1)
ConditionPathExists=/mirror/{target}

[Service]
Type=oneshot
ExecStartPre=/usr/bin/git -C /mirror/{target} remote update --prune
ExecStart=/usr/bin/git -C /mirror/{target} fetch --tags --prune
ExecStartPost=/usr/bin/git -C /mirror/{target} fetch origin +refs/heads/*:refs/heads/*

[Install]
WantedBy=multi-user.target
"""

timer_template = """[Unit]
Description={short_name} mirror query timer [{target}]
ConditionPathExists=/mirror/{target}

[Timer]
OnBootSec={refresh_on_boot}
OnUnitInactiveSec={refresh}

[Install]
WantedBy=default.target
"""

def main():
    parser = argparse.ArgumentParser(description='gen-mirror-files')
    parser.add_argument('--yaml-mirror', metavar='<yaml_mirror>', type=str,
                        default=default_mirrors_yaml,
                        help='The yaml mirror input file.')
    parser.add_argument('--verbose', const=True, default=False, action="store_const",
                        help='Be verbose on otput.')
    parser.add_argument('--refresh', metavar='<refresh>', type=str,
                        default='360m',
                        help='How often to update the git tree.')
    parser.add_argument('--refresh-on-boot', metavar='<refresh>', type=str,
                        default='10m',
                        help='How long to wait on boot to update the git tree.')
    args = parser.parse_args()

    if not os.path.isfile(args.yaml_mirror):
        sys.stdout.write("%s does not exist\n" % (yaml_mirror))
        sys.exit(1)

    # load the yaml input file
    with open(f'{args.yaml_mirror}') as stream:
        yaml_vars = yaml.safe_load(stream)

    if yaml_vars.get('mirrors') is None:
        raise Exception(f"Missing mirrors descriptions on %s" %
                        (args.yaml_mirror))

    if (args.verbose):
        sys.stdout.write("Yaml mirror input: %s\n\n" % args.yaml_mirror)

    total = 0
    for mirror in yaml_vars['mirrors']:
        total = total + 1

        if mirror.get('short_name') is None:
            raise Exception(f"Missing required short_name on mirror item #%d on file: %s" % (total, args.yaml_mirror))
        if mirror.get('url') is None:
            raise Exception(f"Missing required url on mirror item #%d on file: %s" % (total, args.yaml_mirror))
        if mirror.get('target') is None:
            raise Exception(f"Missing required target on mirror item #%d on file: %s" % (total, args.yaml_mirror))

        short_name = mirror['short_name']
        url = mirror['url']
        target = mirror['target']

        service_file = f"{yaml_dir}" + short_name + "-mirror" + ".service"
        timer_file = f"{yaml_dir}" + short_name + "-mirror" + ".timer"

        refresh = args.refresh
        if mirror.get('refresh'):
            refresh = mirror.get('refresh')
        refresh_on_boot = args.refresh_on_boot
        if mirror.get('refresh_on_boot'):
            refresh = mirror.get('refresh_on_boot')

        if (args.verbose):
            sys.stdout.write("Mirror #%d\n" % total)
            sys.stdout.write("\tshort_name: %s\n" % (mirror['short_name']))
            sys.stdout.write("\turl: %s\n" % (mirror['short_name']))
            sys.stdout.write("\ttarget: %s\n" % (mirror['short_name']))
            sys.stdout.write("\tservice: %s\n" % (service_file))
            sys.stdout.write("\ttimer: %s\n" % (timer_file))
            sys.stdout.write("\trefresh: %s\n" % (refresh))
            sys.stdout.write("\trefresh_on_boot: %s\n" % (refresh_on_boot))

        if os.path.exists(service_file):
            if (args.verbose):
                sys.stdout.write("\toverwrite_service: True\n")
            os.remove(service_file)
        else:
            if (args.verbose):
                sys.stdout.write("\toverwrite_service: False\n")

        output_service = open(service_file, 'w')
        context = {
            "short_name" : short_name,
            "url" : url,
            "target" : target,
        }
        output_service.write(service_template.format(**context))
        output_service.close()

        if os.path.exists(timer_file):
            if (args.verbose):
                sys.stdout.write("\toverwrite_timer: True\n")
            os.remove(timer_file)
        else:
            if (args.verbose):
                sys.stdout.write("\toverwrite_timer: False\n")

        output_timer = open(timer_file, 'w')
        context = {
            "short_name" : short_name,
            "url" : url,
            "target" : target,
            "refresh" : refresh,
            "refresh_on_boot" : refresh_on_boot,
        }
        output_timer.write(timer_template.format(**context))
        output_timer.close()

if __name__ == "__main__":
    main()
