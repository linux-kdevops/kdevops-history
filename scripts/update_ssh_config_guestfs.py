#!/usr/bin/python3
#
# update_ssh_config_guestfs
#
# For each kdevops guest, determine the IP address and write a ssh_config
# entry for it to ~/.ssh/config_kdevops_$prefix. Users can then just add a
# line like this to ~/.ssh/config:
#
# Include ~/.ssh/config_kdevops_*
#

import yaml
import json
import sys
import pprint
import subprocess
import time
import os
from pathlib import Path

ssh_template = """Host {name} {addr}
	HostName {addr}
	User kdevops
	Port 22
	IdentityFile {sshkey}
	UserKnownHostsFile /dev/null
	StrictHostKeyChecking no
	PasswordAuthentication no
	IdentitiesOnly yes
	LogLevel FATAL
"""

# We take the first IPv4 address on the first non-loopback interface.
def get_addr(name):
    attempt = 0
    while True:
        attempt += 1
        if attempt > 60:
            raise Exception(f"Unable to get an address for {name} after 60s")

        result = subprocess.run(['/usr/bin/virsh','qemu-agent-command',name,'{"execute":"guest-network-get-interfaces"}'], capture_output=True)
        # Did it error out? Sleep and try again.
        if result.returncode != 0:
            time.sleep(1)
            continue

        # slurp the output into a dict
        netinfo = json.loads(result.stdout)

        ret = None
        for iface in netinfo['return']:
            if iface['name'] == 'lo':
                continue
            if 'ip-addresses' not in iface:
                continue
            for addr in iface['ip-addresses']:
                if addr['ip-address-type'] != 'ipv4':
                    continue
                ret = addr['ip-address']
                break

        # If we didn't get an address, try again
        if ret:
            return ret
        time.sleep(1)

def main():
    topdir = os.environ.get('TOPDIR', '.')

    # load extra_vars
    with open(f'{topdir}/extra_vars.yaml') as stream:
        extra_vars = yaml.safe_load(stream)

    # slurp in the guestfs_nodes list
    with open(f'{topdir}/{extra_vars["kdevops_nodes"]}') as stream:
        nodes = yaml.safe_load(stream)

    ssh_config = f'{Path.home()}/.ssh/config_kdevops_{extra_vars["kdevops_host_prefix"]}'

    # make a stanza for each node
    sshconf = open(ssh_config, 'w')
    for node in nodes['guestfs_nodes']:
        name = node['name']
        addr = get_addr(name)
        context = {
            "name" : name,
            "addr" : addr,
            "sshkey" : f"{extra_vars['guestfs_path']}/{name}/ssh/id_ed25519"
        }
        sshconf.write(ssh_template.format(**context))
    sshconf.close()

if __name__ == "__main__":
    main()
