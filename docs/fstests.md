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

## Augment expunges for a kernel

If you know this is a real failure which we need to expunge
(TODO: document rationale for this)
you can augment the shared expunge list to help with our known test baseline.

## Confidence in a baseline

A baseline consists of a set of known failures being expunged. Failure rates may
vary on tests and so to help with this we strive by default to build confidence
of a baseline by running fstests in a loop 100 times.  If no new failures have
been found we consider that we have a high confidence in a baseline and then
it can be used to verify if new development changes are not causing a regression.

The amount of loops you choose to test with fstests is configurable
with `CONFIG_KERNEL_CI_STEADY_STATE_GOAL`. We default to 100. This value
is chosen for a few reasons:

  * Running fstests 100 times takes about 1 week
  * This is a sensible litmus test to ensure no regressions are
    introduced with a new delta of patches, if you want to build confidence
    in some possibly intrusive changes to Linux, or backport some patches
    without regressing the kernel.

The value originally comes from kdevops use at SUSE Linux enterprise
distributions, as a litmus test to validate kernel releases, so to ensure
there are no filesystem regressions. Eventually it has also now been adopted
for Linux kernel XFS stable backporting efforts.

You may want to increase or reduce this value depending on your criteria for
testing, but for upstream kdevops testing we want to upkeep at least 100 minimum.

We currently expunge known failures so to reduce time to test. And so any known
test failure is important to expunge, even if the failure rate is one out of
10,000. If a test has a failure rate of 1/10,000, that is one out of 10,000
times running the test, it is still an issue we want to document. We strive
to document failure rates with a comment.

Regardless of how low a failure rate is, we must expunge the test. Eventually
we should verify failures are still occurring and remove tests from expunges
if patches merged fix issues. We should strive to automate this too in the
future.

## Lazy baseline

Since we test different filesystem configurations often, when working on a new
baseline what will happen is a low failure rate test starts to be observed only
in a few target filesystem configuration sections. Eventually, these tests start
failing on other configurations. And so to help reduce the amount of time to
test, after a test fails in at least two test sections (filesystem
configurations) you can use a lazy baseline consideration and just expunge
the test on all sections by using the `all.txt` file.

To do this we a script which will look for common failures, and if found
add them to all.txt, it will then also remove tests found on all.txt but
still present on individual test sections. To process a lazy baseline,
just run:

```bash
./scripts/workflows/fstests/lazy-baseline.sh
```

# Seeing kdevops community fstests results

See [viewing kdevops archived results](docs/viewing-fstests-results.md) to see
how you can look at existing results file inside kdevops.

TODO:
  * provide a python script to query all results for a specific test or filesystem.
  * this should assume your current configured kernel first and optionally
    let you override that
