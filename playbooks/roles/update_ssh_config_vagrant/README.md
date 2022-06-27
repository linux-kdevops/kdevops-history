update_ssh_config_vagrant
=========================

Update your `~/.ssh/config` with the same information vagrant has.
If you `vagrant destroy -f` and then `vagrant up` and information
has changed, this role will delete old stale entries and replace
them with the new ones.

Care must be taken as this *does* update your local user's ~/.ssh/config by
default. That is, this role is intended to be run locally, never on virtual
host, unless of course you are doing nested virtualization.

Development notes
-----------------
The code for updating your ssh configuration is shared with terraform.
We do this by having the code for this ansible role effectively
present on this ansible role through a git subtree within kdevops.
The code upstream on that tree is used to publish a terraform module:

  * https://registry.terraform.io/modules/mcgrof/add-host-ssh-config

To learn how to make changes to the shared code read:

  * [update_ssh_config documentation](playbooks/roles/update_ssh_config_vagrant/update_ssh_config/README.md)

Requirements
------------

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

copyleft-next-0.3.1
