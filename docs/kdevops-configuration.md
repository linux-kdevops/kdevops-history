# Getting help with configuration

To learn the different ways to configure kdevops run:

```bash
make help
```

# Configuring kdevops

kdevops provides support for vagrant, terraform, bare metal, and optionally
helps you install and configure libvirt, as well as let you choose which git
tree for Linux to compile, install and boot into, along with which git tag or
commit ID use, and apply any extra patches you might have. The last step of
booting into a particular version of Linux is only the beginning of what can
be accomplished with kdevops, it is just a core demonstration of the
infrastructure. You are encouraged to expand on it for your own needs and a
few more elaborate projects are referenced later.

What a target system may need will vary depending on your needs and your
preferences and so the Linux modeling variability language, kconfig, has been
embraced to allow users to configure how kdevops is to be used. You choose
whether or not to use vagrant, terraform, bare metal, and what bells or
whistles to turn on or off.

To configure kdevops use:

```bash
make menuconfig
```

# Dynamic kconfig

kdevops also supports dynamic kconfig entries without which some features
could not be supported. Typically you run 'make menuconfig' to configure
the Linux kernel the breadth of variability is known, but in the kdevops
world you may want to tweak a few options which are only specific to your
platform on which you are running kdevops on. More specifically, in order
to support PCI-E passthrough support we need to scrape your system's PCI-E
devices and then give you options for doing PCI-E passthrough onto guests.
In order to support PCI-E passthrough kdevops supports creating a few
Kconfig files on-the-fly. But not everyone wants to see these dynamic Kconfig
files or needs to work with them. And so a new target is provided to support
those features that need a dynamic kconfig:

```bash
make dynconfig
```
