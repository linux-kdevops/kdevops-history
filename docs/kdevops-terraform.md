# Terraform support

Read the [kdevops_terraform](https://github.com/mcgrof/kdevops_terraform)
documentation, then come here and read this.

Terraform is used to deploy your development hosts on cloud virtual machines.
Below are the list of clouds providers currently supported:

  * openstack (special minicloud support added)
  * aws - Amazon Web Service
  * gce - Google Cloud Compute
  * azure - Microsoft Azure

## Provisioning with terraform

You can just use:

```bash
make bringup
```

Or to do this manually:

```bash
make deps
cd terraform/you_provider
make deps
# Make sure you then add the variables to let you log in to your cloud provider
terraform init
terraform plan
terraform apply
```

Because *some* buggy cloud providers can take time to make hosts accessible via
ssh, the only thing we strive in terms of initial setup is to update your
`~/ssh/config` for you. Once the hosts become available you are required to run
ansible yourself, including the `devconfig` role:

```bash
ansible-playbook -i hosts playbooks/bootlinux.yml
```

### Terraform ssh config update

We provide support for updating your ssh configuration file (typically
`~/.ssh/config`) automatically for you, however each cloud provider requires
support to be added in order for this to work. As of this writing we
support this for all cloud providers we support, however Azure seems to
have a bug, and I'm not yet sure who to blame.

# Running ansible for worklows

Before running ansible make sure you can ssh into the hosts listed on
ansible/hosts.

```bash
make ansible_deps
ansible-playbook -i hosts -l dev playbooks/bootlinux.yml
```

Yes you can later add use a different tag for the kernel revision from the
command line, and even add an extra patch to test on top a kernel:

```
ansible-playbook -i hosts -l dev --extra-vars "target_linux_version=4.19.21 target_linux_extra_patch=try-v4.19.20-fixes-20190716-v1.patch" bootlinux.yml
```

You would place the `pend-v4.19.58-fixes-20190716-v2.patch` file into the
`~/.ansible/roles/mcgrof.bootlinux/templates/` directory.

Say you just want to reboot the systems:

```bash
ansible-playbook -i hosts playbooks/bootlinux.yml --tags reboot
```
