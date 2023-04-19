# Overriding all settings in one optional file

With Kconfig support the additional extra files are not needed, but are
useful for project configurations which don't want to rely on the kdevop's
kconfig integration.

To help users easily override role variables *all* of the kdevops Ansible roles
look for optional extra argument files, which you can use to override *all*
role defaults. This is a `kdevops` thing, to help you be lazy. Since Ansible
roles are expected to be defined in a directory, we look at the parent directory
for these optional files, and use the first one found. The order of the files
we look for is:

  * `extra_args.yml`
  * `extra_args.yaml`
  * `extra_args.json`

