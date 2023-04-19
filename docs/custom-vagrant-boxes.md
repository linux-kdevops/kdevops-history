# Creating your own custom Vagrant boxes or qcow2 virtual images

You can create your own custom Vagrant boxes if the publicly available
Vagrant boxes do not suit your needs. We document how to do this here.
One reason might be you are an Enterprise Linux distribution and don't
have public Vagrant boxes for older releases you might still support
but want the benefit of having Vagrant boxes to work with kdevops
kernel-ci. Another reason might be you just cannot legally share you
images, for one reason or another. Another reason is you may have some
new technology which is not yet easily available on distribution kernels
and want to enable folks to test technology on some development subsystem
or linux-nxt.

## Re-using an existing box for development

If you are doing Linux kernel development you may want to just enable
a QA or other developers to quickly test a built kernel for you.
If you don't want to do a full fresh install of a distribution you can
opt to re-use a distribution Vagrant box and just augment it with a
custom kernel build. This section documents how to do that with a demo
of a successful box built using this technique.

This is the lazy developer approach to customizing a Vagrant box for Linux
kernel development. This involves four steps:

  * 1) One is getting your kernel binary and modules
  * 2) The GRUB configuration stuff right.
  * 3) Edit the Vagrantfile to remove stupid stuff
  * 4) Building the tarball

We break this down below.

### Getting your kernel over

From a libvirt perspective Vagrant boxes are just compressed tarballs
with a qcow2 file. So to hack on one first download the box. So for
example if we visit the [debian/testing64](https://app.vagrantup.com/debian/boxes/testing64)
page there you will see a [libvirt download URL](https://app.vagrantup.com/debian/boxes/testing64/versions/20220626.1/providers/libvirt.box)
with the box file.

So we do:

```bash
wget https://app.vagrantup.com/debian/boxes/testing64/versions/20220626.1/providers/libvirt.box

sha1sum libvirt.box
06b07c0d0b78df5369d9ed35eaf39098c1ec7846  libvirt.box

file libvirt.box
libvirt.box: gzip compressed data, from Unix, original size modulo 2^32 1197363200
```

The file can be decompressed as a regular tarball. Since it has no
directory in it you want to copy the file to another directory and uncompress
there, otherwise it will clutter your current directory:

```bash
mkdir box-dev
cp libvirt.box box-dev
cd box-dev
tar zxvf libvirt.box
```

So you will see 3 files, one just a qcow2 file the other expresses
how big of a drive was used to create this qcow2 file along with a
provider, and the Vagrantfile defines how to initialize this qcow2 file
with libvirt:

```bash
ls -1

box.img
metadata.json
Vagrantfile

file box.img
box.img: QEMU QCOW2 Image (v3), 21474836480 bytes

cat metadata.json
{
  "provider"     : "libvirt",
  "format"       : "qcow2",
  "virtual_size" : 20
}

cat Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.post_up_message = "Vanilla Debian box. See https://app.vagrantup.com/debian for help and bug reports"

  # workaround for #837992
  # use nfsv4 mode by default since rpcbind is not available on startup
  # we need to force tcp because udp is not available for nfsv4
  config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: "4", nfs_udp: false

  # Options for libvirt vagrant provider.
  config.vm.provider :libvirt do |libvirt|

    # A hypervisor name to access. Different drivers can be specified, but
    # this version of provider creates KVM machines only. Some examples of
    # drivers are kvm (QEMU hardware accelerated), qemu (QEMU emulated),
    # xen (Xen hypervisor), lxc (Linux Containers),
    # esx (VMware ESX), vmwarews (VMware Workstation) and more. Refer to
    # documentation for available drivers (http://libvirt.org/drivers.html).
    libvirt.driver = "kvm"

    # The name of the server, where libvirtd is running.
    # libvirt.host = "localhost"

    # If use SSH tunnel to connect to Libvirt.
    libvirt.connect_via_ssh = false

    # The username and password to access Libvirt. Password is not used when
    # connecting via SSH.
    libvirt.username = "root"
    #libvirt.password = "secret"

    # Libvirt storage pool name, where box image and instance snapshots will
    # be stored.
    libvirt.storage_pool_name = "default"

    # Set a prefix for the machines that's different than the project dir name.
    #libvirt.default_prefix = ''
  end
end
```

And so to hack on the qcow file we just use nbd:

```bash
sudo qemu-nbd --connect=/dev/nbd0 box.img
mkdir debian-testing-root-vagrant
sudo mount /dev/nbd0p1 ./vanilla-debian-zns/debian-testing-root-vagrant
```

When you finish just do:

```bash
sudo modprobe nbd max_part=8
sudo umount debian-testing-root-vagrant
sudo qemu-nbd --disconnect /dev/nbd0
```

It is important to run the disconnect command before copying the box file as
backups or using it for anything.

What I do then is use a kdevops linux-next guest to compile linux-next or
whatever I want, and then I use a two step process. One to scp the modules
directory locally, and the respective `/boot/*$(uname -r)*` files over to
a new directory and then install these on the target. Then you need to configure
the GRUB console so `sudo virsh console <domain>` works and you also want to
update the GRUB menu. That is covered in the next subsection.

### Getting your kernel over

OK now you just need to update the `/etc/default/grub` file and also the
`/boot/grub/grub.cfg` file. Editing `/etc/default/grub` is easy you can
just run your editor on the mounted partition for the file and ensure
you have these entries:

```
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"
GRUB_CMDLINE_LINUX="console=tty0 console=tty1 console=ttyS0,115200n8"

GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --parity=no --stop=1"
GRUB_TERMINAL="console serial"
GRUB_DISABLE_SUBMENU=y
```

The last part of this file helps ensure you can get to pick a different
kernel at boot through the GRUB prompt using the serial console
(`virsh console`), however sadly it seems the GRUB version on the Debian
testing as of today doesn't work with this yet, so this step could be enhanced
to enable more flexibility to the user from the start. Until this is fixed then
developers have to do the work manually to perhaps update GRUB to get this
fixed.

The last step is then to update the `/boot/grub/grub.cfg` file.
To do this, I just have two guests running:

 * dev: some development system where I compile and install some kernel
 * baseline: a fresh Debian testing guest just brought up with Vagrant

And then I scp to it the kernel / modules from dev over, run update-grub
and copy its grub.cfg file over. Something like the following:

```bash
mkdir -p tmp/boot
scp -r dev:/lib/modules/5.19.0-rc4-next-20220629/ tmp/
scp -r dev:/boot/*5.19.0-rc4-next-20220629* tmp/

scp -r tmp/boot/* baseline:/boot/
scp -r tmp-provision-dir/5.19.0-rc4-next-20220629 baseline:/lib/modules/
ssh baseline sudo update-grub
scp baseline:/boot/grub/grub.cfg tmp
```

OK so finally we can copy that grub.cfg to the mounted nbd partition and
hope that works.

### Editing your Vagrantfile to remove stupid stuff

By default Vagrant boxes enable sharing your directory to the guest
through NFS. From a Linux kernel development perspective this is just
lunacy. And so I like to disable it. By default then Debian uses this
for its sync thing

```
  config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: "4", nfs_udp: false
```

Replace this with the more sane which disables this:

```
  config.vm.synced_folder './', '/vagrant', type: '9p', disabled: true, accessmode: "mapped", mount: false
```

You may also want to edit the `config.vm.post_up_message` with whatever.

```
  config.vm.post_up_message = "this is kernel build for send bug reports to ignore@ignore.org"
```

### Example network name resolution

Most distros use udev for consistent names for networking interfaces. If
you just want to get a box out which will work fast the best way is to just
append to your GRUB kernel parameter:

```
GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"
```

### Example network DHCP fix

On a basic debian console install, so where no Network Manager is installed,
you want to just have something simply like this, after testing that the
default network name that comes up is eth0:

```
# cat /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
```

### Ensuring ssh works

You will want to ensure the user ~vagrant has a .ssh/ directory with
chmod 700 permissions and the vagrant ssh key installed by default.
When vagrant detects this a new one random one is replaced.

https://github.com/hashicorp/vagrant/tree/main/keys

So just do:

```bash
mkdir .ssh
chmod 700 .ssh
echo ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key >> authorized_keys
```

### Creating the Vagrant new box file tarball

To create the box file you just tar it up. Assuming you want maximum
compression:

```bash
tar -cvf ../mcgrof-20220629.box box.img metadata.json Vagrantfile -I "gzip --best"
```

You can now upload this box on the Vagrant cloud and use it with the
nice shorthands provided.

## A fresh install

To try to save the most amount of space you want to do a fresh install.
This section documents how to do that.

First you'd install a guest using virt-install, an example script which
you can extend to your own needs is the
[virt-install-demo.sh](docs/virt-install-demo.sh).
There are a a series of adjustments that needed to be made for guests
to work for older kernel releases, should you need that. This is all
documented below.

But below is an example simple script


```bash
virt-install --virt-type kvm \
	--name lio \
	--arch x86_64 \
	--cpu host \
	--location /home/mcgrof/debian-testing-amd64-netinst.iso \
	--os-variant debiantesting \
	--memory 8192  --vcpus  8 \
	--disk pool=data3-xfs,size=20,bus=virtio,format=qcow2 \
	--graphics none \
	--network network=vagrant-libvirt-private,model=virtio \
	--console pty,target_type=serial \
	--debug \
	--extra-args "console=ttyS0"
```

## Extending the Vagrant box definition

A Vagrant box is essentially a tarball (gzip, xc are both supported) with a
qcow2 image and a small metadata file explaining how large the drive for the
guest is.  The Vagrant box also ensures that the guest brought up will also
work on any new system, and so a few things need to be done to ensure for
instance that the network interface will get a DHCP address successfully, and
that you can ssh into the system. So a way to deal with moving guests around
the `cloud` are needed, an example is avoiding
`/etc/udev/rules.d/70-persistent-net.rules` upon first boot on some SLE
systems.

Standard userspace development needs are typically met with the above
requirements. Kernel development however, have more more needs. Extensions
can be made by you so that the custom Vagrant boxes you build extend
what is promised by a Vagrant box, with other things which kernel developers
would typically prefer to have set on the system. This can save time
on bringup. Kdevops does a slew of things to help with this for you, like
setting up the serial console, but if Vagrant boxes already have these things
done on them that is a step which could be skipped.

Below we provide a recipe of items which can be done to help on a fresh install
of a Linux distribution on a qcow2 image so that it is easier to test new
kernels and debug them. The standard Vagrant box definition *only* requires a
guest to come up, and to be able to ssh into them with the Vagrant user.

  * 1) root/vagrant user password is vagrant
  * 2) vagrant user on /etc/sudoers does not need a password to gain root
  * 3) vagrant user has an insecure SSH key installed to enable adding a new random one
  * 4) Disable the firewall and AppArmor
  * 5) Deal with persistent net rules
  * 6) Ensure DHCP will work on the first network interface
  * 7) Ensure the console is allowed
  * 8) Ensure the correct disk size is used on the metadata json file
  * 9) Try to use disk partitions by UUID on /etc/fstab
  * 10) GRUB disk setup with UUID
  * 11) GRUB console setup
  * 12) Address lack of virtio
  * 13) Address changes in sudo for old systems

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

### vagrant user has an insecure SSH key installed

Vagrant publishes an arbitrary public static SSH public and private key, so
that if it is detected a random SSH key is instead generated and used and
installed.

Using a random SSH key for each host is a better idea due to possible
risks of guests being left `spawned` and then `pawned` by motivated eager
beavers for a key the entire internet has access to.

You can surely use your own key as well, however, when sharing Vagrant boxes
you likely don't want to be sharing SSH keys.

### Disable the firewall and AppArmor

You are not trying to secure a bank when running a guest for
kernel development, so running a firewall and apparmor is just
typically noise. This is unless of course if you are testing apparmor
or firewall changes to the kernel.

The firewall and AppArmor can be enabled after initialization, however,
if you really need it.

### Deal with persistent net rules

Each Linux distribution has dealt with a way to keep MAC addresses mapped
to a specific interface name. This is to allow a network card to always get
the same IP address, in case it changes the bus it uses on a system.

Spawning a guest from a Vagrant box means we *want* a different MAC
address for each new guest. This also means we want the first interface
to take the first possible interface name, which will be used for DHCP
purposes after bootup.

### Ensure DHCP will work on the first network interface

We expect at least one ethernet interface to come up so that it can get an IP
address and so that we can then SSH into it. Using a network interface just to
communicate to guests is rather archaic, however, it is the current norm.

A Vagrant box *expects* a random interface to be spawned with it, and we
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

Note that the Vagrant libvirt provider does not seem to provide support
yet for versioning.

### Try to use disk partitions by UUID on /etc/fstab

Some releases do not use /dev/disk/by-uuid labels on /etc/fstab. This
poses a risk when trying to move a guest qcow2 image file from one
system to another. We want something static, and the UUID assigned to
partitions addresses this problem.

This however means that if you are creating your own custom Vagrant
box or installing your own new fresh kernel you may have to take steps
to ensure the UUID is used instead of the raw /dev/vda or alternative
device disk name.

### GRUB disk setup with UUID

As an example, GRUB 0.97 is used on SLE10-SP3, SLE11-SP1, and SLE11-SP4. On
these releases you must ensure that the same /dev/disk/by-uuid is used so that
that a Vagrant box can function on new systems. You do this by editing
/boot/grub/menu.lst and ensuring the appropriate full path /dev/disk/by-uuid/ is
used for the partition in question.

On SLES10-SP3 swap partitions lacked a respective UUID, and so the
resume entry must be removed.

SLES12-SP1 and newer use GRUB2, and started using UUID=id as a shortcut on
/etc/fstab and /etc/default/grub, and so no modifications are needed there.

### GRUB console setup

As a kernel developer you want to be able to pick what kernel boots
easily. Today, we do this via the console. So we must ensure the console
works on the guest. We support GRUB2 (GRUB) and GRUB 0.97 (GRUB Legacy).

#### GRUB 0.97 console setup

On GRUB 0.97 based systems you must add the following to the top of the
/boot/grub/menu.lst file (when in doubt check one of the custom Vagrant
boxes):

```
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=4 serial console
```

Replace `gfxmenu` with `menu` on /boot/grub/menu.lst.

Below are the base releases of GRUB 0.97 used on our older SLE releases:

  * sles10sp3: grub-0.97-16.25.9
  * sles11sp1: grub-0.97-162.9.1
  * sles11sp4: grub-0.97-162.172.1

Ensure any `quiet` entry is removed from the kernel command lines.

#### GRUB2 console setup

If you install an ISO on a guest using the console the installer has the sanity
to set up *most* of the right setting for you. However, on SLE12-SP1 you must
make the following change on /etc/default/grub:

```
-GRUB_TERMINAL=console
+GRUB_TERMINAL="console serial"
```

Also ensure GRUB_CMDLINE_LINUX_DEFAULT has the entry `quiet` removed.

###  Address lack of virtio

Certain modern Linux releases releases support virtio drivers for networking,
or storage. Since Vagrant uses KVM and KVM relies on QEMU, when virtio is not
available emulation is needed. Vagrant is controlled via its Vagrantfile, and
users of a Vagrant box can specify one. However sensible defaults must also be
set and provided on a base Vagrantfile for a Vagrant box. The lack of a virtio
driver then is codified into the Vagrantfile used to build the first Vagrant
box. A Vagrant box is nothing more than a tarball (gzip or xz, use xz, it has
better compression) with the guest qcow2 image, the metadata.json file shown
above, and an initial Vagrantfile.

Below we document the currently needed modifications needed to the Vagrantfile
for our older Linux distributions, we use older SUSE Linux releases as
example which were targeted to create Vagrant boxes for kernel development
and testing.

#### Disable default /vagrant nfs sharing for all releases

Vagrant boxes by default share folders under the current directory via NFS
to the guests you create. This doesn't work so well for all hosts, and sharing
via NFS isn't the best really. We disable NFS sharing as the default then.

This applies to SLE12-SP3 and older releases.

#### Disable virtio drives

SLE10-SP3 doesn't have virtio block driver, and so the root drive uses scsi as the
emulated backend for the drive. Note that currently we still use IDE drives for
the other alternative drives, given using scsi doesn't work at the moment. This
discrepancy should be resolved.

This is done as follows on the respective Vagrantfile:

```
	libvirt.disk_bus = "scsi"
```

#### Disable virtio networking

SLE10-SP3 doesn't have a virtio network driver, and so the ne2k_pci network driver
is emulated.

This is done as follows on the respective Vagrantfile:

```
	libvirt.nic_model_type = "ne2k_pci"
```

### Address changes in sudo for old systems

SLE10-SP3 has an old version of sudo which lacks the `-E` argument. And since
the default in Vagrant is to use -E, we have to disable this for SLE10-SP3.

This is done as follows on the respective Vagrantfile:

```
	config.ssh.sudo_command = "sudo -H %c"
```
