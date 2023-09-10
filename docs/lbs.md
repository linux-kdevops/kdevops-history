# kdevops Large Block Size (LBS) R&D

kdevops has support for experimenting with larger physical block sizes. This documents some
of its motivations and history in Linux.

A group of folks try to track LBS R&D on the kernel newbies wiki:

  * [Linux LBS progress on kernel newbies wiki](https://kernelnewbies.org/KernelProjects/large-block-size)

## Enabling experimental LBS

On `make menuconfig` just enable:

 * `CONFIG_QEMU_ENABLE_EXTRA_DRIVE_LARGEIO`

This will make sure you have enabled support to build Linux and for `large-block-next`.

## Building large-block-next

```bash
make linux
```

## Enabling NVMe with LBS using 16k physical block sizes

The large-block-next tree has enhancements to enable NVMe to leverage
large block sizes. There are two forms you can use LBS for NVMe:

  * Larger LBA format
  * npwg + awupf >=4k

### Enabling NVMe with LBS with larger LBA formats

The kdevops `CONFIG_QEMU_ENABLE_EXTRA_DRIVE_LARGEIO` option let's you enable
to experiment with drives with larger LBA formats. We have a current
practical limitation of enabling up to 1 MiB LBA format, as otherwise the
kernel will crash.

### NVMe with LBS with npwg + awupf

You can use real NVMe drives for LBS if they have a npwg and awupf >= 4k.

#### R&D to fake large npwg + awupf

You can use real NVMe drives with PCIe passthrough on kdevops and still enable
LBS it to experiment, so long as you don't care about power failure. You can
use an out of tree debug module parameter at boot to fake a larger npwg and
awupf. This is possible so long as you use a value smaller than or equal to the
awun. Three out of tree patches are required for this:

  * [nvme: enhance max supported LBA format check](https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux-next.git/commit/?h=large-block-20230825&id=c434f7be760e04d56867b311cd9f486397427d94)
  * [nvme: add awun / nawun sanity check](https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux-next.git/commit/?h=large-block-20230825&id=c45a46ebfc56129a35921d2201f2b2265e74b8b4)
  * [nvme: add nvme_core.debug_large_atomics to force high awun as phys_bs](https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux-next.git/commit/?h=large-block-20230825&id=e4896787efe7f1cf58be587ab655ea1cd464a11b)

Given some drives use a larger awun, set to MDTS, this should let you experiment
with LBS on NVMe up to MDTS. For example enable a 16k physical block size you
would boot your kernel with:

```
nvme_core.debug_large_atomics=16384
```

You can enable this on your `/etc/default/grub` after `make linux` on the device
you want to a physical block size of 16k.

## Using fio for LBS

You can experiment to see if things are good with fio on LBS:

```bash
fio -bs=16k -iodepth=8 -rw=write -ioengine=io_uring -size=200M -name=io_uring_1 -filename=/dev/nvme9n1 -verify=md5
```

Today we're able to not-crash when using up to 512 KiB LBS NVMe drives for
both direct IO and buffered IO.

## Enabling pure-iomap

Christoph's patches allow for a world where one could potentially boot a system
without buffer heads implemented in `fs/buffer.c` completely. To do that though
you'd need a system that does not use a block device or filesystem which
requires buffer-heads. Today that is only possible if you boot with btrfs or
XFS as the main storage driver. The cloud Amazon Linux 2023 are also capable
of experimenting with this setup.

## Enabling iomap block device cache coexistence

The large-block-next tree also has patches to enable usage of iomap aops for
the block device cache when needed, but also allows you to revert back to
buffer-heads when needed. This let's you use XFS with LBS support for example
and if you later want to, use ext4 on the same drive after wiping XFS.

## Experimenting with pure-iomap

Kdevops provides its own debian-testing vagrant image which supports XFS as the main
root image, and thus could also enable experimenting with pure-iomap. Pure-iomap
allows the `bdev cache` to use IOMAP instead of buffer-heads when doing disk
partition scanning on bootup.

Enable:

  * `CONFIG_VAGRANT_KDEVOPS_DEBIAN_TESTING64_XFS_20230427`

This effectively enables the vagrant image:

  * [kdevops debian-xfs-20230427](https://app.vagrantup.com/linux-kdevops/boxes/debian-xfs-20230427/)

If you'd like to work on your own image see [kdevops docs on building custom vagrant images](https://github.com/linux-kdevops/kdevops/blob/master/docs/custom-vagrant-boxes.md).

# Possible regression analysis of large-block-next

The following 3 tests appear to fail on the R&D development kernel for large
block support large-block-nobdev-20230825 on the test section xfs_reflink_4k
but they are not failing on next-20230825:

  * generic/630
  * generic/491
  * xfs/166

Reproducing these failures on xfs_reflink_4k on large-block-next is easy.
So let us review the failure specifics captured.

## Reviewing the generic/630 failure

```
tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/generic/630.dmesg
[ 9476.325616] run fstests generic/630 at 2023-09-08 19:35:58
[ 9477.130214] XFS (nvme0n1p16): Mounting V5 Filesystem 8a920730-8eb7-4322-b38c-ae95e30a5949
[ 9477.149550] XFS (nvme0n1p16): Ending clean mount
[ 9477.669268] XFS (nvme0n1p5): Mounting V5 Filesystem 85237c66-6527-4a4b-ac84-8ba24c45f205
[ 9477.683097] XFS (nvme0n1p5): Ending clean mount
[ 9477.756625] XFS (nvme0n1p5): Unmounting Filesystem 85237c66-6527-4a4b-ac84-8ba24c45f205
[ 9478.117081] XFS (nvme0n1p5): Mounting V5 Filesystem 676dbb73-c51a-4229-8766-1e80ad6fe632
[ 9478.130884] XFS (nvme0n1p5): Ending clean mount
[ 9482.668174] XFS (nvme0n1p16): Unmounting Filesystem 8a920730-8eb7-4322-b38c-ae95e30a5949
[ 9483.110195] XFS (nvme0n1p5): Unmounting Filesystem 676dbb73-c51a-4229-8766-1e80ad6fe632
[ 9483.208591] XFS (nvme0n1p5): Mounting V5 Filesystem 676dbb73-c51a-4229-8766-1e80ad6fe632
[ 9483.221155] XFS (nvme0n1p5): Ending clean mount
[ 9483.241492] XFS (nvme0n1p5): Unmounting Filesystem 676dbb73-c51a-4229-8766-1e80ad6fe632

tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/generic/630.full
meta-data=/dev/nvme0n1p5         isize=512    agcount=4, agsize=3866624 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=1
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=15466496, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
Discarding blocks...Done.

tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/generic/630.out.bad
QA output created by 630
ASSERT: offset 37 should be 0x58, got 0x0!
/data/fstests-install/xfstests/tests/generic/630: line 29: 1662086 Aborted                 $here/src/deduperace -c $SCRATCH_MNT -n $nr_ops
ASSERT: offset 37 should be 0x58, got 0x0!
/data/fstests-install/xfstests/tests/generic/630: line 32: 1662089 Aborted                 $here/src/deduperace -c $SCRATCH_MNT -n $nr_ops -w
Silence is golden.
```

## Reviewing the generic/491 failure

The generic/491 failure also has nothing interesting on 491.dmesg and 491.full
the out.bad does:

```
tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/generic/491.out.bad
QA output created by 491
/data/fstests-install/xfstests/tests/generic/491: line 47: 1499941 Killed                  $TIMEOUT_PROG -s KILL 1s cat $testfile
```

## Reviewing the xfs/133 failure

```
tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/xfs/166.out.bad
QA output created by 166
0: [AA..BB] XX..YY AG (AA..BB) RIGHT GOOD
1: [AA..BB] XX..YY AG (AA..BB) RIGHT GOOD
2: [AA..BB] XX..YY AG (AA..BB) RIGHT GOOD
3: [AA..BB] XX..YY AG (AA..BB) WRONG GOOD
4: [AA..BB] XX..YY AG (AA..BB) WRONG GOOD

tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/xfs/166.full
/media/scratch/test_file:
 EXT: FILE-OFFSET      BLOCK-RANGE      AG AG-OFFSET        TOTAL FLAGS
   0: [0..31]:         192..223          0 (192..223)          32 000000
   1: [32..12287]:     224..12479        0 (224..12479)     12256 010000
   2: [12288..12319]:  12480..12511      0 (12480..12511)      32 000000
   3: [12320..24567]:  12512..24759      0 (12512..24759)   12248 010000
   4: [24568..24575]:  24760..24767      0 (24760..24767)       8 000000

tar -xOJf  workflows/fstests/results/mcgrof/xfs/libvirt-qemu/20230909/6.5.0-rc7-large-block-nobdev-20230825+.xz 6.5.0-rc7-large-block-nobdev-20230825+/xfs_reflink_4k/xfs/166.dmesg
[13464.023190] run fstests xfs/166 at 2023-09-08 20:42:26
[13465.271472] XFS (nvme0n1p5): Mounting V5 Filesystem df786641-12e4-468e-8dc5-8d4c2287d9e1
[13465.284903] XFS (nvme0n1p5): Ending clean mount
[13465.474291] XFS (nvme0n1p16): Unmounting Filesystem 8a920730-8eb7-4322-b38c-ae95e30a5949
[13465.561247] XFS (nvme0n1p5): Unmounting Filesystem df786641-12e4-468e-8dc5-8d4c2287d9e1
[13465.649621] XFS (nvme0n1p5): Mounting V5 Filesystem df786641-12e4-468e-8dc5-8d4c2287d9e1
[13465.663958] XFS (nvme0n1p5): Ending clean mount
[13465.682869] XFS (nvme0n1p5): Unmounting Filesystem df786641-12e4-468e-8dc5-8d4c2287d9e1
```
