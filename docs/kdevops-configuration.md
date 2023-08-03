# Getting help with configuration

To learn the different ways to configure kdevops run:

```bash
make help
```

# Configuring kdevops

kdevops provides support for vagrant, Terraform, bare metal, and optionally
helps you install and configure libvirt, as well as let you choose which git
tree for Linux to compile, install and boot into, along with which git tag or
commit ID use, and apply any extra patches you might have. The last step of
booting into a particular version of Linux is only the beginning of what can
be accomplished with kdevops, it is just a core demonstration of the
infrastructure. You are encouraged to expand on it for your own needs and a
few more elaborate projects are referenced later.

What a target system may need will vary depending on your needs and your
preferences and so the Linux modeling variability language, Kconfig, has been
embraced to allow users to configure how kdevops is to be used. You choose
whether or not to use vagrant, Terraform, bare metal, and what bells or
whistles to turn on or off.

To configure kdevops use:

```bash
make menuconfig
```

# Dynamic Kconfig

Refer to [kdevops dynamic configuration](docs/kdevops-dynamic-configuration.md)
