# update_ssh_config

This Python script you update your ssh configuration file, typically
` ~/.ssh/config` programatically. It was originally designed to extend
vagrant so that it would update your user's ssh configuration, and later
terraform support was added. The same python script however is shared
between both projects:

  * [update_ssh_config_vagrant](https://github.com/mcgrof/update_ssh_config_vagrant) - ansible role for vagrant to update your ssh configuration
  * [terraform-kdevops-add-host-ssh-config](https://github.com/mcgrof/terraform-kdevops-add-host-ssh-config) - terraform module to update you ssh configuration

This git tree aims at providing a mechanism to allow both projects to share
the same python script. They bring in this code using a git subtree.

## Usage

Below are example command line uses:

### The vagrant use case

This will remove the hosts entries for two hosts, kdevops and kdevops-dev,
and then it adds the hosts using the output from `vagrant ssh-config`. The
output from the command `vagrant ssh-config` is processed by the script,
to allow further extensions.

A backup file is used, just for safe measures.

```
update_ssh_config.py \
	~/.ssh/config \
	--backup_file ~/.ssh/config.bk \
	--remove kdevops,kdevops-dev \
	--addvagranthosts
```

Contrary to the terraform use case we don't perform two operations, and so
we only use one backup file. This is tested under the test case:

  * `test_0009_add_hosts_vagrant_emulate_top()`

## The terraform use case

Terraform will also remove the hosts, but at the same time, it will then also
add the hosts, using parameters specified on the command line. In this example
it is going to add the hosts kdevops, and kdevops-dev, using the IP addresses
provided. The port is the same, and so only one port entry is given, however
if the ports were different they can be separated by a comma, similar to how
the hostname and IP addresses are provided. The identity file to use
is provided.

This is first used for the removal, the IP addresses are given, yet they
are not processed for the removal:

```
update_ssh_config.py \
	--remove kdevops,kdevops-dev \
	--hostname 51.179.84.243,52.195.142.18 \
	--username mcgrof \
	--port 22 \
	--identity ~/.ssh/kdevops_terraform \
	--addstrict \
	--backup_file ~/.ssh/config.backup.kdevops.remove \
	~/.ssh/config
```

Then a second call is issued for the addition. Two separate calls are
made so that there is backup for the ssh configuration for both operations,
one for removal and another for the addition.

```
update_ssh_config.py \
	--addhost kdevops,kdevops-dev \
	--hostname 51.179.84.243,52.195.142.18 \
	--username mcgrof \
	--port 22 \
	--identity \
	~/.ssh/kdevops_terraform \
	--addstrict \
	--backup_file ~/.ssh/config.backup.kdevops.add \
	~/.ssh/config
```

Using two separate calls are however not needed, we split this for
terraform to be careful, however one can combine both operations in one,
and only use one backup file:

```
update_ssh_config.py \
	--remove kdevops,kdevops-dev \
	--addhost kdevops,kdevops-dev \
	--hostname 51.179.84.243,52.195.142.18 \
	--username mcgrof \
	--port 22 \
	--identity \
	~/.ssh/kdevops_terraform \
	--addstrict \
	--backup_file ~/.ssh/config.backup.kdevops.add \
	~/.ssh/config
```

This is tested under test case:

  * `test_0007_add_remove_hosts_two_separate_ops_top()`

## Custom KexAlgorithms

Certain old hosts require a custom KexAlgorithms entry to be added.
To add that use the `--kexalgorithms` parameter. This is tested
with the following test test cases:

  * `0010_add_hosts_kexalgorithms_vagrant_emulate_top()`: to mimic the use
    case if used by vagrant
  * `0011_add_remove_hosts_two_separate_ops_kexalgorithms_top()`: to mimic the
    use case if used by terraform

## Rationale for using Python3

We explicitly rely on python3 because our current use case is vagrant and
terraform users, and that software should be used on recent distributions,
hopefully rolling distrubutions which get updated more often than not. Because
modern distributions are expected to be used as your command and control, it
is a safe assumption you must have python3 available.

Also, some distributions, such as Debian testing as of September 2020, no longer
have a `/usr/bin/python` symlink, and the
[Debian Python Policy](https://www.debian.org/doc/packaging-manuals/python-policy/ch-python.html#s-interpreter)
specifically requests that scripts do not use `/usr/bin/env`, do not use
`/usr/bin/python` and instead use the exact version desired.

If you'd like to add Python2 support feel free to add a python2 version file,
maybe `update_ssh_config2.py` and just have your project symlink to it. The
way vagrant and terraform will use this script is to symlink to the Python3
version.

### Author

[Luis Chamberlain](https://www.do-not-panic.com)

### License

This module is released under the GPLv2.
