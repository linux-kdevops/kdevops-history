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

Known issues
-------------

If you are using kdevops to build Linux and fstests this will use
the `create_partition` role twice, once to create the `/data/`
partition and then again later to create the `/media/sparsefiles/`
partition. The first uses the `data_device` and the second uses the
`sparsefiles_device`. The issue is that typically this looks like on
extra_vars.yaml:

```bash
$ egrep "data_device|sparsefiles_device" extra_vars.yaml
data_device: /dev/nvme0n1
sparsefiles_device: /dev/nvme1n1
```

If you run first `make linux` the nvme0n1 drive we intended to use for
the `data` partition might be correct, but upon reboot it  may switch
to `/dev/nvme1n1`. The `/data/` mount point would still work as we used
labels for when creating the filesystem with `mkfs`, but then if that
happens the creation of the filesystem for `sparsefiles_device` will fail.

So currently we have a limitation to require users of fstest to run
`make fstests` prior to `make linux`.

We already associate with vagrant the data partition with information of its purpose:

https://github.com/mcgrof/kdevops/blob/master/playbooks/roles/gen_nodes/templates/kdevops_nodes_split_start.j2.yaml#L57

The scratch device:

https://github.com/mcgrof/kdevops/blob/master/playbooks/roles/gen_nodes/templates/kdevops_nodes_split_start.j2.yaml#L59

*and* we actually already extract the purpose, ie, this "data" or
"scratch" when we're creating the nvme drives for qemu:

https://github.com/mcgrof/kdevops/blob/master/playbooks/roles/gen_nodes/templates/Vagrantfile.j2#L337

So we *could* already even associate this information to the serial
number easily of the device, it would just mean that we'd have
to extend the create_partition task to support 'disk_setup_serial_number'
as an alternative to disk_setup_device:

https://github.com/mcgrof/kdevops/blob/master/playbooks/roles/create_partition/tasks/main.yml
https://github.com/mcgrof/kdevops/blob/master/playbooks/roles/create_partition/defaults/main.yml

License
-------

copyleft-next-0.3.1
