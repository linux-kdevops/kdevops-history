oscheck ansible module
======================

fstests is a collection of filesystems tests. fstests is run by using its
script ./check in a series of ways. To install all depenencies for fstests and
to know which arguments to use to pass to check can take time. oscheck abstracts
this to make it easy to just run oscheck against any distribution, and it would
figure things out for you.

This ansible module abstracts oscheck's distro specific and agnostic setup in
ansible playbooks, and also augments oscheck's scripts to automate compiling,
installing a version of Linux and testing fstests on a series of hosts for you.

This oscheck ansible module helps formalize fstests' dependencies, setup, and
helps us parallelize running fstests against a list of target hosts
to reduce test coverage time for a testing a filesystem.

Requirements
------------

 * ansible >= 2.7 - must support reboot module
 * debian testing - further distributions will be added later

Role Variables
--------------

To configure this module look and inspect the files:

  * group_vars/main.yml
  * roles/bootlinux/defaults/main.yml
  * roles/oscheck/defaults/main.yml

Dependencies
------------

We have modifed a few roles a bit, for convenience we therefore carry these
roles on our own and have embeded them into our major roles.

Example Playbook
----------------

To compile linux on all hosts:

```
ansible-playbook -i hosts bootlinux.yml
```

To run oscheck on all hosts:

```
ansible-playbook -i hosts oscheck.yml
```

License
-------

GPLv2

Author Information
------------------

Send patches and rants to: mcgrof@kernel.org
