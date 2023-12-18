nfsd_add_export
================

The nfsd_add_export role lets you create an NFS export on the NFS
server set up by kdevops. There are checks in place to ensure the
export is created only if it didn't exist before. The new export
is added to the server's list of permanent exports.

Requirements
------------

None. NFS server and LVM administrative tools are installed on the
kdevops NFS server automatically.

Role Variables
--------------

  * server_host: the hostname or IP address of the NFS server where
    the new export is to be created
  * export_volname: the name of the new export, to be created under
    the /exports directory on the NFS server
  * export_options: the export options for the new export
  * export_fstype: the file system type of the new export
  * export_size: the maximum size of the new export
  * export_user: the owner of the new export
  * export_group: the owner group of the new export

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
- name: Create NFS export for test vol
  include_role:
    name: nfsd_add_export
  vars:
    server_host: "kdevops-nfsd"
    export_volname: "test"
    export_fstype: "btrfs"
    export_size: 20g
  when:
    - test_fstype == "nfs"
    - test_nfs_use_kdevops_nfsd|bool
```

For further examples refer to one of this role's users, the
[https://github.com/linux-kdevops/kdevops](kdevops) project.

License
-------

GPL-2.0+
