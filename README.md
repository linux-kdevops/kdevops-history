Table of Contents
=================

* [kdevops](#kdevops)
   * [Quick kdevops demos](#quick-kdevops-demos)
      * [Start kernel hacking in just 4 commands](#start-kernel-hacking-in-just-4-commands)
      * [Start running fstests in 2 commands](#start-running-fstests-in-2-commands)
      * [Start running blktests in 2 commands](#start-running-blktests-in-2-commands)
      * [Start testing NFS with in 2 commands](#start-testing-nfs-with-in-2-commands)
      * [Runs some kernel selftests in a parallel manner](#runs-some-kernel-selftests-in-a-parallel-manner)
      * [CXL](#cxl)
   * [kdevops chats](#kdevops-chats)
   * [kdevops on discord](#kdevops-on-discord)
      * [kdevops IRC](#kdevops-irc)
   * [Parts to kdevops](#parts-to-kdevops)
* [kdevops workflow documentation](#kdevops-workflow-documentation)
   * [kdevops shared workflows](#kdevops-shared-workflows)
   * [kdevops workflows which may be dedicated](#kdevops-workflows-which-may-be-dedicated)
* [kdevops general documentation](#kdevops-general-documentation)
* [kdevops kernel-ci support](#kdevops-kernel-ci-support)
* [kdevops organization](#kdevops-organization)
* [kdevops tests results](#kdevops-tests-results)
* [Video presentations on kdevops or related](#video-presentations-on-kdevops-or-related)
* [Underneath the kdevops hood](#underneath-the-kdevops-hood)
   * [License](#license)

# kdevops

The master git repo for kdevops is:

  * https://github.com/linux-kdevops/kdevops

<img src="images/kdevops-trans-bg-edited-individual-with-logo-gausian-blur-1600x1600.png" width=250 align=center alt="kdevops logo">

kdevops provides a framework for automation for optimal Linux kernel development
and testing. It is intended to help you both be able to ramp up with any complex
Linux kernel development environment super fast, and to also let you ramp up
an entire lab for Linux kernel testing for a complex subsystem in a jiffy.

It makes use of local ansible roles and optionally lets you use
[libguestfs](https://libguestfs.org/) with libvirt or terraform in order
to support an cloud provider. Support for vagrant in kdevops exists but is now
deprecated in favor of [libguestfs](https://libguestfs.org/) since vagrant
lacks any active maintenance, new development should use and focus on
[libguestfs](https://libguestfs.org/).

Variability is provided through the same variability language used in the Linux
kernel, kconfig. It is written by Linux kernel developers, for Linux kernel
developers. The project aims to enable support for all Linux distributions.

kdevops supports [PCIe passthrough](docs/libvirt-pcie-passthrough.md)
when using virtualization and allows you to pick and choose onto which guest
any PCIe device gets passed onto. This could be all devices to one guest
or you get to pick what device goes to a specific guest. You can for example
even end up with many guests and each guest gets one PCIe passthrough device
assigned, all through kconfig.

kdevops [PCIe passthrough](docs/libvirt-pcie-passthrough.md) support is
supported using [kdevops dynamic kconfig](docs/kdevops-dynamic-configuration.md), a
new target is provided 'make dynconfig' which let's kdevops generate Kconfig
files dynamically based on your system environment. This mechanism will be
expanded in the future to make kdevops even more dynamic to support even more
features.

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

To uninstall the "6.6.0-rc2" kernel from all nodes:

  * `make linux-uninstall KVER="6.6.0-rc2"`

### Start running fstests in 2 commands

To test a kernel against fstests, for example, if you enable the fstests
workflow you can just run:

  * `make fstests`
  * `make fstests-baseline`
  * `make fstests-results`

For more details see [kdevops fstests docs](docs/fstests.md)

### Start running blktests in 2 commands

To test a kernel against fstests, for example, if you enable the blktests
workflow you can just run:

  * `make blktests`
  * `make blktests-baseline`
  * `make blktests-results`

For more details see [kdevops blktests docs](docs/blktests.md)

### Start testing NFS in 2 commands

To test the kernel's nfs server with the pynfs testsuite, enable the pynfs
workflow and then run:

  * `make pynfs`
  * `make pynfs-baseline`

For more details see [kdevops nfs docs](docs/nfs.md)

### Start running the git regression suite in 2 commands

To test a kernel using the git regression suite, enable the gitr workflow
and then run:

  * `make gitr`
  * `make gitr-baseline`

For more details see [kdevops gitr docs](docs/gitr.md)

### Start running the ltp suite in 2 commands

To test a kernel using the ltp suite, enable the ltp workflow and then run:

  * `make ltp`
  * `make ltp-baseline`

For more details see [kdevops gitr docs](docs/gitr.md)

### Runs some kernel selftests in a parallel manner

kdevops supports running Linux kernel selftests in parallel, this is as easy as:

  * `make selftests`
  * `make selftests-baseline`

You can also run specific tests:

  * `make selftests-firmware`
  * `make selftests-kmod`
  * `make selftests-sysctl`

For more details see [kdevops nfs docs](docs/selftests.md)

### CXL

There is CXL support. You can either use virtualized CXL devices or with
[PCIe passthrough](docs/libvirt-pcie-passthrough.md) you can assign devices
to guests and create custom topologies. kdevops let you build and install
the latest CXL enabled qemu version as well for you. For more details
refer to [kdevops cxl docs](docs/cxl.md)

## kdevops chats

We use discord and IRC. Right now we have more folks on discord than on IRC.

## kdevops on discord

We have a public chat server up, for now we use discord:

  * https://bit.ly/linux-kdevops-chat

### kdevops IRC

We are also on irc.oftc.net on #kdevops

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

# kdevops workflow documentation

A kdevops workflow is a type of target work environment you want to run in.
Different workflows have different kernel requirements, sometimes cloud or qemu
requirements and also enable new make targets for building things or test
targets. Some workflows are generic and may be shared such as that for Linux to
configure and build it. Building and installing Linux is however optional if you
want to just use the kernel that comes with your Linux distribution.

## kdevops shared workflows

* [kdevops example workflow: running make linux](docs/kdevops-make-linux.md)

## kdevops workflows which may be dedicated

  * [kdevops fstests docs](docs/fstests.md)
  * [kdevops blktests docs](docs/blktets.md)
  * [kdevops CXL docs](docs/cxl.md)
  * [kdevops NFS docs](docs/nfs.md)
  * [kdevops selftests docs](docs/selftests.md)

# kdevops general documentation

Below is kdevops' recommended documentation reading.

  * [sending patches and contributing to kdevops](docs/contributing.md)
  * [kdevops requirements](docs/requirements.md)
  * [kdevops' evolving make help](docs/evolving-make-help.md)
  * [kdevops configuration](docs/kdevops-configuration.md)
  * [kdevops mirror support](docs/kdevops-mirror.md)
  * [kdevops first run](docs/kdevops-first-run.md)
  * [kdevops running make](docs/running-make.md)
  * [kdevops libvirt storage pool considerations](docs/libvirt-storage-pool.md)
  * [kdevops PCIe passthrough support](docs/libvirt-pcie-passthrough.md)
  * [kdevops running make bringup](docs/running-make-bringup.md)
  * [kdevops running make destroy](docs/kdevops-make-destroy.md)
  * [kdevops make mrproper](docs/kdevops-restarting-from-scratch.md)
  * [kdevops Large Block Size R&D](docs/lbs.md)

# kdevops kernel-ci support

kdevops supports its own kernel continous integration support, so to allow
Linux developers and Linux distributions to keep track of issues present in
any of supported kdevops workflows and be able to tell when new regressions
are detected. Note though that kernel-ci for kdevops is only implemented on
a few workflows, such as fstestse and blktests. In order to support a kernel-ci
part of the hard task is to come up with what a baseline is, and in kdevops
style, be able go easily `git diff` and read a regression with one line
per regression. This requires a bit of time and work. And it is why some
other workflows do not yet support a kernel-ci.

Documentation for this follows:

  * [kdevops kernel-ci](docs/kernel-ci/README.md)

# kdevops organization

kdevops was put under the linux-kdevops organization to enable other developers
to commit / push updates without any bottlenecks.

# kdevops tests results

kdevops has started to enable users / developers to also push results for
tests. This goes beyond just collecting baseline rusults for known failures,
this aims to collect *within* all dmesg / bad log files for each test that
failed.

An arbitrary namespace is provided so to enable developers, part of the
linux-kdevops organization to contribute findings.

See [viewing kdevops archived results](docs/viewing-fstests-results.md) to see
more details about how to see results. We should add simple wrappers for this
in the future.

# Video presentations on kdevops or related

  * [May 10, 2023 kdevops: Advances with automation of testing with fstests and blktests](https://www.youtube.com/watch?v=aC4gb0r9Hho&ab_channel=TheLinuxFoundation)
    * [LWN coverage of this talk](https://lwn.net/Articles/937830/)
    * A follow up on requests from folks to store failures
    * [fstests results](./workflows/fstests/results/)
    * [blktests results](./workflows/blktests/results/)
    * modules support is confirmed
    * How folks use kdevops, an example is Amir and Chandan use it to support
      stable XFS work for different stable kernels using different technologies.
      Amir uses local virtualization support provided with system resources through Samsung while Chandan uses Oracle Cloud Linux. See
      the [LSFMM 2023 Linux stable backports](https://www.youtube.com/watch?v=U-f7HlD2Ob4&list=PLbzoR-pLrL6rlmdpJ3-oMgU_zxc1wAhjS&ab_channel=TheLinuxFoundation)
      video for more details
    * review 9p support
    * Chandan added OCI cloud support [kdevops OCI docs](docs/kdevops-terraform.md)
    * Alibaba cloud support is possible as terraform provider already exists, patches welcomed
    * arm64 woes - help us debian folks
    * [Oracle supports us with a free trial on the cloud](https://www.oracle.com/cloud/free/) sign up!
    * Microsoft evaluating supporting us with credits
    * SUSE could help with testing but cannot let folks log in
    * Exciting future integration with patchwork we can learn from eBPF
      community and their patchwork usage and testing !
  * [2023 - day to day kernel development kdevops demo to fix a bug](https://youtu.be/CfGX51a_Fq0) which covers the topics:
    * Setting up kdevops to use mirroring for Linux git trees
    * Using git remotes on your host kdevops linux directory
    * An example of a real world kernel issue being investigated and fixed upstream
    * Recommendations and value for reproducers for bugs, in this case stress-ng was used, [more details on the commit that fixes the issue](https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/commit/?h=20230328-module-alloc-opts&id=f66db2da670853b2386af23552fd941275a13644)
    * Using a specific remote branch for development, in this example [20230328-module-alloc-opts](https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/log/?h=20230328-module-alloc-opts) was used as an example PATCH v1 series
    * Using `localversion.*` files to help identify kernel names on Grub prompt
    * Using `make modules_install install -j100` on your guest using 9p
    * Console access with virsh console to guest
    * Console access to pick your kernel at bootup
    * Example of a small change to a real future v2 patch series
  * [2023 - Live kdevops demo](https://youtu.be/FSY3BMHUyJc) which covers the topics:
    * An example with AWS with NVMe drives which [support 16k atomic writes](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/storage-twp.html) on ARM64
    * Demonstrates how to ramp up with a custom arbitrary new Linux kernel branch for testing based on linux-next
    * Demonstrates how to start testing btrfs with linux-next
    * Demonstrates how to test with XFS for linux-next
    * Demonstrates initial work on NFS testing with pynfs
    * Demonstrates current CXL workflows / testing
    * Demonstrates how a few stable XFS maintainers are using kdevops to test XFS using local virtualization solutions or cloud solutions
    * Demonstrates dynamic Kconfig generation in order to support PCIe-passthrough
  * [2022 - LSFMM - Challenges with running fstests and blktests](https://youtu.be/9PYjRYbc-Ms)
  * [2020 - SUSE Labs Conference - kdevops: bringing devops to kernel development](https://youtu.be/-1KnphkTgNg)

# Underneath the kdevops hood

Below are sections which get into technical details of how kdevops works.

  * [How is extra_vars.yaml generated](docs/how-extra-vars-generated.md)
  * [How is the ansible hosts file generated](docs/the-gen-hosts-ansible-role.md)
  * [What are and how to generate the kdevops nodes files](docs/the-gen-nodes-ansible-role.md)
    * [How is the dynamic Vagrant files generated](docs/the-gen-nodes-ansible-role-vagrant.md)
    * [How is the terraform kdevops_nodes variable generated](docs/the-gen-nodes-ansible-role-terraform.md)
  * [How are the terraform terraform/terraform.tfvars variables generated](docs/the-terraform-gen-tfvar-ansible-role.md)
  * [Why Vagrant (deprecated) used to be used for virtualization](docs/why-vagrant.md)
  * [A case for supporting truncated files with loopback block devices](docs/testing-with-loopback.md)
  * [Seeing more issues with loopback / truncated files setup](docs/seeing-more-issues.md)
  * [Adding a new workflow to kdevops](docs/adding-a-new-workflow.md)
  * [Kconfig integration](docs/kconfig-integration.md)
  * [kdevops dynamic Kconfig support](docs/kdevops-dynamic-configuration.md)
  * [Motivation behind kdevops](docs/motivations.md)
  * [Linux distribution support](docs/linux-distro-support.md)
  * [Overriding all Ansible role options with one file](docs/ansible-override.md)
  * [kdevops Vagrant support](docs/kdevops-vagrant.md)
  * [kdevops terraform suppor - cloud setup with kdevops](docs/kdevops-terraform.md)
  * [kdevops local Ansible roles](docs/ansible-roles.md)
  * [Tutorial on building your own custom Vagrant boxes](docs/custom-vagrant-boxes.md)

License
-------

This work is licensed under the copyleft-next-0.3.1, refer to the [LICENSE](./LICENSE) file
for details. Please stick to SPDX annotations for file license annotations.
If a file has no SPDX annotation the copyleft-next-0.3.1 applies. We keep SPDX annotations
with permissive licenses to ensure upstream projects we embraced under
permissive licenses can benefit from our changes to their respective files.
Likewise GPLv2 files are allowed as copyleft-next-0.3.1 is GPLv2 compatible.
