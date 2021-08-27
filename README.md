# kdevops

kdevops provides a devops environment for Linux kernel development and testing.
It makes heavy use of local ansible roles and optionally lets you use
vagrant or terraform. kdevops is Linux distribution agnostic, and also supports
OS X. It aims at letting you configure these tools and bring up a set
of nodes for Linux kernel development as fast as possible.

You can use this project as a template, or you can fork it for your own needs.
Better yet, if you really have custom changes and you want to keep them
private, this use is encouraged and supported, the best to do this however
is for you to consider using kdevops as a git subtree.

## Quick kdevops demos

To give you the idea of the power and goals behind kdevops we provide a few
quick demos of what you can do below. More workflows will be added with time.
There is documentation below on how to get started to add new workflows.

### Start kernel hacking in just 4 commands

Configure kdevops to use bare metal, cloud or virtualization solution, pick
your distribution of choise, enable the Linux kernel workflow, select target
git tree, and get up and running on a freshly compiled Linux git tree in just
4 commands:

  * `make menuconfig`
  * `make`
  * `make bringup`
  * `make linux`

### Start running fstests in 2 commands

To test a kernel against fstests, for example, if you enable the fstests
workflow you can just run:

  * `make fstests`
  * `make fstests-baseline`

### Start running blktets in 2 commands

To test a kernel against fstests, for example, if you enable the blktests
workflow you can just run:

  * `make blktests`
  * `make blktests-baseline`

## Parts to kdevops 

It is best to think about kdevops in phases of your desired target workflow.
The first thing you need to do is get systems up. You either are going to
use baremetal guests, use a cloud solution, or spawn virtualized guests.

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
  * [kdevops example workflow: running make linux](kdevops-make-linux.md)
  * [kdevops running make destroy](docs/kdevops-make-destroy.md)
  * [kdevops make mrproper](docs/kdevops-restarting-from-scratch.md)

# Underneath the kdevops hood

Below are sections which get into technical details of how kdevops works.

  * [adding a new workflow to kdevops](docs/adding-a-new-workflow.md)
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
