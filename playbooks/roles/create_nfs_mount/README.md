create_nfs_mount
================

The create_nfs_mount role mounts an NFS export.

Requirements
------------

None. This role installs any necessary NFS client administrative
tools automatically.

Role Variables
--------------

  * nfs_mount_options: extra mount options to use for /etc/fstab.
    This variable should never be empty. If you want to use the
    default mount options, do not override the defaults, which
    is "defaults"
  * nfs_mounted_on: the directory on which to mount the new file system
  * nfs_server_hostname: the NFS server's hostname or IP address
  * nfs_server_export: the pathname of the export to be mounted

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
- name: Create /test/nfs if needed
  include_role:
    name: create_nfs_mount
  vars:
    nfs_mounted_on: "/test/nfs"
    nfs_server_hostname: "nfs.example.com"
    nfs_server_export: "/export/example"
    nfs_mount_options: "sec=sys,vers=4.1"
  tags: [ 'test_nfs_enable' ]
```

For further examples refer to one of this role's users, the
[https://github.com/linux-kdevops/kdevops](kdevops) project.

License
-------

copyleft-next-0.3.1
