# The gen_nodes ansible role

The `gen_nodes` ansible role is used to let us generate certain target files we
need upon bringup. The amount of files it generates will depend on the features
you have enabled.

The `gen_nodes` ansible role uses jinja2 `template` engine supported by
ansible to generate output files. A file uses the `template` jinja2 processing
by just using *one* ansible task. You provide the source file, and the output
file. That's it. You then codify in the template file what you need using
`jinja2`, and so can leverage variables  in your `extra_vars.yaml` based on
your configuration.

The `gen_nodes` ansible role is in charge of generating node specific
files. The amount of files generated will depend on if you are using
local virtualization (vagrant) or cloud (terraform). We document both below.

For both cases we always generate the `KDEVOPS_NODES` file based on the
jinja2 template `KDEVOPS_NODES_TEMPLATE`.

## Overriding KDEVOPS_PLAYBOOKS_DIR and KDEVOPS_NODES_ROLE_TEMPLATE_DIR

Although the `gen_nodes` ansible role is used to generate the nodes files,
you can override this if you need to. The default settings are set at the
top level Makefile.

```
export KDEVOPS_PLAYBOOKS_DIR := playbooks
KDEVOPS_NODES_ROLE_TEMPLATE_DIR := $(KDEVOPS_PLAYBOOKS_DIR)/roles/gen_nodes/templates
```

## KDEVOPS_NODES and KDEVOPS_NODES_TEMPLATE

The `KDEVOPS_NODES` and `KDEVOPS_NODES_TEMPLATE` is a top level Makefile
variable set to empty at first.

If you have local virtualization enabled vagrant then we default these:

  * `KDEVOPS_NODES` as `vagrant/kdevops_nodes.yaml`
  * `KDEVOPS_NODES_TEMPLATE` is set to the jinja2 template `$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/kdevops_nodes_split_start.j2.yaml`.

If using a cloud environment terraform will set these to be other files:

  * `KDEVOPS_NODES` as `terraform/nodes.tf`
  * `KDEVOPS_NODES_TEMPLATE` as `$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/terraform_nodes.tf.j2`

Furthermore, your workflow can override this to something different if needed.

Docs for each are split up:

  * [gen_nodes for vagrant](the-gen-nodes-ansible-role-vagrant.md)
  * [gen_nodes for terraform](the-gen-nodes-ansible-role-terraform.md)
