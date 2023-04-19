# Recommended methodology to a define kernel-ci host and guest architecture

We now provide generic recommendations so that if you want to build your
kernel-ci system you can do so. These system requirements can be applied
to a bare metal system or cloud solution. You can do your own evaluation.
Since we provide for cloud solutions though we might update the documentation
frequently to provide updates as to the best options available from different
cloud vendors.

Let's address our hardware requirements. In order to accomplish kernel
continuous integration we must be able to test the kernel for the subsystem
targets as fast as possible. Since the kernel-ci effort started with a focus
on filesystems we provide a basis for minimum requirement for a kernel-ci
system as one which can at least do full testing for *any* Linux kernel
filesystem. The assumption is that these requirements might suffice to help
test other subsystems.

In order to design a testbed we account then for the filesystems with the
largest number of configurations required. Due to the long history in evolution
of support for features in XFS, testing XFS requires both enabling and disabling
many features. For example users with an XFS filesystem created on older kernel
should not run into regressions if they upgrade their kernel where CRCs were
later enabled by default.

Testing XFS then requires enabling all supported features but also
disabling all features which older releases supported. As it stands today,
testing XFS requires testing a larger number of possible configurations.

Since fstests does not run parallelized, the best we can do *for now* is to
parallelize tests against different types of filesystems created. One type of
filesystem created consists of a filesystem created with a specific set of mkfs
parameters.

The guest requirements then are defined by the most efficient way to
run *all* fstests for *one* filesystem type of configuration -- one set of
mkfs parameters.

Your host requirements can evolve to support just one filesystem and one
kernel release, to supporting different filesystems and different kernel
releases. Let us at least strive to support testing BTRFS, XFS and ext4 on
at least few kernel releases. Maybe a few stable releases and linux-next.
Maybe you want to be able to generate tests based on a new development
branch released which is not yet merged. An assumption here is of course, that
these requirements should suffice for also testing most other subsystem
specific tests.

Each supported filesystem configuration is tested on a unique guest identifying
the filesystem configuration on the hostname.

Lastly, we optionally also wish for each kernel-ci host to be able to provision
and deploy one set of guests for what we know as the defined baseline and one
set of guests for for development purposes. This allows developers to use spare
kernel-ci system to reproduce any issues which come up as the baseline and
development guests would be running the same kernel and software. It also means
having spare guests available and spawned up which developers can temporarily
use to confirm / test new unrelated issues.

The maximum number of guests required to run on a host is twice those required
for testing, one guest is deployed for tracking the baseline, and another is
used for development purposes. Given we have many guests running the same
binaries we can also enable a few host settings to make more use of our
memory such as KSM and Zswap (refer to the CONFIG_HYPERVISOR_TUNING), if we
are going to be using our own bare metal host.

To define the requirements for the host then, we must first define the ideal
guest requirements, evaluate possible system tunings, and what our goals are
for successful testing. When new tests are considered the guest requirements
can be revisited.

