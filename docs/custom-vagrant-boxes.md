# Creating your own custom vagrant boxes or qcow2 virtual images

You can create your own custom vagrant boxes if the publicly available
vagrant boxes do not suit your needs. We document how to do this here.
One reason might be you are an Enterprise Linux distribution and don't
have public vagrant boxes for older releases you might still support
but want the benefit of having vagrant boxes to work with kdevops
kernel-ci. Another reason might be you just cannot legally share you
images, for one reason or another.

First you'd install a guest using virt-install, an example script which
you can extend to your own needs is the
[virt-install-demo.sh](docs/virt-install-demo.sh).
There are a a series of adjustments that needed to be made for guests
to work for older kernel releases, should you need that. This is all
documented below.

## Extending the vagrant box definition

A vagrant box is essentially a tarball (gzip, xc are both supported) with a
qcow2 image and a small metadata file explaining how large the drive for the
guest is.  The vagrant box also ensures that the guest brought up will also
work on any new system, and so a few things need to be done to ensure for
instance that the network interface will get a DHCP address successfully, and
that you can ssh into the system. So a way to deal with moving guests around
the `cloud` are needed, an example is avoiding
`/etc/udev/rules.d/70-persistent-net.rules` upon first boot on some SLE
systems.

Standard userspace development needs are typically met with the above
requirements. Kernel development however, have more more needs. Extensions
can be made by you so that the custom vagrant boxes you build extend
what is promised by a vagrant box, with other things which kernel developers
would typically prefer to have set on the system. This can save time
on bringup. Kdevops does a slew of things to help with this for you, like
setting up the serial console, but if vagrant boxes already have these things
done on them that is a step which could be skipped.

Below we provide a recipe of items which can be done to help on a fresh install
of a Linux distribution on a qcow2 image so that it is easier to test new
kernels and debug them. The standard vagrant box definition *only* requires a
guest to come up, and to be able to ssh into them with the vagrant user.

  * 1) root/vagrant user password is vagrant
  * 2) vagrant user on /etc/sudeors does not need a password to gain root
  * 3) vagrant user has an insecure ssh key installed to enable adding a new random one
  * 4) Disable the firewall and apparmor
  * 5) Deal with persistent net rules
  * 6) Ensure DHCP will work on the first network interface
  * 7) Ensure the console is allowed
  * 8) Ensure the correct disk size is used on the metadata json file
  * 9) Try to use disk partitions by UUID on /etc/fstab
  * 10) grub disk setup with UUID
  * 11) grub console setup
  * 12) address lack of virtio
  * 13) address changes in sudo for old systems

These all deserve their own attention so a section is provided for them below.

### root / vagrant password

Although no password is needed, just to ensure one is set the `vagrant` password
is set, just in case you need to use it.

### vagrant sudoers

The goal is to never have to use root directly since the boxes are for development
purposes, and so the following entry is expected:

```
vagrant ALL=(ALL) NOPASSWD: ALL
```

### vagrant user has an insecure ssh key installed

vagrant publishes an arbitrary public static ssh public and private key, so
that if it is detected a random ssh key is instead generated and used and
installed.

Using a random ssh key for each host is a better idea due to possible
risks of guests being left `spawned` and then `pawned` by motivated eager
beavers for a key the entire internet has access to.

You can surely use your own key as well, however, when sharing vagrant boxes
you likely don't want to be sharing ssh keys.

### Disable the firewall and apparmor

You are not trying to secure a bank when running a guest for
kernel development, so running a firewall and apparmor is just
typically noise. This is unless of course if you are testing apparmor
or firewall changes to the kernel.

The firewall and apparmor can be enabled after initialization, however,
if you really need it.

### Deal with persistent net rules

Each Linux distribution has dealt with a way to keep MAC addresses mapped
to a specific interface name. This is to allow a network card to always get
the same IP address, in case it changes the bus it uses on a system.

Spawning a guest from a vagrant box means we *want* a different MAC
address for each new guest. This also means we want the first interface
to take the first possible interface name, which will be used for DHCP
purposes after bootup.

### Ensure DHCP will work on the first network interface

We expect at least one ethernet interface to come up so that it can get an IP
address and so that we can then ssh into it. Using a network interface just to
communicate to guests is rather archaic, however, it is the current norm.

A vagrant box *expects* a random interface to be spawned with it, and we
want to just ensure it, whatever it is, will ask for an IP address via
DHCP. We want to use a mechanism that will work, if possible, for older
systems as well.

The following recipe works from SLES12-SP3 down to SLES10-SP3 as
an example:

```bash
if [ -d ] /etc/sysconfig ]; then
	cat << FIXIFCGHETH0 > /etc/sysconfig/network/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
STARTMODE='auto'

FIXIFCGHETH0
```

### Ensure the correct disk size is used on the metadata json file

Vagrant boxes have a metadata json file. If you create a qcow2 image
as follows:

```
qemu-img create -f qcow2  foo.qcow2 50G
```

Then ensure you have 50 as your size for your metadata.json file:

```
{
  "provider"     : "libvirt",
  "format"       : "qcow2",
  "virtual_size" : 50
}
```

Note that the vagrant libvirt provider does not seem to provide support
yet for versioning.

### Try to use disk partitions by UUID on /etc/fstab

Some releases do not use /dev/disk/by-uuid labels on /etc/fstab. This
poses a risk when trying to move a guest qcow2 image file from one
system to another. We want something static, and the UUID assigned to
partitions addresses this problem.

This however means that if you are creating your own custom vagrant
box or installing your own new fresh kernel you may have to take steps
to ensure the UUID is used instead of the raw /dev/vda or alternative
device disk name.

### grub disk setup with UUID

As an example, grub 0.97 is used on SLE10-SP3, SLE11-SP1, and SLE11-SP4. On
these releases you must ensure that the same /dev/disk/by-uuid is used so that
that a vagrant box can function on new systems. You do this by editing
/boot/grub/menu.lst and ensuring the apprpriate full path /dev/disk/by-uuid/ is
used for the parition in question.

On SLES10-SP3 swap paritions lacked a respective UUID, and so the
resume entry must be removed.

SLES12-SP1 and newer use grub2, and started using UUID=id as a shortcut on
/etc/fstab and /etc/default/grub, and so no modifications are needed there.

### grub console setup

As a kernel developer you want to be able to pick what kernel boots
easily. Today, we do this via the console. So we must ensure the console
works on the guest. We support grub2 and grub 0.97.

#### grub 0.97 console setup

On grub 0.97 based systems you must add the following to the top of the
/boot/grub/menu.lst file (when in doubt check one of the custom vagrant
boxes):

```
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=4 serial console
```

Replace `gfxmenu` with `menu` on /boot/grub/menu.lst.

Below are the base releases of grub 0.97 used on our older SLE releases:

  * sles10sp3: grub-0.97-16.25.9
  * sles11sp1: grub-0.97-162.9.1
  * sles11sp4: grub-0.97-162.172.1

Ensure any `quiet` entry is removed from the kernel commmand lines.

#### grub2 console setup

If you install an ISO on a guest using the console the installer has the sanity
to set up *most* of the right setting for you. However, on SLE12-SP1 you must
make the following change on /etc/default/grub:

```
-GRUB_TERMINAL=console
+GRUB_TERMINAL=serial
```

Also ensure GRUB_CMDLINE_LINUX_DEFAULT has the entry `quiet` removed.

###  Address lack of virtio

Certain modern Linux releases releases support virtio drivers for networking,
or storage. Since vagrant uses KVM and KVM relies on qemu, when virtio is not
available emulation is needed. Vagrant is controlled via its Vagrantfile, and
users of a vagrant box can specify one. However sensible defaults must also be
set and provided on a base Vagrantfile for a vagrant box. The lack of a virtio
driver then is codified into the Vagrantfile used to build the first vagrant
box. A vagrant box is nothing more than a tarball (gzip or xz, use xz, it has
better compression) with the guest qcow2 image, the metadata.json file shown
above, and an an initial Vagrantfile.

Below we document the currently needed modifications needed to the Vagrantfile
for our older Linux distributions, we use older SUSE Linux releases as
example which were targetted to create vagrant boxes for kernel development
and testing.

#### Disable default /vagrant nfs sharing for all releases

Vagrant boxes by default share folders under the current directoy via NFS
to the guests you create. This doesn't work so well for all hosts, and sharing
via NFS isn't the best really. We disable NFS sharing as the default then.

This applies to SLE12-SP3 and older releases.

#### Disable virtio drives

SLE10-SP3 doesn't have virtio block driver, and so the root drive uses scsi as the
emulated backend for the drive. Note that currently we still use IDE drives for
the other alternative drives, given using scsi doesn't work at the moment. This
discrepancy should be resolved.

This is done as follows on the respective Vangrantfile:

```
	libvirt.disk_bus = "scsi"
```

#### Disable virtio networking

SLE10-SP3 doesn't have a virtio network driver, and so the ne2k_pci network driver
is emulated.

This is done as follows on the respective Vangrantfile:

```
	libvirt.nic_model_type = "ne2k_pci"
```

### Address changes in sudo for old systems

SLE10-SP3 has an old version of sudo whichhlacks the `-E` argument. And since
the default in vagrant is to use -E, we have to disable this for SLE10-SP3.

This is done as follows on the respective Vangrantfile:

```
	config.ssh.sudo_command = "sudo -H %c"
```
