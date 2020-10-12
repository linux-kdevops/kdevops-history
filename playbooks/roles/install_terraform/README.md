install-terraform
=================

The ansible install-terraform role lets you get install terraform.
As of January 22, 2019 no Linux distribution I have my hands on currently
packages terraform, as such this role currently lets you download whatever
version you specify. It only installs terraform if its not present.

Later, once distributions start picking up on terraform we can update it
to just use your package manager's latest package.

Requirements
------------

Run a supported OS/distribution:

  * SUSE SLE / OpenSUSE
  * Red Hat / Fedora
  * Debian / Ubuntu

Role Variables
--------------

  * terraform_version: version of terraform to download and install. This is
    only used if you are downloading and installing the zip file.
  * force_install_zip: set to False by default, set this to True to ignore
    installing the package from your distro and instead install the
    zip file directly from Hashicorp.
  * force_install_if_present: set to False by default, set this to True if
    want to force to download terraform even if you already have it present.
    This is a bad idea, however in lieu of the ability to verify the version
    through a task yet, we enable this for debugging purposes for now.

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook, say a install_terraform.yml file:

```
---
- hosts: localhost
  roles:
    - { role: mcgrof.install-terraform, terraform_version: '0.12.19' }
```

If terraform is already installed nothing is done. If you want to force
installation, you can use:

```
---
- hosts: localhost
  roles:
    - { role: mcgrof.install-terraform, terraform_version: '0.12.19', force_install_if_present: True }
```

License
-------

GPLv2
