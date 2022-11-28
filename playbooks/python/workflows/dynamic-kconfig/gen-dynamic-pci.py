#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# Takes as input the output of $(lspci -Dvmmm) and then creates a kconfig
# file you can use. One use case is pci-passthrough.

import argparse
import os
import sys
import re

dynpci_kconfig_ansible_python_dir = os.path.dirname(os.path.abspath(__file__))
passthrough_prefix = "KDEVOPS_DYNAMIC_PCIE_PASSTHROUGH"

debug = 0

def add_pcie_kconfig_string(prefix, val, name):
    config_name = prefix + "_" + name.upper()
    sys.stdout.write("config %s\n" % (config_name))
    sys.stdout.write("\tstring\n")
    sys.stdout.write("\tdefault \"%s\"\n" % (val))
    sys.stdout.write("\n")

def add_pcie_kconfig_name(config_name, sdevice):
    sys.stdout.write("config %s\n" % (config_name))
    sys.stdout.write("\tbool \"%s\"\n" % (sdevice))
    sys.stdout.write("\tdefault n\n")
    sys.stdout.write("\thelp\n")
    sys.stdout.write("\t  Enabling this will PCI-E passthrough this device onto the\n")
    sys.stdout.write("\t  target guest.\n")
    sys.stdout.write("\n")

def add_pcie_kconfig_entry(sdevice, domain, bus, slot, function, config_id):
    prefix = passthrough_prefix + "_%04d" % config_id
    add_pcie_kconfig_name(prefix, sdevice)
    add_pcie_kconfig_string(prefix, domain, "domain")
    add_pcie_kconfig_string(prefix, bus, "bus")
    add_pcie_kconfig_string(prefix, slot, "slot")
    add_pcie_kconfig_string(prefix, function, "function")

def add_new_device(slot, sdevice, possible_id):
    line = slot.strip()
    # Example expeced format 0000:2d:00.0
    m = re.match(r"^(?P<DOMAIN>\w+):"
                  "(?P<BUS>\w+):"
                  "(?P<MSLOT>\w+)\."
                  "(?P<FUNCTION>\w+)$", line)
    if not m:
        return possible_id

    possible_id += 1

    slot_dict = m.groupdict()
    domain = "0x" + slot_dict['DOMAIN']
    bus = "0x" + slot_dict['BUS']
    mslot = "0x" + slot_dict['MSLOT']
    function = "0x" + slot_dict['FUNCTION']

    sdevice = sdevice.strip()

    if debug:
        sys.stdout.write("\tdomain: %s\n" % (domain))
        sys.stdout.write("\tbus: %s\n" % (bus))
        sys.stdout.write("\tslot: %s\n" % (mslot))
        sys.stdout.write("\tfunction: %s\n" % (function))

    if possible_id == 1:
        sys.stdout.write("# Automatically generated PCI-E passthrough Kconfig by kdevops\n\n")

    add_pcie_kconfig_entry(sdevice, domain, bus, mslot, function, possible_id)

    return possible_id

def main():
    num_candidate_devices = 0
    parser = argparse.ArgumentParser(description='Creates a Kconfig file lspci output')
    parser.add_argument('input', metavar='<input file with lspci -Dvmmm output>', type=str,
                        help='input file wth lspci -Dvmmm output')
    args = parser.parse_args()

    lspci_output = args.input

    if not os.path.isfile(lspci_output):
        sys.stdout.write("input file did not exist: %s\n" % (lspci_output))
        sys.exit(1)

    lspci = open(lspci_output, 'r')
    all_lines = lspci.readlines()
    lspci.close()

    slot = -1
    sdevice = None

    for line in all_lines:
        line = line.strip()
        m = re.match(r"^(?P<TAG>\w+):"
                      "(?P<STRING>.*)$", line)
        if not m:
            continue
        eval_line = m.groupdict()
        tag = eval_line['TAG']
        data = eval_line['STRING']
        if tag == "Slot":
            if sdevice:
                num_candidate_devices = add_new_device(slot, sdevice, num_candidate_devices)
            slot = data
            sdevice = None
        elif tag == "SDevice":
            sdevice = data

    add_pcie_kconfig_string(passthrough_prefix, num_candidate_devices, "NUM_DEVICES")
    os.unlink(lspci_output)


if __name__ == '__main__':
    main()
