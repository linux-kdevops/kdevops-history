# kdevops filesystem testing support

kdevops has support testing Linux filesystems using the fstests test suite.
This documents support for that.

# kdevops fstests configuration

Other than using Kconfig to let you configure your bring up environment and
requirements kdevops also brings the options that fstests offers into Kconfig,
and so enables an easy way to configure you fstests test environment.

# kdevops fstess dedicated workflow

If you are going to test a filesystem you really want to enable a dedicated
workflow (`CONFIG_KDEVOPS_WORKFLOW_DEDICATE_FSTESTS=y`) as that allows kdevops
to let you pick and choose the different target filesystem configuration options
you can test. Some Linux distributions may have older kernels, for instance,
which may not have support for new features which cannot be tested. kdevops uses
Kconfig to allow developers to `select` which target filesystem configuration
options are supported by a distro kernel or not. This avoids having users
testing incorrect or unsupported filesystem configurations.

A dedicated workflow also let's us build target host nodes either for a cloud
deployment or a local virtualization setup which is built off of each target
supported filesystem configuration we support.

# Target devices to use to test

fstest requires at least one drive to test a filesystem, however, there are
cheap ways for us to create multiple drives to support more advanced tests.
Since there are different ways to to create multiple devices this is a
configurable option for kdevops. A dedicated kdevops fstsets workflow has the
option to either use use real NVMe drives to test filesystems or we can build
sparse files for you. The NVMe drives may exist already or if you are using
virtualization, they may be pass onto the guest with PCIe passthrough support.
More details for each of these follow.

# kdevops sparse file testing

kdevops supports testing using sparse or
[truncated files with loopback block devices](docs/testing-with-loopback.md)
so to minimize disk usage and requirements. With this mechanism you only use
disk space for the actual required test, nothing more.

# Testing with real NVMe drives

kdevops supports using real NVMe drives for filesystem testing when used in
a kdevops dedicated fstests workflow.

NVMe drive support relies on the symlinks:

  * `/dev/disk/by-id/nvme`
  * `/dev/disk/by-id/nvme`$model-$serial as an optional fallback

For more details refer to [test using real NVMe drives](docs/testing-with-nvme.md).
The symlinks are used to ensure the same drives are used upon reboot.

You can use real NVMe drivse on nodes which are on baremetal, the cloud,
or virtualization using [PCIe passthrough](docs/libvirt-pcie-passthrough.md).
kdevops supports all these and automates it setup for you.

# Running fstests

Just run:

  * `make fstests`
  * `make fstests-baseline`
  * `make fstests-results`

## Seeing regresions

To see regressions:

  * `git diff`

## Commit new expunges

If you know these failures are real, you can commit them:

  * `git add workflows/fstests/expunges/<path-to-kernel>`

It would be nice for you to commit back over results to our archive, specially
if you are adding expunges for a kernel.

To do that do:

bash
```
TODO
```

# Seeing kdevops community fstests results

See [viewing kdevops archived results](docs/viewing-fstests-results.md) to see
how you can look at existing results file inside kdevops.

TODO:
  * provide a python script to query all results for a specific test or filesystem.
  * this should assume your current configured kernel first and optionally
    let you override that
