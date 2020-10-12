devconfig
==========

The devconfig role lets you customize your shell environment on target systems
with your typical set of user preferences. For example if you have a
~/.gitconfig file it will copy it over to each target system you run ansible
on. Likewise you may have a set of favorite bash hacks, which you are used to.
You can stuff these into your file ~/.enhance-bash and devconfig will ensure
that each target system sources this file on their .bashrc file on both the
default target user and also root.

All these are optional. The file copies and modifications only happen if the
files exist.

Requirements
------------

None.

Role Variables
--------------

  * data_home_dir: the target home directory on each host, this defaults to
    /home/vagrant
  * dev_gitconfig_src: your localhost .gitconfig file
  * dev_gitconfig_dest: where to copy the .gitconfig to on the target system
  * dev_bash_config: the .bashrc used
  * dev_bash_config_root: root's .bashrc
  * dev_bash_config_hacks_name: the name of your bash hacks file, the default
    is "enhance-bash"
  * dev_bash_config_hacks_src: if the above is "enhance-bash" then this is
    ~/.enhance-bash
  * dev_bash_config_hacks_generic: the generic name of the above file
  * dev_bash_config_hacks_dest: where to copy the file to on the target system
  * dev_bash_config_hacks_root: where top copy the hacks file for root
  * devconfig_try_refresh_repos: try to update your repos?
  * devconfig_try_upgrade: should we try to update your system?
  * devconfig_try_install_kdevtools: should we install some kernel hacker tools?
  * devconfig_repos_addon: set to true to enable add on repositories
  * devconfig_repos_addon_list: the list of repositories to use

You can also optionally have debian.yml, suse.yml or redhat.yml. Below are
distro specific variables. Some of these can be distro specific of stuffed
into an optional user secret.yml file.

  * suse_register_system: if set to true we will try to register your system
  * suse_registration_code: registration code to use

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
---
- hosts: all
  roles:
    - role: devconfig
```

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

License
-------

GPLv2
