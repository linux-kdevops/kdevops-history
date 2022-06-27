# Vagrant support - localized VMs

Read the [kdevops_vagrant](playbooks/roles/install_vagrant/README.md)
documentation, then come here and read this.

Vagrant is used to easily deploy non-cloud virtual machines. Below are
the list of providers supported:

  * Virtualbox
  * libvirt (KVM)

The following Operating Systems are supported:

  * OS X
  * Linux

## Running libvirt as a regular user

kdevops is designed be used without requiring root privileges, however your
user must be allowed to run sudo without a password, and for the regular
user to also be able to run libvirt commands as a regular user. We have an
ansible role which takes care of dealing with this for you. You'd only use
libvirt if using Linux.

## Node configuration

The term `host` is often used to describe `localhost`, and so to help
distinguish `localhost` from your target hosts you'd use for development we
refer to target hosts for development as `nodes`.

We use a yml file to let you describe your project's nodes and how to configure
them. You configure your node target deployment on the
``vagrant/${PROJECT}_nodes.yaml`` file by default. Since this file is commited
into git, if you want to override the defaults and keep that file outside of
git you can use use the file:

  * ``vagrant/${PROJECT}_nodes_override.yaml``

If you prefer a different override file, you can use the environment variable
``KDEVOPS_VAGRANT_NODE_CONFIG`` to define the vagrant host description file
used.

## Provisioning with vagrant

If on Linux we'll assume you are using KVM / libvirt. If on OS X we'll assume
you are using Virtualbox. If these assumptions are incorrect you can override
on the configuration file for your node provisioning. For instance, for this
demo you'd use `vagrant/kdevops_nodes.yaml` and set the `force_provider` variable
to either "libvirt" or "kvm". You can also use environment variables to
override the provider:

  * KDEVOPS_VAGRANT_PROVIDER

You are responsible for having a pretty recent system with some fresh
libvirt, or virtualbox installed. You are encouraged to use the latest release
for your OS and preferably a rolling Linux distribution release. A virtualbox
which supports nvme is required.

To ramp up your guests with vagrant:

```bash
make
make bringup
```

The last step in the above `make bringup` is to run optional ansible roles
which can enable direct ssh access to nodes and also run a bit of basic
provisioning. Although vagrant has direct support for running ansible we do
not make use of this mechanism as it has proven to be fragile before. If
`CONFIG_KDEVOPS_SSH_CONFIG_UPDATE` is enabled your ssh configuration
is updated to enable ansible to connect to the nodes which have come up. If
`CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK` is enabled then the ansible
role configured in `CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK` is the first
ansible to run against nodes to do initial provisioning which by default is the
`devconfig` ansible role. This is all done as part of the `bringup_vagrant`
target on the file `scripts/vagrant.Makefile`. The roles used are:

  * [update_ssh_config_vagrant](playbooks/roles/update_ssh_config_vagrant/README.md)
  * [devconfig](playbooks/roles/devconfig/README.md)

At this point basic initial provisioning is complete.

### Code changes for update_ssh_config_vagrant

The ansible role `update_ssh_config_vagrant` is used to help update your
ssh configuration when using vagrant. The actual code used is a python
script which is also shared for kdevop's support of terrform for cloud
provisioning support. The `update_ssh_config_vagrant` ansible role in
kdevops has the for for the python script locally by using a git subtree.
Updates to actual python code used should be made atomically so that these
changes get pushed back upstream. For more details refer to the follwing
documentation:

  * [update_ssh_config shared code documentation](playbooks/roles/update_ssh_config_vagrant/update_ssh_config/README.md)

## Destroying provisioned nodes with vagrant

You can just use the helper:

```bash
make destroy
```

Or you can either destroy directly with vagrant:

```bash
cd vagrant/
vagrant destroy -f
rm -rf .vagrant
```

Or you can just use virsh directly, if using KVM:

```bash
sudo virsh list --all
sudo virsh destroy name-of-guest
sudo virsh undefine name-of-guest
```

## Limitting vagrant's number of boxes

By default using vagrant will try to create *all* the nodes specified on
your configuration file. By default this is `vagrant/kdevops_nodes.yaml` for
this project, and there are currently 2 nodes there. If you are going to just
test this framework you can limit this initially using environment variables:

```bash
export KDEVOPS_VAGRANT_LIMIT_BOXES="yes"
export KDEVOPS_VAGRANT_LIMIT_NUM_BOXES=1
```

This will ensure only the first host, for example, would be created and
provisioned.
