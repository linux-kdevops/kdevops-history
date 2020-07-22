# Linux distribution support by kdevops

There are two scopes to consider for Linux distribution support, one the
host, and then for the target systems. We document our support for each
here.

## Host Linux distribution support by kdevops

Linux Distribution support is only relevant for the host system which you
will use as your `command and control center`, if you will.

Distributions are supported as new users add support for them. Adding support
for a new distribution typically just consists of updating the kdevops
ansible roles with support for doing a mapping of package names, package
manager updates, and ensuring your distribution can install the latest
version of vagrant and terraform. Because you *want* the latest version of
vagrant and terraform rolling Linux distributions are encouraged to be used.
Currently supported Linux distributions:

  * Debian testing
  * OpenSUSE Tumbleweed

If your distribution does not have vagrant and terraform packaged, support
is provided to download the latest releases via the published zip files,
however this can get complex quite fast due to the dependency chain.

## Target Linux distributions support

*Any* Linux distribution can be used as a target, however, the kdevops ansible
roles would need to be updated to map for distribution specific things such
as package names, and if you are using an enterprise release how to register
it. Give kdevops a test run, and if you get support added, feel free to extend
this list.

The list of supported distributions are parft of the list of avaiable
distributions you can select for using `make menuconfig`.

Currently supported target Linux distributions:

   * Debian testing
   * OpenSUSE Tumbleweed
   * Fedora 32
   * SUSE Linux

