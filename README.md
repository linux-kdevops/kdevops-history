# kdevops

kdevops provides a devops environment for Linux kernel development and testing.
It makes heavy use of local ansible roles and optionally lets you use
vagrant or terraform. kdevops is Linux distribution agnostic, and also supports
OS X. It aims at letting you configure these tools and bring up a set
of nodes for Linux kernel development as fast as possible.

You can use this project as a template, or you can fork it for your own needs.

kconfig support is provided, to allow you to configure which features from
kdevops you want to use and get up and running on a fresh version of linux
in just 4 commands:

  * `make menuconfig`
  * `make`
  * `make bringup`
  * `make linux`

To test a kernel against fstests, for example, if you enable fstests you can
just run:

  * `make fstests`
  * `make fstests-baseline`

Once kdevops is configured, there are 3 main parts to what kdevops will do
for you:

  * Bring up
  * Make systems easily accessible, and install generic developer preferences
  * Run defined workflows

![kdevops-diagram](images/kdevops-diagram.png)

## Requirements for kdevops

You must be on a recent Linux distribution or OS X. You must have installed:

  * ansible
  * python
  * ncurses-devel
  * make
  * gcc
  * bison
  * flex

If you enable vagrant or terraform *we* try to install it for you along with
their dependencies, including the vagrant-libvirt plugin. The dependency chain
for vagrant can get complex quite fast because of the vagrant-libvirt plugin
and so if using vagrant you are encouraged to be using a rolling Linux
distribution.

If your distribution does not have a package for vagrant, vagrant-libvirt, or
terraform, we support installing from the latest zip Hashi Corp file releases,
however installing manually can get complicated fast later, specially with
the requirement of vagrant-libvirt. If you are going to use vagrant, you
are *highly* encouraged to *not* use an Enterprise version of Linux. You have
been warned.

Examples of well tested rolling distributions recommended if using vagrant:

  * Debian testing
  * OpenSUSE Tumbleweed

If using terraform just ensure you can upgrade terraform to the latest release
regularly.

## Configuring kdevops

kdevops provides support for vagrant, terraform, bare metal, and optionally
helps you install and configure libvirt, as well as let you choose which git
tree for Linux to compile, install and boot into, along with which sha1sum to
use, and apply any extra patches you might have. The last step of booting into
a particular version of Linux is only the beginning of what can be accomplished
with kdevops, it is just a core demonstration of the infrastructure. You are
encouraged to expand on it for your own needs and a few more elaborate projects
are referenced later.

What a target system may need will vary depending on your needs and your
preferences and so the Linux modeling variability language, kconfig, has been
embraced to allow users to configure how kdevops is to be used. You choose
whether or not to use vagrant, terraform, bare metal, and what bells or
whistles to turn on or off.

To configure kdevops use:

```bash
make menuconfig
```

## Running kdevops for the first time

Most dependencies are installed if you're running kdevops for the first time.
To help with this we have an option on kconfig which you should enable if it is
your first time running kdevops, the prompt is for CONFIG_KDEVOPS_FIRST_RUN:

```
"Is this your first time running kdevops on this system?"
```

This will enable a set of sensible defaults to help with your first run.

You can safely this option after you've already run kdevops on a system once
successfully.

## Run make mrproper for each new fresh run

There are several ways to clean a git tree, $(git clean -f -x -d) would be
the paranoid way, however, given we have ansible roles deployed on your system,
which install a few local files, you don't want to re-add them locally, so to
clean a system after you've destroyed your setup with $(make destroy), you can
just run:

```
make mrproper
```

This will remove all generated files, and your .config file, allowing you
to run a new configuration and deployment.

## Getting help with configuration

```bash
make help
```

## Installing dependencies

Once done with configuration we must install all dependencies, and generate
configuration files which will be used later during bring up. To do this
run:

```bash
make
```

## Configuring kdevops

## Bring up nodes

To get your systems up and running and accessible directly via ssh, just do:

```bash
make bringup
```

At this point you should be able to run:

  * `ssh kdevops`
  * `ssh kdevops-dev`

We provide two hosts by default, one to be used as a baseline for your kernel
development, and another for development.

## Booting into a configured version of Linux

Now, to get the configured version of Linux on the systems we just brought up,
all you have to run is:

```bash
make linux
```

Immediately after this you should be able to ssh into either system, and `uname
-r` should disply the kernel you configured.

## Destroying nodes

Just do:

```bash
make destroy
```

---

# Underneath the kdevops hood

Below are sections which get into technical details of how kdevops works.

  * [kconfig integration](docs/kconfig-integration.md)
  * [Motivation behind kdevops](docs/motivations.md)
  * [Linux distribution support](docs/linux-distro-support.md)
  * [Overriding all ansible role options with one file](docs/ansible-override.md)
  * [Parts to kdevops](docs/parts-to-kdevops.md)
  * [kdevops projects](docs/kdevops-projects.md)
  * [kdevops vagrant support](docs/kdevops-vagrant.md)
  * [kdevops terraform support](docs/kdevops-terraform.md)
  * [kdevops ansible roles](docs/ansible-roles.md)

License
-------

This work is licensed under the copyleft-next-0.3.1, refer to the [LICENSE](./LICENSE) file
for details. Please stick to SPDX annotations for file license annotations.
If a file has no SPDX annotation the copyleft-next-0.3.1 applies. We keep SPDX annotations
with permissive licenses to ensure upstream projects we embraced under
permissive licenses can benefit from our changes to their respective files.
Likewise GPLv2 files are allowed as copyleft-next-0.3.1 is GPLv2 compatible.
