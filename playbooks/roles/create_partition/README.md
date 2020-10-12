create_partition
================

The create_partition role lets you safely create and mount a Linux partition.

There are checks in place to ensure you only create the partition if the
partition didn't exist before. Devices upon bootup can change device names, and
so the assumption is we'd use a device name upon an initial boot, and later it
may move to another device name. This role would capture this as it scrape for
the partition label on other devices.

The partition label is used and relied upon.

Requirements
------------

You must have your respective partition userspace tools.  For instance,
xfsprogs if using xfs. If you specify 'xfs' then make.xfs is used. If you
specify 'foo' as your filesystem type, then you must have 'mkfs.foo'.

Role Variables
--------------

  * disk_setup_device: the target device to use
  * disk_setup_fstype: the filesystem type to use
  * disk_setup_mount_opts: extra mount options to use for /etc/fstab, should
    never be empty, if you want to use the default just do not override
    the defaults which is "defaults"
  * disk_setup_label: the filesystem label to use
  * disk_setup_fs_opts: additional filesystem options to pass
  * disk_setup_path: the path to mount the filesystem
  * disk_setup_user: the user to assign the directory path to
  * disk_setup_group: the group to assign the directory path to

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
- name: Create /media/truncated if needed
  include_role:
    name: create_partition
  vars:
    disk_setup_device: "/dev/nvme2n1"
    disk_setup_fstype: "xfs"
    disk_setup_label : "truncated"
    disk_setup_fs_opts: "-L {{ disk_setup_label }}"
    disk_setup_path: "/media/truncated"
    disk_setup_user: "vagrant"
    disk_setup_group: "vagrant"
  tags: [ 'oscheck', 'truncated_partition' ]
```

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

License
-------

GPLv2
