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
sys_bus_prefix = "/sys/bus/pci/devices/"

debug = 0

def get_first_dir(path):
    if len(os.listdir(path)) > 0:
        return os.listdir(path)[0]
    return None

def get_sysname(sys_path, entry):
    sys_entry_path = sys_path + entry
    if not os.path.isfile(sys_entry_path):
        return None
    entry_fd = open(sys_entry_path, 'r')
    line = entry_fd.readlines()[0]
    line = line.strip()
    entry_fd.close()
    return line

# kconfig does not like some characters
def strip_kconfig_name(name):
    fixed_name = name.replace("\"", "")
    fixed_name = fixed_name.replace("'", "")
    return fixed_name

def get_special_device_nvme(pci_id):
    pci_id_name = strip_kconfig_name(pci_id)
    sys_path = sys_bus_prefix + pci_id + "/nvme/"
    if not os.path.isdir(sys_path):
        return None
    block_device_name = get_first_dir(sys_path)
    if not block_device_name:
        return None
    block_sys_path = sys_path + block_device_name + "/"
    model = get_sysname(block_sys_path, "model")
    if not model:
        return None
    fw = get_sysname(block_sys_path, "firmware_rev")
    if not fw:
        return None
    return pci_id_name + " - /dev/" + block_device_name + " - " + model + " with FW %s" % fw


def get_kconfig_device_name(pci_id, sdevice):
    default_name = pci_id + " - " + sdevice
    special_name = None
    if os.path.isdir(sys_bus_prefix + pci_id + "/nvme"):
        special_name = get_special_device_nvme(pci_id)
    if not special_name:
        return strip_kconfig_name(default_name)
    return strip_kconfig_name(special_name)

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

def add_pcie_kconfig_entry(pci_id, sdevice, domain, bus, slot, function, config_id):
    prefix = passthrough_prefix + "_%04d" % config_id
    name = get_kconfig_device_name(pci_id, sdevice.strip())
    add_pcie_kconfig_name(prefix, name)
    add_pcie_kconfig_string(prefix, domain, "domain")
    add_pcie_kconfig_string(prefix, bus, "bus")
    add_pcie_kconfig_string(prefix, slot, "slot")
    add_pcie_kconfig_string(prefix, function, "function")

def add_new_device(slot, sdevice, possible_id):
    slot = slot.strip()
    # Example expeced format 0000:2d:00.0
    m = re.match(r"^(?P<DOMAIN>\w+):"
                  "(?P<BUS>\w+):"
                  "(?P<MSLOT>\w+)\."
                  "(?P<FUNCTION>\w+)$", slot)
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
        sys.stdout.write("\tslot: %s\n" % (slot))
        sys.stdout.write("\tdomain: %s\n" % (domain))
        sys.stdout.write("\tbus: %s\n" % (bus))
        sys.stdout.write("\tslot: %s\n" % (mslot))
        sys.stdout.write("\tfunction: %s\n" % (function))

    if possible_id == 1:
        sys.stdout.write("# Automatically generated PCI-E passthrough Kconfig by kdevops\n\n")

    add_pcie_kconfig_entry(slot, sdevice, domain, bus, mslot, function, possible_id)

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
