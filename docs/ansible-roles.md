# Local ansible role documentation

The following local ansible roles are used:

  * [create_partition](./playbooks/roles/create_partition/README.md)
  * [update_ssh_config_vagrant](./playbooks/roles/update_ssh_config_vagrant/README.md)
  * [devconfig](./playbooks/roles/devconfig/README.md)
  * [bootlinux](./playbooks/roles/bootlinux/README.md)
  * [install_terraform/](./playbooks/roles/install_terraform/README.md)
  * [install_vagrant/](./playbooks/roles/install_vagrant/README.md)
  * [install_vagrant_boxes](./playbooks/roles/install_vagrant_boxes/README.md)
  * [libvirt_user](./playbooks/roles/libvirt_user/README.md)
  * [update_ssh_config_vagrant](./playbooks/roles/update_ssh_config_vagrant/README.md)
  * create_data_partition: creates the data parition, uses the creat_partition role
  * fstests_prep_localhost: used to install command and control dependencies
  * fstests: used to run the fstests workflow

Kernel configuration files are tracked in the bootlinux role.
