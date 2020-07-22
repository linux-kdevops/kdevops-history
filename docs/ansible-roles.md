# Public ansible role documentation

The following public roles are used, and so have respective upstream
documentation which can be used if one wants to modify how the role
runs with additional tags or extra variables from the command line.
the `kdevops_install` is in charged of installing the rest of the
ansible rolls for you so your project only needs to track that single
ansible role to embrace kdevops.

  * [kdevops_install](https://github.com/mcgrof/kdevops_install)
  * [create_partition](https://github.com/mcgrof/create_partition)
  * [update_ssh_config_vagrant](https://github.com/mcgrof/update_ssh_config_vagrant)
  * [devconfig](https://github.com/mcgrof/devconfig)
  * [bootlinux](https://github.com/mcgrof/bootlinux)
  * [kdevops_vagrant](https://github.com/mcgrof/kdevops_vagrant)
  * [kdevops_terraform](https://github.com/mcgrof/kdevops_terraform)

Kernel configuration files are tracked in the [bootlinux](https://github.com/mcgrof/bootlinux)
role. If you need to update a kernel configuration for whatever reason, please
submit a patch for the [bootlinux](https://github.com/mcgrof/bootlinux)
role upstream.
