# Terraform support

kdevops allows you to provide variability for terraform using kconfig,
and uses ansible to deploy the files needed to get you going with
a terraform plan.

Terraform is used to deploy your development hosts on cloud virtual machines.
Below are the list of clouds providers currently supported:

  * gce - Google Cloud Compute
  * aws - Amazon Web Service
  * azure - Microsoft Azure
  * openstack (special minicloud support added)

You configure which cloud provider you want to use, what feature from that
cloud provider you want to use, and then you can use kdevops to select which
workflows you want to enable on that configuration.

## Installing dependencies

Just run:

```bash
make
```

## Provisioning (bringup) with terraform

You can just use:

```bash
make bringup
```

Or if you want to do this manually:

```bash
make deps
cd terraform/you_provider
make deps
# Make sure you then add the variables to let you log in to your cloud provider
terraform init
terraform plan
terraform apply
```

You should have had your `~/.ssh/config` updated automatically with the
provisioned hosts.

### Terraform ssh config update

We provide support for updating your ssh configuration file (typically
`~/.ssh/config`) automatically for you, however each cloud provider requires
support to be added in order for this to work. At the time of this writing
we support this for all cloud providers we support.

# If provisioning failed

We run the devconfig ansible role after we update your ssh configuration,
as part of the bring up process. If can happen that this can fail due to
connectivity issues. In such cases, you can run the ansible role yourself
manually:

```bash
ansible-playbook -i hosts -l kdevops playbooks/devconfig.yml
```

Note that there a few configuration items you may have enabled, for things
which we are aware of that we need to pass in as extra arguments to
the roles we support we automatically build an `extra_vars.yaml` with all
known extra arguments. We do use this for one argument for the devconfig
role, and a series of these for the bootlinux role. The `extra_args.yaml`
file is read by all kdevops ansible roles, it does this on each role with
a task, so that users do not have to specify the
`--extra-args=@extra_args.yaml` argument themselves. We however strive to
make inferences for sensible defaults for most things.

# Running ansible for worklows

Before running ansible make sure you can ssh into the hosts listed on
ansible/hosts.

```bash
make uname
```

There is documentation about different workflows supported on the top level
documentation.
