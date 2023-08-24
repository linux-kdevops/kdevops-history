# The gen_nodes ansible role

The `gen_nodes` ansible role is used to let us generate certain target files we
need upon bringup. The amount of files it generates will depend on the features
you have enabled. For cloud environments terraform is supported ans the
following files are generated:

  * The `KDEVOPS_NODES` file: defines which nodes to create

## KDEVOPS_NODES and KDEVOPS_NODES_TEMPLATE

If using a cloud environment terraform will set these to be other files:

  * `KDEVOPS_NODES` as `terraform/nodes.tf`
  * `KDEVOPS_NODES_TEMPLATE` as `$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/terraform_nodes.tf.j2`

Your workflow can override this to something different if needed. This
just defines the terraform variable `kdevops_nodes`.

  * [Generating kdevops_nodes terraform variable](playbooks/roles/gen_nodes/templates/terraform_nodes.tf.j2)
