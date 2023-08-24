# Vagrant gen_nodes work

The `gen_nodes` ansible role is used to let us generate certain target files we
need upon bringup. The amount of files it generates will depend on the features
you have enabled. For local virtualization we support vagrant and the files
generated are listed below.

  * The `KDEVOPS_NODES` file: defines which nodes to create
  * The `vagrant/Vagrantfile`: a dynamic Vagrantfile

## KDEVOPS_NODES and KDEVOPS_NODES_TEMPLATE for vagrant

If you have local virtualization enabled vagrant then we default these:

  * `KDEVOPS_NODES` as `vagrant/kdevops_nodes.yaml`
  * `KDEVOPS_NODES_TEMPLATE` is set to the jinja2 template `$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/kdevops_nodes_split_start.j2.yaml`.

Your workflow can override this to something different if needed.

### Dynamic vagrant/kdevops_nodes.yaml file

Although the top level ansible hosts file is already dynamic
(see [dynamic kdevops ansible hosts file)](docs/the-gen-hosts-ansible-role.md))
we currently also generate another yaml file which is used by both local
virtualizaition and cloud environment for node definitions. This file
is a bit more complex given we also extend it with a set of libvirt options
for dynamic features to hosts, to do this jinja2 routines are used.

  * [kdevops dynamic ansible hosts file](playbooks/roles/gen_nodes/templates/kdevops_nodes_split_start.j2.yaml)
  * [kdevops dynamic ansible hosts file](playbooks/roles/gen_nodes/templates/hosts.j2)

As you will see, the `kdevops_nodes_split_start.j2.yaml` starts off with
a set of variables. Most of these were defined and used before we started
embracing Kconfig, so one future work item is to try to see which ones
make sense to move to Kconfig and then `extra_vars.yaml` so we don't have them
in this file.

The last part of the file is as follows

```
vagrant_boxes:
{% include './templates/hosts.j2' %}
```

This just calls the jinja2 helper `gen_nodes_list()` with a series of arguments.
This in turn just processes the loop of `gen_node()` for each node in the
array nodes_list. That routine will augment the series of requirements which
are node specific. For example if `passthrough_enable` is `True` it will augment
the node with PCIe passthrough options.

#### Hyper dynamic qemu feature

Support for [PCIe passthrough support docs](docs/libvirt-pcie-passthrough.md) is
accomplished by scraping your host system and generating dynamic Kconfig files.
These files are unique to your host and because of this kdevops is
`hyper dynamic`. kdevops uses this support to let you pick which target
nodes will get what features and extends qemu arguments for each guest.

This demonstrate both how we both:

  * static Kconfig options for qemu per guest
  * hyper dynamic Kconfig options for qemu per guest

#### Static dynamic qemu features per guest

Given dynamic Kconfig features are possible, it should be easy to then extend
vagrant support to also support different features which don't depend on your
host system, but rather are defined statically on everyone's Kconfig options.
This might be useful, for example, to extend CXL topologies statically.
However, considerations should be also taken to evaluate if a dynamic set
of CXL topologies *could* be inferred based on programming, how would we
define them? Evaluation for this should be done.

If you want you can just define a custom `KDEVOPS_NODES_TEMPLATE` as well.

## Related files

  * [Vagrant top level Makefile](scripts/vagrant.Makefile)
