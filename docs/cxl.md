# kdevops cxl support

kdevops has support bringing up a CXL development environment and testing. This
documents this support.

You can either use virtualized CXL devices or you can use
[PCIe passthrough](docs/libvirt-pcie-passthrough.md) to passthrough real
devices onto your guests. kdevops support different CXL topologies and allows
you to easily build new ones.

## Get a Linux CXL development environment going and test CXL in just 2 commands:

Using CXL today means you have to build QEMU as most devices are not yet
available on the market, let alone CPUs which have support for them.
CXL in qemu is also is in a large state of flux and so we enable the
best qemu versions available for the latest and greatest.

kdevops supports building QEMU for you.To ramp up with CXL (other than bringup
and the above linux target) just run:

  * `make cxl`
  * `make cxl-test-probe`
  * `make cxl-test-meson`

## Get a Linux CXL switch testing going

This will use b4 to get some R&D patches for CXL switches.

  * `make defconfig-cxl-switch`
  * `make -j$(nproc)`
  * `make bringup`
  * `make linux`
  * `make cxl`
