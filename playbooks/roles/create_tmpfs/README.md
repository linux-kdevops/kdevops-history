create_tmpfs
================

The create_tmpfs role mounts a tmpfs file system.

Requirements
------------

None.

Role Variables
--------------

  * tmpfs_mount_options: extra mount options to use for /etc/fstab.
    This variable should never be empty. If you want to use the
    default mount options, do not override the defaults, which
    is "defaults"
  * tmpfs_mounted_on: the directory on which to mount the new file system
  * tmpfs_user: the user to assign the directory path to
  * tmpfs_group: the group to assign the directory path to

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
- name: Create /test/tmpfs if needed
  include_role:
    name: create_tmpfs
  vars:
    tmpfs_mount_options: "size=75%"
    tmpfs_mounted_on: "/test/tmpfs"
    tmpfs_user: "vagrant"
    tmpfs_group: "vagrant"
  tags: [ 'oscheck', 'test_tmpfs_enable' ]
```

For further examples refer to one of this role's users, the
[https://github.com/linux-kdevops/kdevops](kdevops) project.

License
-------

copyleft-next-0.3.1
