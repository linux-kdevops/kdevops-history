install-vagrant-boxes
=====================

The ansible install-vagrant-boxes role lets you get install additional vagrant
boxes which may be outside of the public catalog.

Requirements
------------

Run system using vagrant.

Role Variables
--------------

  * kdevops_install_vagrant_boxes: set to True to enable installing boxes
  * vagrant_boxes: this role is designed so that you override this varaible
    your own list of boxes.

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook, say a install-vagrant-boxes-sle.yml file which
would try to install the aarch64 vagrant boxes for SLE using some URLs you
have access to:

```
---
- hosts: localhost
  tasks:
    - include_role:
        name: install-vagrant-boxes
      vars:
        vagrant_boxes:
          - { name: 'suse/sle12sp5.aarch64', box_url: 'http://some.com/SLES12-SP5-Vagrant.aarch64-12.5-libvirt_aarch64-GM.vagrant.libvirt.box' }
          - { name: 'suse/sle15sp2.aarch64', box_url: 'http://some.com/SLES15-SP2-Vagrant.aarch64-15.2-libvirt_aarch64-Snapshot2.vagrant.libvirt.box' }
```

License
-------

copyleft-next-0.3.1
