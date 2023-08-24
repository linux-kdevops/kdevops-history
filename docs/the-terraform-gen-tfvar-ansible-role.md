# The terraform gen_tfvars ansible role

The `gen_tfvars` ansible role is used to let us generate the terraform
variables we need for cloud environments.

## terraform/terraform.tfvars

The default `kdevops_terraform_tfvars` path is `terraform/terraform.tfvars`.
So we generate the `terraform/terraform.tfvars` using jinja2 template, and
each cloud provider can define its own other variables.

## Related files

  * [gen_tfvars ansible main task](playbooks/roles/gen_tfvars/tasks/main.yml)

## Dependency on gen_nodes ansible role

The `gen_tfvars` ansible has a dependency on the
[gen_nodes](docs/the-gen-nodes-ansible-role.md) ansible role as well
to generate the terraform variable `kdevops_nodes`. See the docs:

  * [What are and how to generate the kdevops nodes files](docs/the-gen-nodes-ansible-role.md)
    * [gen_nodes for terraform](docs/the-gen-nodes-ansible-role-terraform.md)

## TODO

It should be possible to automatically generate Kconfig variables for
cloud providers based on input from a real tool from a cloud provider.
This should be able to leverage the dynamic kconfig nature of kdevops.
