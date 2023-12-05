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

# Regressions large-block-next

We no longer have any regressions detected yet.
