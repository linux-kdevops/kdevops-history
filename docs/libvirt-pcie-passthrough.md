# PCIe passthrough configuration

One of the newest features in kdevops is to support PCIe passthrough support
using dynamic Kconfig. A dynamic set of Kconfig files are required to be
built in order to allow you to pick / choose which devices you want to
passthrough onto a guest.

Not everyone wants kdevops to be scraping your systems' lspci output and
generating Kconfig files based on that for you, and so this falls into a new
type of feature which kdevops needs to support, and which requires explicit
user consent for it to be enabled.

Support for features which require dynamic Kconfig support are supported
through a new kdevops configuration, instead of running:

```bash
make menuconfig
```

If you want to be *able* to *enable* PCIe passthrough support as a feature
when configuring how kdevops uses libvirt, you must now run:

```bash
make dynconfig
```

The idea behind this is that we expect *more* features in kdevops which may
requires more dynamic Kconfig content, and we must simply be mindful, that
not everyone wants these features.

## Enable kdevops PCIe passthrough support

PCIe passthrough support is currently only available when you select to
use vagrant with libvirt. The respective Kconfig option is
`CONFIG_KDEVOPS_LIBVIRT_PCIE_PASSTHROUGH`.

If you enable that you then get to pick what technique you wish to use to
passthrough devices onto the guest. This is simply a matter of helping
you with your user experience with the configuration of this feature.

```
  (X) Onto the first guest
  ( ) Onto a specific host name you'll specify
  ( ) Per device specific host
```

You will see 3 options. The options are pretty self intuitive, however
each Kconfig has its own description you can use the question mark to get
help on the configuration to read more about it. We'll just explain the
most complex setup, the last option "Per device specific host". That
just allows you to pick a different guests you may want to passthrough
each and every single PCIe device you have onto an arbitrary guest
which kdevops is bringing up. So for example I may want to passthrough
a CXL device a guest I want to do CXL hacking on, but I may want to
instead passthrough a ZNS device onto some other guest I am doing block
storage hacking or filesystem hacking on for zone storage.

## IOMMU group

You may run into issues with passing through a device onto a guest,
if the complaint is about the IOMMU group, you very likely just need
to passthrough *all* devices on that IOMMU group to the guest if you
want to passthrough that single device. This is why the Kconfig options
which are generated include the IOMMU group number for your convenience.

## The code which generates the dynamic PCIe Kconfig

Go read [gen-dynamic-pci.py](playbooks/python/workflows/dynamic-kconfig/gen-dynamic-pci.py).
In a gist, it reads `lspci -Dvmmm` output and then generates some Kconfig data
for us for kdevops.

## Special names

Often times though the output from `lspci -Dvmmm` sucks to inform any user
or even developer where the heck that device is with regards to the human
visible experience on the system. So for example a system may have 10 NVMe
drives, all with the same model, but a few of them may already be used by
the host or another guest. So it is is not easy to tell which one is available.
To help with this kdevops supports adding *further* human readable information
onto the Kconfig entry so to enable users to make more informed decisions about
which device to passthrough. For example the corresponding NVMe device name
under `/dev/nvme0n` will be very useful if the device is an NVMe drive, and so
there is a helper for this. So `get_kconfig_device_name()` calls
`get_special_device_nvme()` for NVMe drives.

If you have another special device you can expand on this to help users.

## Testing

This has been tested on a high end server, latop and desktop.
This is however a very new feature so please report bugs.

## Manual PCIe passthrough instructions

These instructions are kept here for those who like to suffer or just want
to review how this is done generically with kdevops. You don't need to read
this if you are using `make dynconfig`.

To get this to work you must modify permissions of some sysfs files so that
vagrant/libvirt will work properly.  You also must make sure the vfio devices
are accessible by the libvirt group.  Scripts are provided to do all the work
for you, but you must determine the PCIe ID's of the devices you want to
passthrough.  The following is an example

```bash
$ lspci -D
0000:2d:00.0 Non-Volatile memory controller: Western Digital Ultrastar DC ZN540 ZNS NVMe SSD
0000:2e:00.0 Non-Volatile memory controller: Western Digital Ultrastar DC ZN540 ZNS NVMe SSD

$ ./scripts/vfio-permissions.sh 0000:2d:00.0 0000:2e:00.0
```

This installs a config into `limits.d` and a udev rule into `udev.d`. Sometimes
the limit doesn't take effect until a reboot depending on your system, so you
may need to run the above script once, reboot, and then run it again.

Then you must configure the device in your `kdevops_nodes.yaml` file. Using the
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

From here you will be able to run `make bringup` and the PCIe passthrough will
work.

Keep in mind this script needs to be run in order to give you the correct
permissions to start up the VM's with the device passed through, so you need to
run this script any time you reboot.

This only works for libvirt currently, VirtualBox isn't supported yet.
