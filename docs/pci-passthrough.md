# PCI passthrough configuration

Currently this is a bit of a manual process to set up.  To get this to work
unprivileged you must modify permissions of some sysfs files so that
vagrant/libvirt will work properly.  You also must make sure the vfio devices
are accessible by the libvirt group.  Scripts are provided to do all the work
for you, but you must determine the PCI ID's of the devices you want to
passthrough.  The following is an example

```bash
$ lspci -D
0000:2d:00.0 Non-Volatile memory controller: Western Digital Ultrastar DC ZN540 ZNS NVMe SSD
0000:2e:00.0 Non-Volatile memory controller: Western Digital Ultrastar DC ZN540 ZNS NVMe SSD

$ ./scripts/vfio-permissions.sh 0000:2d:00.0 0000:2e:00.0
```

This installs a config into `limits.d` and a udev rule into `udev.d`.  Sometimes
the limit doesn't take effect until a reboot depending on your system, so you
may need to run the above script once, reboot, and then run it again.

Then you must configure the device in your `kdevops_nodes.yaml` file.  Using the
above example, you would have a `pcipassthrough` option with the configuration
for your given device

```yaml
vagrant_boxes:
  - name: kdevops-btrfs-zns
    ip: 172.17.8.101
    pcipassthrough:
      zns1:
        domain: 0x0000
        bus: 0x2d
        slot: 0x00
        function: 0x0
```

From here you will be able to run `make bringup` and the pci passthrough will
work.

Keep in mind this script needs to be run in order to give you the correct
permissions to start up the VM's with the device passed through, so you need to
run this script any time you reboot.

This only works for libvirt currently, virtualbox isn't supported yet.
