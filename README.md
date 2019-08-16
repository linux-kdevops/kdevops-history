# kdevops

kdevops is a sample framework which lets you easily get your Linux devops
environment going for whatever use case you have. The first use case is to
provide a devops environment for Linux kernel development testing, and hence
the name. The goal behind this project is to let you *easily fork it* and
re-purpose it for whatever kdevops needs you may have.

kdevops relies on vagrant, terraform and ansible to get you going with whatever
your virtualization / bare metal / cloud provisioning environment easily.
It realies heavily on public ansible galaxy roles. This lets us share code
with the community work and allows us to not have to carry all that code
in this project. Each role focuses on one specific small goal of the
development focus of kdevops. kdevops then is a bare bones sample demo
project of the kdevops ansible roles made available to the community.

There are three parts to the long terms ideals for kdevops:

1. Provisioning required virtual hosts / cloud environment
2. Provisioning your requirements
3. Running whatever you want

Ansible is first used to get all the required ansible roles.

Vagrant or terraform can then be used to provision hosts. Vagrant and terraform
are also used to kick off ansible later for the second part of the
provisioning, to get all requirements installed.

What works?

  * Full vagrant provisioning
  * Initial terraform provisioning on different cloud providers
  * Running ansible to install dependencies on debian
  * Using ansible to clone, compile and boot into to any random kernel git tree
    with a supplied config
  * Updating your ~/ssh/config for terraform, first tested with the
    OpenStack provider, with both generic and special minicloud support. Other
    terraform providers just require making use of the newly published
    [terraform module add-host-ssh-config](https://registry.terraform.io/modules/mcgrof/add-host-ssh-config/)

# Install dependencies

Just run:

```
make deps
```

kdevops relies on a series of ansible roles to allow us to share as much code
as possible with other projects. Next decide if you want to use a series of
already provisioned hosts, provision your own localized VMs, or use a cloud
provider. If you already have your hosts provisioned then skip to the ansible
section. If you need to provision local VMs read the vagrant section below.
If you want to use a cloud provider read the terraform docs below.

In the end you will rely on ansible after all hosts are provisioned.

## Vagrant support - localized VMs

Read the [kdevops_vagrant](https://github.com/mcgrof/kdevops_vagrant)
documentation, then come here and read this.

Vagrant is used to easily deploy non-cloud virtual machines. Below are
the list of providers supported:

  * Virtualbox
  * libvirt (KVM)

The following Operating Systems are supported:

  * OS X
  * Linux

### Running libvirt as a regular user

kdevops can be used without requiring root privileges. To do this you must
ensure the user which runs vagrant is part of the following groups:

  * kvm
  * libvirt
  * qemu on Fedora / libvirt-qemu on Debian

Debian uses libvirt-qemu as the userid which runs qemu, Fedora uses qemu.
The qcow2 files created are ensured to allow the default user qemu executes
under by letting the qemu user group to write to them as well. We have the
defaults for debian on this project, to override the default group to use for
qemu set the value need on the environment variable:

  * KDEVOPS_VAGRANT_QEMU_GROUP

You can override the default user qemu will run by modifying
`/etc/libvirt/qemu.conf' user and group settings there. If on a system with
apparmor or selinux enabled, there may be more work required on your part.

### Node configuration

You configure your node target deployment on the node.yaml file by default,
you however can override what file to use with the environment variables:

  * KDEVOPS_VAGRANT_NODE_CONFIG

### Provisioning with vagrant

If on Linux we'll assume you are using KVM. If on OS X we'll assume you are
using Virtualbox. If these assumptions are incorrect you can override on the
configuration file for your node provisioning. For instance, the demo you'd
use vagrant/nodes.yaml and set the force_provider variable to either "libvirt"
or "kvm". However, since you would typically keep your vagrant/nodes.yaml file
in version control you can instead use an environment variable:

  * KDEVOPS_VAGRANT_PROVIDER

You are responsible for having a pretty recent system with some fresh
libvirt, or vitualbox installed. For instance, a virtualbox which supports
nvme.

```bash
make deps
cd vagrant/
vagrant up
```

Say you want to just test the provisioning mechanism:

```bash
vagrant provision
```
### Limitting vagrant's number of boxes

By default the using vagrant will try to create *all* the nodes specified on
your configuration file. By default this is nodes.yml and there are currently 7
nodes there. If you are going to just test this framework you can limit this
initially using environment variables:

```bash
export KDEVOPS_VAGRANT_LIMIT_BOXES="yes"
export KDEVOPS_VAGRANT_LIMIT_NUM_BOXES=1
```

This will ensure only the first host, for example, would be created and
provisioned. This might be useful if you are developing on a laptop, for
example, and you want to limit the amount of resources used.

## Terraform support

Read the [kdevops_terraform](https://github.com/mcgrof/kdevops_terraform)
documentation, then come here and read this.

Terraform is used to deploy your solution on cloud virtual machines. Below are
the list of clouds currently supported:

  * azure
  * openstack (special minicloud support added)
  * aws

More details are available on the file [terraform/README.md](./terraform/README.md) file

### Provisioning with terraform

```bash
make deps
cd terraform/you_provider
make deps
terraform init
terraform plan
terraform apply
```

Because cloud providers can take time to make hosts accessible via ssh, the
only thing we strive for is update your `~/ssh/config` for you. Once the
hosts become available you are required to run ansible yourself.

#### Terraform ssh config update

We provide support for updating your ssh configuration file (typically
`~/.ssh/config`) automatically for you, however each cloud provider requires
support to be added in order for this to work. Below is the status of support
for this by different cloud providers we support:

  * OpenStack
   * Generic OpenStack solutions
   * Minicloud
  * Azure: requires work
  * AWS: requires work

## Running ansible

Before running ansible make sure you can ssh into the hosts listed on ansible/hosts.

```bash
make ansible_deps
ansible-playbook -i hosts -l dev playbooks/bootlinux.yml
```

Yes you can later add use a different tag for the kernel revision from the
command line, and even add an extra patch to test on top a kernel:

```
ansible-playbook -i hosts -l dev --extra-vars "target_linux_version=4.19.21 target_linux_extra_patch=try-v4.19.20-fixes-20190716-v1.patch" bootlinux.yml
```

You would place the `pend-v4.19.58-fixes-20190716-v2.patch` file into the
`~/.ansible/roles/mcgrof.bootlinux/templates/` directory.

### Public ansible role documentation

The following public roles are used, and so have respective upstream
documentation which can be used if one wants to modify how the role
runs with additional tags or extra variables from the command line:

  * [create_partition](https://github.com/mcgrof/create_partition)
  * [update_ssh_config_vagrant](https://github.com/mcgrof/update_ssh_config_vagrant)
  * [devconfig](https://github.com/mcgrof/devconfig)
  * [bootlinux](https://github.com/mcgrof/bootlinux)

Kernel configuration files are tracked in the [bootlinux](https://github.com/mcgrof/bootlinux)
role. If you need to update a kernel configuration for whatever reason, please
submit a patch for the [bootlinux](https://github.com/mcgrof/bootlinux)
role upstream.

License
-------

This work is licensed under the GPLv2, refer to the [LICENSE](./LICENSE) file
for details. Please stick to SPDX annotations for file license annotations.
If a file has no SPDX annotation the GPLv2 applies. We keep SPDX annotations
with permissive licenses to ensure upstream projects we embraced under
permissive licenses can benefit from our changes to their respective files.
