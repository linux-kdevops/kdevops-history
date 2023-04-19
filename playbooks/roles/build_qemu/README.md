build_qemu
==========

The Ansible build-qemu role lets you get and build QEMU from source.
This may be desirable if QEMU offers a feature which is not yet upstream,
which is typically the case for new hardware features.

Requirements
------------

Run a supported OS/distribution:

  * SUSE SLE / OpenSUSE
  * Red Hat / Fedora
  * Debian / Ubuntu

Role Variables
--------------

  * qemu_force_install_if_present: set to False by default, set this to True to
    force building even if you have /usr/local/bin/qemu-system-x86_64

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
    - role: build_qemu
```

License
-------

copyleft-next-0.3.1
