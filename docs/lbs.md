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

## Enabling NVMe with LBS

Just boot with `nvme_core.debug_large_lbas=1` on your kernel command line. If you know
this works for boot you can enable this permanently on your grub configuration.

## Using fio for LBS

You can experiment to see if things are good with fio on LBS:

```bash
fio -bs=16k -iodepth=8 -rw=write -ioengine=io_uring -size=200M -name=io_uring_1 -filename=/dev/nvme9n1 -verify=md5
```

Today we're able to not-crash when using up to 32 KiB LBS NVMe drives.

## Enabling pure-iomap

Christoph's patches allow for a world where we could potentially deprecate
`fs/buffer.c` completely. To do that though you'd need a system that does
not use a block device or filesystem which requires buffer-heads. Today
that is only possible if you boot with btrfs or XFS as the main storage
driver. The cloud Amazon Linux 2023 are also capable of experimenting with
this setup.

Kdevops provides its own debian-testing vagrant image which supports XFS as the main
root image, and thus could also enable experimenting with pure-iomap. Pure-iomap
allows the `bdev cache` to use IOMAP instead of buffer-heads when doing disk
partition scanning on bootup.

Enable:

  * `CONFIG_VAGRANT_KDEVOPS_DEBIAN_TESTING64_XFS_20230427`

This effectively enables the vagrant image:

  * [https://app.vagrantup.com/linux-kdevops/boxes/debian-xfs-20230427/](kdevops debian-xfs-20230427)

Today we crash when enabling a LBS at boot on a pure-iomap kernel.

  * large-block-20230426 - [LBS 8k NVMe pure-iomap crash](docs/lbs-pure-iomap-crash.md)
