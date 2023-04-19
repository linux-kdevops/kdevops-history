# Requirements for kdevops

You must be on a recent Linux distribution, we highly recommend a rolling
Linux distribution or OS X. You must have installed:

  * Ansible
  * GNU Make

Then just run:

  * `make menuconfig-deps`

Then you can now run:

  * `make menuconfig`

If you enable Vagrant or Terraform *we* try to install it for you along with
their dependencies, including the vagrant-libvirt plugin. The dependency chain
for Vagrant can get complex quite fast because of the vagrant-libvirt plugin
and so if using Vagrant you are encouraged to be using a rolling Linux
distribution.

If your distribution does not have a package for Vagrant, vagrant-libvirt, or
Terraform, we support installing from the latest zip HashiCorp file releases,
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

If using Terraform just ensure you can upgrade Terraform to the latest release
regularly.
