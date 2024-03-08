#!/usr/bin/python3
#
# add_pcie_passthrough_guestfs
#
# For each kdevops guest, gets its PCIe passthrough devices on the yaml file
# and augment them on the XML file.

import yaml
import json
import sys
import pprint
import subprocess
import time
import os
from pathlib import Path

pcie_hotplug_template = """<!-- PCIE passthrough device -->
   <hostdev mode='subsystem' type='pci' managed='yes'>
      <driver name='vfio'/>
      <source>
        <address domain='0x{domain}' bus='0x{bus}' slot='0x{slot}' function='0x{function}'/>
      </source>
    </hostdev>
<!-- End of PCIE passthrough device -->
"""

def main():
    topdir = os.environ.get('TOPDIR', '.')

    # load extra_vars
    with open(f'{topdir}/extra_vars.yaml') as stream:
        extra_vars = yaml.safe_load(stream)

    yaml_nodes_file = f'{topdir}/{extra_vars["kdevops_nodes"]}'

    # slurp in the guestfs_nodes list
    with open(yaml_nodes_file) as stream:
        nodes = yaml.safe_load(stream)

    # add pcie devices
    for node in nodes['guestfs_nodes']:
        name = node['name']
        pcipassthrough = node.get('pcipassthrough')
        if not pcipassthrough:
            continue
        for dev_key_name in pcipassthrough:
            dev = pcipassthrough.get(dev_key_name)
            dev_keys = list(dev.keys())
            if 'domain' not in dev_keys or 'bus' not in dev_keys or 'slot' not in dev_keys or 'function' not in dev_keys:
                raise Exception(f"Missing pcie attributes for device %s in %s" %
                                (dev_key_name, yaml_nodes_file))
            domain = dev.get('domain')
            bus = dev.get('bus')
            slot = dev.get('slot')
            function = dev.get('function')

            pcie_xml = f"{extra_vars['guestfs_path']}/{name}/pcie_passthrough_" + dev_key_name + ".xml"

            if os.path.exists(pcie_xml):
                os.remove(pcie_xml)

            device_xml = open(pcie_xml, 'w')
            context = {
                "domain" : domain,
                "bus" : bus,
                "slot" : slot,
                "function" : function,
            }
            device_xml.write(pcie_hotplug_template.format(**context))
            device_xml.close()

if __name__ == "__main__":
    main()
