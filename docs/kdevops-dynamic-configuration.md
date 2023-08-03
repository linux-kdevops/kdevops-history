# Dynamic Kconfig

kdevops supports dynamic Kconfig entries without which some features
could not be supported. Typically you run 'make menuconfig' to configure
the Linux kernel the breadth of variability is known, but in the kdevops
world you may want to tweak a few options which are only specific to your
platform on which you are running kdevops on. More specifically, in order
to support PCIe passthrough support we need to scrape your system's PCIe
devices and then give you options for doing PCIe passthrough onto guests.
In order to support PCIe passthrough kdevops supports creating a few
Kconfig files on-the-fly. But not everyone wants to see these dynamic Kconfig
files or needs to work with them. And so a new target is provided to support
those features that need a dynamic Kconfig:

```bash
make dynconfig
```

## Future ideas

### CXL topologies

Today we construct CXL topologies manually through kconfig and
Vagrantfile qemu line entries based on jinja2 variables. It should be possible
to generate CXL topologies automatically.

### dynamic cloud configs

Right now cloud provider support requires manual editing of files. This
means we need to edit system information about cloud features. This is
error prone and painful given the slew of features and different region
supported.

It should be possible to dynamically generate all of your cloud provider
features with dynamic Kconfig support. You'd use a tool provided by your
cloud provider, and simply based on your authentication and region give
you all the options you need in Kconfig so you can use with kdevops.
