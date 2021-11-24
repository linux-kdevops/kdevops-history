# kernel-ci guest requirements

Today the most complex filesystem to test is the XFS filesystem. It requires
testing at least 8 different configurations on x86_64, each configuration
representing one diferent xfs filesystem created with different mkfs.xfs
parameters.

For instance to create a filesystem with no crc enabled we would use:

  * mkfs.xfs -f -m crc=0,reflink=0,rmapbt=0, -i sparse=0

The trailing commas are not needed but supported by mkfs.xfs. The fstests
test framework allows one to specify *one* target filesystem to
test with different parameters in a section. For the XFS filesystem, at
least for testing against stable kernels, we test 8 different possible
configurations. If no parameters are passed to mkfs.xfs then the defaults
will be used, however these defaults can vary depending on the version of
xfsprogs released, and as such the defaults are relative to the release
being tested. We refer to each type of filesystem created as as part of
a *section*.

* *xfs* (defaults): mkfs.xfs -f -m crc=1,reflink=0,rmapbt=0, -i sparse=0
* *xfs_nocrc*: mkfs.xfs -f -m crc=0,reflink=0,rmapbt=0, -i sparse=0
* *xfs_nocrc_512*: mkfs.xfs -f -m crc=0,reflink=0,rmapbt=0, -i sparse=0, -b size=512
* *xfs_reflink*: mkfs.xfs -f -m reflink=1,rmapbt=1, -i sparse=1
* *xfs_reflink_1024*: mkfs.xfs -f -m reflink=1,rmapbt=1, -i sparse=1, -b size=1024
* *xfs_reflink_normapbt*: mkfs.xfs -f -m reflink=1,rmapbt=0, -i sparse=1

The following two use an external log device for meta data, and the realtime_dev
section name uses also an additional realtime device:

* *xfs_logdev*: mkfs.xfs -f -m crc=1,reflink=0,rmapbt=0, -i sparse=0 -lsize=1g
* *xfs_realtimedev*: mkfs.xfs -f -lsize=1g

## Verifying fstests configuration works

The default target test device to use is specified in TEST_DEV for simple
tests and this corresponds to /dev/loop5. Running the following will end up
using that device using the definition for the xfs_reflink_normapbt
configuration:

 * ./check -s xfs_reflink_normapbt generic/003

To verify the same intended configuration was used with xfs you can use:

 * xfs_info /dev/loop5

generic/003 is the first tests that uses the `_scratch_mkfs` which will create
the filesystem specified in the section configuration.

## kernel-ci guest fstests requirements

In order to run tests with fstests one must configure certain variables to
inform fstests where to find devices to configure with xfs, which are external
log devices -- if one is used -- and which mount path to use for scratch data.
Each test requires at least one test block device to use to test the filesystem.
This is represented by the TEST_DEV variable. Then, some tests may require a a
larger set set of filesystems to be created other than just TEST_DEV. A variable
used to define a set of additional scratch devices which can be used for further
testing, this is defined on the SCRATCH_DEV_POOL variable.

In practice today having at lest 8 number of additional scratch devices
to use suffices for all test. If we also add the TEST_DEV, the external
log and realtime devices we then have 10 devices which we allow fstests
to use for testing.

## kernel-ci guest CPU / RAM requirements

fstests does not run parallelized, running any test can easily create a conflict
with another test. The design behind fstests are for the tests to run serialized,
one test at a time. fstests doesn't require much CPU / RAM, however enough to
not hold a system back is desirable. Experimentation shows 8 vcpus / 8 GIB RAM
more than suffices.

Further testing has been done on one kernel-ci setup to try to reduce the amount
of memory per guest, and we have determined using 2 GiB per guest with 8 vcpus
also works fine except for tests use xfs_scratch, this issue has been reported
through [bsc#1183463](https://bugzilla.suse.com/show_bug.cgi?id=1183463) on test
xfs/074 on the test section xfs_nocrc_512 and prior work on
[bsc#1138229](https://bugzilla.suse.com/show_bug.cgi?id=1138229#c17) shows
how it was concluded that xfs_scratch requires a lot of memory. This issue needs
to be fixed upstream. A compromise is to only increase the memory on the
guest for the section xfs_nocrc_512.

## kernel-ci guest main OS drive

We will need at least 50 GiB for the main OS to be installed. One drive will
be used for this.

## kernel-ci guest data partition

We want to use one partition to mount and use for development files. We refer
to this as the *data* parition, given we mount this on /data. This can be for
our testing or for example cloning a Linux git tree and compiling it on the
guest. 100 GiB should suffice.

When possible we strive for this to be exposed as an nvme drive, and in order
to not require a full 100 GiB of physical space, a sparse file can be created
on the host, so that only the data required by the guest is actually used
on the host. No space is therefore lost on the host. If the guest only used
10 GiB of storage for its clone of a linux git tree, only 10 GiB of space
is used on the host, even though the guest believes it has a full set of
100 GiB of space available for its data parition.

## kernel-ci guest truncated files

Using at least 20 GiB for each device suffices, however since not all tests
actually require the full size of the device for a test it would be wasteful
to guarantee a full 20 GiB for each device, and so truncated files can be used.
Loopback devices can be created on these truncated files so that only the actual
data required by the test is used on the guest.

Experimentation shows that only about 60 GiB of data is requried to run all
any filesystem test.

## kernel-ci guest requirements diagram

Adding all things up, we need a guest with about 8 vcpus, 8 GiB RAM and only
need about 192 GiB of storage of space for each guest. When possible we strive
to push the memory requirements on the guest down to 2 GiB and fix issues
found. At least for testing XFS this is still work in progress. Testing btrfs,
ext4 and blktests however can be done with just 2 GiB RAM. Since disk IO
will be our bottlenceck we hope that the truncated files will be on a fast
storage medium, the faster, the better. The following is what this ends up
looking like:

![kernel-ci-guest](/images/kernel-ci-guest-v3.png)
