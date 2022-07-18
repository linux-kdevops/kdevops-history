# kdevops

The master git repo for kdevops is:

  * https://github.com/linux-kdevops/kdevops

<img src="images/kdevops-trans-bg-edited-individual-with-logo-gausian-blur-1600x1600.png" width=250 align=center alt="kdevops logo">

kdevops provides a framework for Linux kernel development and testing.
It makes use of local ansible roles and optionally lets you use
vagrant or terraform. kdevops is compatible with Linux in a distribution
agnostic manner and has support for OS X as well. It aims to provision nodes and
tooling for kernel development in a flexible, configurable and speedy manner.

## Quick kdevops demos

To give you an idea of the power and goals behind kdevops we provide a few
quick demos of what you can do below. More workflows will be added with time.
Additional documentation detailing how to get started as well as how to add new
workflows follows the quick demos.

### Start kernel hacking in just 4 commands

Configure kdevops to use bare metal, cloud or a local vm based solution, pick
your distribution of choice, enable the Linux kernel workflow, select target
git tree, and get up and running on a freshly compiled Linux git tree in just
4 commands:

  * `make menuconfig`
  * `make`
  * `make bringup`
  * `make linux`
  * `make linux HOSTS="kdevops-xfs-crc kdevops-xfs-reflink"` for example if you wanted to restrict running the above command only to the two hosts listed

### Start running fstests in 2 commands

To test a kernel against fstests, for example, if you enable the fstests
workflow you can just run:

  * `make fstests`
  * `make fstests-baseline`

### Start running blktests in 2 commands

To test a kernel against fstests, for example, if you enable the blktests
workflow you can just run:

  * `make blktests`
  * `make blktests-baseline`

## kdevops chat server

We have a public chat server up, for now we use discord:

  * https://bit.ly/linux-kdevops-chat

## Parts to kdevops 

It is best to think about kdevops in phases of your desired target workflow.
The first thing you need to do is get systems up. You either are going to
use baremetal hosts, use a cloud solution, or spawn local virtualized guests.

The phases of use of kdevops can be split into:

  * Bring up
  * Make systems easily accessible, and install generic developer preferences
  * Run defined workflows

![kdevops-diagram](images/kdevops-diagram.png)

---

# kdevops documentation

Below is kdevops' recommended documentation reading.

  * [kdevops requirements](docs/requirements.md)
  * [kdevops' evolving make help](docs/evolving-make-help.md)
  * [kdevops configuration](docs/kdevops-configuration.md)
  * [kdevops first run](docs/kdevops-first-run.md)
  * [kdevops running make](docs/running-make.md)
  * [kdevops running make bringup](docs/running-make-bringup.md)
  * [kdevops example workflow: running make linux](docs/kdevops-make-linux.md)
  * [kdevops running make destroy](docs/kdevops-make-destroy.md)
  * [kdevops make mrproper](docs/kdevops-restarting-from-scratch.md)
  * [kdevops pci passthrough configuration](docs/pci-passthrough.md)

# kdevops kernel-ci support

kdevops supports its own kernel continous integration support, so to allow
Linux developers and Linux distributions to keep track of issues present in
any of supported kdevops workflows and be able to tell when new regressions
are detected. Documentation for this follows:

  * [kdevops kernel-ci](docs/kernel-ci/README.md)

# Underneath the kdevops hood

Below are sections which get into technical details of how kdevops works.

  * [Why vagrant is used for virtualization](docs/why-vagrant.md)
  * [A case for truncated files with loopback block devices](docs/testing-with-loopback.md)
  * [Seeing more issues with loopback / truncated files setup](docs/seeing-more-issues.md)
  * [adding a new workflow to kdevops](docs/adding-a-new-workflow.md)
  * [kconfig integration](docs/kconfig-integration.md)
  * [Motivation behind kdevops](docs/motivations.md)
  * [Linux distribution support](docs/linux-distro-support.md)
  * [Overriding all ansible role options with one file](docs/ansible-override.md)
  * [kdevops vagrant support](docs/kdevops-vagrant.md)
  * [kdevops terraform suppor - cloud setup with kdevops](docs/kdevops-terraform.md)
  * [kdevops local ansible roles](docs/ansible-roles.md)
  * [Tutorial on building your own custom vagrant boxes](docs/custom-vagrant-boxes.md)

License
-------

This work is licensed under the copyleft-next-0.3.1, refer to the [LICENSE](./LICENSE) file
for details. Please stick to SPDX annotations for file license annotations.
If a file has no SPDX annotation the copyleft-next-0.3.1 applies. We keep SPDX annotations
with permissive licenses to ensure upstream projects we embraced under
permissive licenses can benefit from our changes to their respective files.
Likewise GPLv2 files are allowed as copyleft-next-0.3.1 is GPLv2 compatible.
