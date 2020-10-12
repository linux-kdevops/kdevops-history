bootlinux
=========

The ansible bootlinux lets you get, build and install Linux.  It also lets you
apply custom patches, remove kernels, etc. Anything you have to do with regards
to generic kernel development. The defaults it will track one of the latest
stable kernels that are still supported, using the linux stable git tree.

Requirements
------------

You are expected to have an extra partition

Role Variables
--------------

  * infer_uid_and_group: defaults to False, if set to True, then we will ignore
    the passed on data_user and data_group and instead try to infer this by
    inspecting the `whoami` and getent on the logged in target system we are
    provisioning. So if user sam is running able on a host, targetting a system
    called foofighter and logging into that system using username pincho,
    then the data_user will be set overwritten and set to pincho. We will then
    also lookup for pincho's default group id and use that for data_group.
    This is useful if you are targetting a slew of systems and don't really
    want to deal with the complexities of the username and group, and the
    default target username you use to ssh into a system suffices to use as
    a base. This is set to False to remain compatible with old users of
    this role.
  * data_path: where to place the git trees we clone under
  * data_user: the user to assign permissions to
  * data_group: the group to assign permissions to

  * data_device: the target device to use for the data partition
  * data_fstype: the filesystem to store the data parition under
  * data_label: the label to use
  * data_fs_opts: the filesystem options to use, you want to ensure to add the
    label

  * target_linux_admin_name: your developer name
  * target_linux_admin_email: your email
  * target_linux_git: the git tree to clone, by default this is the linux-stable
    tree
  * target_linux_tree: the name of the tree
  * target_linux_dir_path: where to place the tree on the target system

  * target_linux_version: which version of linux to use, so 4.19.62
  * target_linux_tag : the actual tag as used on linux, so v4.19.62
  * target_linux_extra_patch: if defined an extra patch to apply with git
     am prior to compilation
  * target_linux_config: the configuration file to use
  * make: the make command to use
  * target_linux_make_cmd: the actual full make command and its arguments
  * target_linux_make_install_cmd: the install command

Dependencies
------------

As defined in requirements.yml.

Example Playbook
----------------

Below is an example playbook, say a bootlinux.yml file:

```
---
- hosts: all
  roles:
    - role: bootlinux
```

Custom runs
===========

Say you want to boot compile a vanilla kernel and you have created a new
section under the hosts file called [dev], with a subset of the [all] section.
You can compile say a vanilla kernel v4.19.58 with an extra set of patches we'd
`git am` for you on top by using the following:

```
cd ansible
ansible-playbook -i hosts -l dev --extra-vars "target_linux_extra_patch=pend-v4.19.58-fixes-20190716-v2.patch" bootlinux.yml
```

You'd place the `pend-v4.19.58-fixes-20190716-v2.patch` file on the directory
`ansible/roles/bootlinux/templates/`.

Now say you wantd to be explicit about a tag of Linux you'd want to use:

```
ansible-playbook -i hosts -l dev --extra-vars "target_linux_version=4.19.21 "target_linux_extra_patch=try-v4.19.20-fixes-20190716-v1.patch" bootlinux.yml
```

To uninstall a kernel:

```
ansible-playbook -i hosts -l dev --tags uninstall-linux --extra-vars "uninstall_kernel_ver=4.19.58+" bootlinux.yml
```

The ansible bootlinux role relies on the create_partition role to create a data
partition where we can stuff code, and compile it. To test that aspect of
the bootlinux role you can run:

```
ansible-playbook -i hosts -l baseline --tags data_partition,partition bootlinux.yml
```

To reboot all hosts:

```bash
ansible-playbook -i hosts bootlinux.yml --tags reboot
```

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

# TODO

## Avoiding carrying linux-next configs

It seems a waste of space to be adding configurations for linux-next for all
tags. It seems easier to just look for the latest linux-next and try that.
We just symlink linux-next files when we really need to, and when something
really needs a new config, we then just add a new file.

License
-------

GPLv2
