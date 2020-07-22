# Vagrant support - localized VMs

Read the [kdevops_vagrant](https://github.com/mcgrof/kdevops_vagrant)
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
make deps
cd vagrant/
vagrant up
```

The last step in the above will also run the ansible roles configured to at
least get ansible working afterwards, this is known as `vagrant provisioning`.
The playbooks which will run during `vagrant provisioning` are configured
at the end of the node yml file. As of today we only kick off two ansible roles
as part of the `vagrant provisioning` process:

  * [update_ssh_config_vagrant](https://github.com/mcgrof/update_ssh_config_vagrant)
  * [devconfig](https://github.com/mcgrof/devconfig)

If you just want to run the `vagrant provisioning` step you can run:

```bash
vagrant up --provision
```

We purposely don't run any more ansible roles because we want to encourage
ansible to be used manually as a next step. This would allow the next step
to be independent of vagrant or terraform.

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

