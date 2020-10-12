update_ssh_config_vagrant
=========================

Update your `~/.ssh/config` with the same information vagrant has.
If you `vagrant destroy -f` and then `vagrant up` and information
has changed, this role will delete old stale entries and replace
them with the new ones.

Care must be taken as this *does* update your local user's ~/.ssh/config by
default. That is, this role is intended to be run locally, never on virtual
host, unless of course you are doing nested virtualization.

Requirements
--------k----

You can use this if you are using vagrant to deploy guests.

Role Variables
--------------

  * sshconfig: your ssh configuration file
  * sshconfig_backup: where to dump the backup file
  * vagrant_dir: the location of your vagrant deployment
  * kexalgorithms: if set, this sets a custom ssh KexAlgorithms, useful
    on older hosts

Dependencies
------------

You should be using vagrant if you are using this role. Your system
isa lso expected to have some sort of .ssh/config file. This runs
*locally* on your system.

Example Playbook
----------------

Below is an example playbook, say a update_ssh_config_vagrant.yml file, this
would be fine if your vagrant deployment is located on ../vagrant/ directory:

```
---
- hosts: localhost
  roles:
    - role: update_ssh_config_vagrant
```

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project.

License
-------

GPLv2
