#!/usr/bin/env python3

import argparse
import os

def qemu_print(kind, value, last=False):
    global args
    if args.format == 'xml':
        print('<qemu:arg value=\'%s\'/>' % kind)
        print('<qemu:arg value=\'%s\'/>' % value)
    else:
        print('%s %s %s' % (kind, value, '' if last else '\\'))

def host_bridge(hb_id, bus, addr):
    return 'pxb-cxl,bus=pcie.0,id=cxl.%d,bus_nr=0x%x,addr=0x%x' % (hb_id, bus, addr)

def root_port(rp_id, hb_id, port, slot):
    return 'cxl-rp,port=%d,bus=cxl.%d,id=cxl_rp%d,chassis=0,slot=%d' % (port, hb_id, rp_id, slot)

def switch(rp_id):
    return 'cxl-upstream,bus=cxl_rp%d,id=cxl_switch%d,addr=0.0,multifunction=on' % (rp_id, rp_id)

def mailbox(rp_id):
    return 'cxl-switch-mailbox-cci,bus=cxl_rp%d,addr=0.1,target=cxl_switch%d' % (rp_id, rp_id)

def downstream_port(dport_id, dport, rp_id, slot):
    return 'cxl-downstream,port=%d,bus=cxl_switch%d,id=cxl_dport%d,chassis=0,slot=%d' % (dport, rp_id, dport_id, slot)

def memdev(dport_id, path, sizestr, sizeval, create):
    filename = '%s/cxl_mem%d.raw' % (path, dport_id)
    if not(os.path.exists(filename)) and create:
        if not(os.path.exists(path)):
            print('ERROR: Tried to create memdev file but directory %s does not exist.' % path)
            exit(1)
        os.umask(0)
        with open(filename, 'wb') as file:
            file.truncate(sizeval)
    return 'memory-backend-file,id=cxl_memdev%d,share=on,mem-path=%s,size=%s' % (dport_id, filename, sizestr)

def lsa(path, create):
    filename = '%s/cxl_lsa.raw' % path
    if not(os.path.exists(filename)) and create:
        if not(os.path.exists(path)):
            print('ERROR: Tried to create lsa file but directory %s does not exist.' % path)
            exit(1)
        os.umask(0)
        with open(filename, 'wb') as file:
            file.truncate(256 * 1024 * 1024)
    return 'memory-backend-file,id=cxl_lsa,share=on,mem-path=%s,size=256M' % filename


def type3(dport_id):
    return 'cxl-type3,bus=cxl_dport%d,memdev=cxl_memdev%d,lsa=cxl_lsa,id=cxl_mem%d' % (dport_id, dport_id, dport_id)

def fmw(num_hb):
    s = ''
    for hb in range(num_hb):
        s += 'cxl-fmw.0.targets.%d=cxl.%d,' % (hb, hb)
    return s + 'cxl-fmw.0.size=8G,cxl-fmw.0.interleave-granularity=256'

parser = argparse.ArgumentParser(description='QEMU CXL configuration generator', usage='%(prog)s [options]')
parser.add_argument('-m', '--memdev-path', dest='memdev_path',
                    help='Path to location of backing memdev files', required=True)
parser.add_argument('-s', '--size', dest='size',
                    help='Size of each memory device in bytes (i.e. 512M, 16G)', required=True)
parser.add_argument('-c', '--create-memdev-files', dest='create_memdevs',
                    help='Create memdev file if not found', action='store_true', default=False)
parser.add_argument('-f', '--format', dest='format',
                    help='Format of QEMU args',
                    default='cmdline', choices=['cmdline', 'xml'])
parser.add_argument('-b', '--host-bridges', dest='num_hb',
                    help='Number of host bridges',
                    type=int, default=1, choices=range(1,5))
parser.add_argument('-r', '--root-ports', dest='num_rp',
                    help='Number of root ports per host bridge',
                    type=int, default=1, choices=range(1,5))
parser.add_argument('-d', '--downstream-ports', dest='num_dport',
                    help='Number of downstream ports per switch',
                    type=int, default=1, choices=range(1,9))
parser.add_argument('-p', '--pci-bus-number', dest='bus_nr',
                    help='PCI bus number for first host bridge (default: 0x38)',
                    type=int, default=0x38)
parser.add_argument('--bus-alloc-per-host-bridge', dest='bus_per',
                    help='Number of PCI buses to allocate per host bridge (default: 16)',
                    type=int, default=16)
parser.add_argument('--pci-function-number', dest='func_nr',
                    help='Starting PCI function number for host bridges on root PCI bus 0 (default: 9)',
                    type=int, default=9)

args = parser.parse_args()

suffix_dict = {'M': 1024 ** 2, 'G': 1024 ** 3}
suffix = args.size[-1].upper()
if not(suffix in suffix_dict):
    print('ERROR: size must end in M (for MiB) or G (for GiB)')
    exit(1)
size = int(args.size[:-1]) * suffix_dict[suffix]

slot = 0
qemu_print('-machine', 'cxl=on')
qemu_print('-object', lsa(args.memdev_path, args.create_memdevs))
for hb in range(args.num_hb):
    qemu_print('-device', host_bridge(hb, args.bus_nr + hb * args.bus_per, hb + args.func_nr))
    for rp in range(args.num_rp):
        rp_id = hb * args.num_rp + rp
        qemu_print('-device', root_port(rp_id, hb, rp, slot))
        slot += 1
        qemu_print('-device', switch(rp_id))
        qemu_print('-device', mailbox(rp_id))
        for dport in range(args.num_dport):
            dport_id = rp_id * args.num_dport + dport;
            qemu_print('-device', downstream_port(dport_id, dport, rp_id, slot))
            slot += 1
            qemu_print('-object', memdev(dport_id, args.memdev_path, args.size, size, args.create_memdevs))
            qemu_print('-device', type3(dport_id))
qemu_print('-M', fmw(args.num_hb), last=True)
