# A case for truncated files with loopback block devices

Since kdevops originally was a project aimed to help automating filesystems
testing, a few details needs to be explained about the architecture behind
the storage drive setup for testing when testing with bare metal or guests,
and why virtualization is used and how this is all justified.

Tests with the origianl precursor to kdevops,
[oscheck](https://github.com/mcgrof/oscheck), in year 2018 revealed
that running a full set of fstests against XFS using only RAM and tmpfs Vs
using truncated files on real SSDs and loopback devices to represent block
devices saved only about 30 minutes, with a full time time for the tests to be
about 4-5 hours.  With nvme drives the difference should be even smaller. A
reason for why running fstests on truncated files Vs pure RAM is comparable is
because fstests tests are not highly optimized, and tests are all serialized.

Prior to v2.6.30 writing to loopback block devices was effectively as good just
writing data to the page cache. This means these writes are subject to the
flushing policy of the host (background writeback, memory pressure, fsync /
sync calls) in order for the data to be actually be written to backing disks.
Prior to v2.6.30 this effectively made using loopback block devices act as
storage device with large a massive writeback cache. On power outages writes
to disks with large writeback cache with no barriers or flush can easily lead
to filesystem corruption. For the v2.6.30 kernel SUSE added barriers to the
loop block driver through commit 68db1961bbf ("loop: support barrier writes").
Later the barrier concept was phased out in the block layer in favor of
REQ_FLUSH/FUA support, refer to the top of block/blk-flush.c for details of
that implementation. After this effort flush requests are now respected when
needed on the loop block driver. Before this users of loopback block devices
only had the option to choose between really bad performance using O_SYNC to
make it as though each write(2) was followed by a call to fsync(2), or not do
this and risk loosing data when using loopback block devices. On the v4.4 kernel
support was added to use an ioctl to enable O_DIRECT on loopback drives given
that it isn't easy to pass a file descriptor opened as O_DIRECT, the new ioctl
is LOOP_SET_DIRECT_IO. This can be used to bypass the cache completely, when
needed.

Experimention with using truncated files with loopback devices without
direct IO on nvme drives has proven to be sufficiently fast enough for testing
with fstests with different filesystems. Direct IO is not used since we have
relative control over where these drives are if testing a baremetal or a
reliable cloud solution, and using a bit of page cache doesn't cause real harm
to our use case. It is also not that important to use direct IO since we are
not writing to drive things we really care about.

Real drives therefore are not needed to test with fstests.

This gives a lot of flexibility for testing filesystems. Using a virtualization
solution is possible then with truncated files for the pool of test block
devices. 100GiB sparse files are used on real nvme drives on a host to expose a
few nvme drives to the guest. One nvme drive is used to place git trees needed
on a /data/ partition. The guest uses one of the other nvme drives to mount
/media/sparsefiles/ and before initializing tests with fstests new sparse files
are created on that mounted partition using truncate, each one with a default
capacity of 20GiB. Loopback block devices are then set up using these sparse
files and passed to fstets TEST_DEV and SCRATCH_DEV_POOL. The old core-utils
truncate is used on the guest instead of util-linux fallocate since we don't
need to ensure that all the data claimed to exist on each sparse file does
exist and in order to support older guests using the same tool to create
sparse files. We provide enough storage space on the sparse files used for the
nvme drives for the guest. Experience with running fstests on different
filesystems with this setup shows we need only about 50GiB of cumulative space
to run a full set of fstests against any one filesystem.

Using virtualization on a host where control to power is gauranteed, and
running fstests on these guests with sparse files is another reason why using
direct IO is not a requirement. However, it should be noted that a set up like
this can only expose more issues on the underlying guest, these are sorts of
corner cases which filesystem developers do want to see and become aware of.

Since virtualization solutions are being used ideally we'd use filesystems
which support Copy on Write (CoW) on the host where the main guest OS drives
are placed if you are using bare metal hosts. Creating 20 guests, for example,
using the same OS for each guest should save us a lot of storage space using
this strategy. The same partition where the main guest OS resides can be used
to create the sparse files used to virtualize spare nvme drives for each guest.
This limits our options on the host to using XFS and btrfs for placing guest
files, both the OS files and sparse files for the guest nvme drives. The guest
has to decide what filesystem to use for their /media/sparsefiles/ mount point,
this can vary, and so can the target test filesystem. For instance a guest may
test btrfs with fstests but the sparse files on /media/sparsefiles/ may be
mounted on an XFS partition.  Likewise a guest testing XFS may use btrfs for
the sparsefiles in /media/sparsefiles/. Ideally we'd test these combinations
and also parity, that is where the filesystem being tested with fstests also
matches the filesystem on /media/sparsefiles/. We strive to all possible
combinations.
