# Requirements for kdevops

You must be on a recent Linux distribution, we highly recomend a rolling
Linux distribution or OS X. You must have installed:

  * ansible
  * make

Then just run:

  * `make menuconfig-deps`

Then you can now run:

  * `make menuconfig`

If you enable vagrant or terraform *we* try to install it for you along with
their dependencies, including the vagrant-libvirt plugin. The dependency chain
for vagrant can get complex quite fast because of the vagrant-libvirt plugin
and so if using vagrant you are encouraged to be using a rolling Linux
distribution.

If your distribution does not have a package for vagrant, vagrant-libvirt, or
terraform, we support installing from the latest zip Hashi Corp file releases,
however installing manually can get complicated fast later, specially with
the requirement of vagrant-libvirt. If you are going to use vagrant, you
are *highly* encouraged to *not* use an Enterprise version of Linux. You have
been warned.

# Supported base distributions for command and control

Examples of well tested rolling distributions recommended if using vagrant:

  * Debian testing
  * OpenSUSE Tumbleweed
  * Fedora
  * Latest Ubuntu

If using terraform just ensure you can upgrade terraform to the latest release
regularly.
