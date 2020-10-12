libvirt-user
============

The ansible libvirt-user role lets you get install libvirt, and then configures
the system to allow the current user to set up guests.

Most ansible roles available for libvirt either install libvirt or configures
libvirt with many options and bells and whistles. All you really need for a
simple set up however, is to install libvirt and enable a regular user to use
libvirt.

This role installs libvirt and configures the current running user to be able
to use KVM via libvirt with the typical distro defaults.

Requirements
------------

Run a supported OS/distribution:

  * SUSE SLE / OpenSUSE
  * Red Hat / Fedora
  * Debian / Ubuntu

Role Variables
--------------

  * skip_install: set this to true if you want to skip installation, this is
    set to False by default
  * skip_configuration: set this to true if you want to skip configuration,
    this is set to False by default. Configuration consists of adding the
    user to the respective libvirt groups and verifying that the user is
    effective. Typically we need two runs when configuring, one to add the
    user the required groups, and a second time to verify the user's group
    changes are in effect.

  * only_install: set this to true if you only want to install libvirt. By
    default this is set to False.
  * only_verify_user: set to False by default. This will ensure that we do the
    handy work to do what is needed to enable your user to run libvirt as a
    regular user. Typical recommended use of this ansible role is to run
    with the default of this set to False, and then a second time with this set
    to True to verify if you need to log out and back in.

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook, say a bootlinux.yml file:

```
---
- hosts: localhost
  roles:
    - role: mcgrof.libvirt-user
```

But you want to run this twice, once with the default `only_verify_user` set to
False and then with `only_verify_user` set to True, the last would be a check
to ensure we inform the user to log out and back in so that the group changes
take effect So for instance you would have:

```bash
# Does the actual work
ansible-playbook -i hosts playbooks/libvirt_user.yml

# Verify if the changes are already effective if not warn the user to log
# out and back in.
ansible-playbook -i hosts playbooks/libvirt_user.yml -e "only_verify_user=True"
```

## Running libvirt as a regular user

This documents the logic used by this ansible role to let a regular user run
libvirt.

vagrant can be used to call libvirt without requiring root privileges. To do
this this ansible role ensures the user which runs vagrant is part of the
following groups:

  * kvm
  * libvirt
  * qemu on Fedora / libvirt-qemu on Debian

Debian has its own set of instructions on
[https://wiki.debian.org/KVM#Connecting_locally_to_libvirt_as_regular_user](connecting locally to libvirt as a regular user).
Debian uses libvirt-qemu as the userid which runs qemu, Fedora uses qemu.
The qcow2 files created are ensured to allow the default user qemu executes
under by letting the qemu user group to write to them as well. We have the
defaults for debian on this project, to override the default group to use for
qemu set the value need on the environment variable:

  * ``${PN_U}_VAGRANT_QEMU_GROUP``

You can override the default user qemu will run by modifying
`/etc/libvirt/qemu.conf' user and group settings there.

## Vagrant with apparmor and selinux

If on a system with apparmor or selinux enabled, there may be more work
required on your part. The easiest solution is to disable it if you can
afford it.

XXX: add a task to do this for users.

License
-------

GPLv2
