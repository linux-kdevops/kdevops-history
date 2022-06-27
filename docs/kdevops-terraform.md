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

## Configuring your cloud options

To configure which cloud provider you will use you will use the same
mechanism to configure anything in kdevops:

```bash
make menuconfig
```

Under "Bring up methods" you will see the option for
"Node bring up method (Vagrant for local virtualization (KVM / Virtualbox))".
Click on that and then change the option to "Terraform for cloud environments".
That should let you start configuring your cloud provider options. You can
use the same main menu to configure specific workflows supported by kdevops,
by defaults no workflows are enabled, and so all you get is the bringup.

## Installing dependencies

To instal the dependencies of everything which you just enabled just run:

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
### Terraform ssh config update - The add-host-ssh-config terraform module

We provide support for updating your configured ssh configuration file
(typically `~/.ssh/config`) automatically for you, however each cloud provider
requires support to be added in order for this to work. At the time of this
writing we support this for all cloud providers we support.

After `make bringup` you should have had your ssh configuration file updated
automatically with the provisioned hosts. The terraform module
`add-host-ssh-config` is used to do the work of updating your ssh configuration,
a module is used to share the code with provioning with vagrant.

The terraform module on the registry:

  * https://registry.terraform.io/modules/mcgrof/add-host-ssh-config/kdevops/latest

The terraform source code:

  * https://github.com/mcgrof/terraform-kdevops-add-host-ssh-config

Because the same code is shared between the vagrant ansible role and the
terraform module, a git subtree is used to maintain the shared code. The
terraform code downloads the module on its own, while the code for
the vagrant ansible role has the code present on the kdevops tree as
part of its local directories in under:

  * `playbooks/roles/update_ssh_config_vagrant/update_ssh_config/`

Patches for code for in `update_ssh_config` can go against
the `playbooks/roles/update_ssh_config_vagrant/update_ssh_config/`
directory, but should be made atomic so that these changes can
be pushed onto the standalone git tree for update_ssh_config on
a regular basis. For details on the development workflow for it,
read the documentation on:

 * [update_ssh_config documentation](playbooks/roles/update_ssh_config_vagrant/update_ssh_config/README.md)

## Destroying nodes with terraform

Just run:

```bash
make destroy
```

Or if you are doing things manually:

```bash
cd terraform/you_provider
terraform destroy
```

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

## Running ansible for worklows

Before running ansible make sure you can ssh into the hosts listed on
ansible/hosts.

```bash
make uname
```

There is documentation about different workflows supported on the top level
documentation.

## Getting set up with cloud providers

To get set up with cloud providers with terraform we provide some more
references below which are specific to each cloud provider.


### Azure

Read these pages:

https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_certificate.html
https://github.com/terraform-providers/terraform-provider-azurerm.git
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm
https://wiki.debian.org/Cloud/MicrosoftAzure

But the skinny of it:

```
$ openssl req -newkey rsa:4096 -nodes -keyout "service-principal.key" -out "service-principal.csr"
$ openssl x509 -signkey "service-principal.key" -in "service-principal.csr" -req -days 365 -out "service-principal.crt"
$ openssl pkcs12 -export -out "service-principal.pfx" -inkey "service-principal.key" -in "service-principal.crt"
```

Use the documentation to get your tentant ID, the applicaiton id, the
subscription ID. You will need this to set these variables up:

```
$ cat terraform.tfvars
client_certificate_path = "./service-principal.pfx"
client_certificate_password = "my-cool-passworsd"
tenant_id = "SOME-GUID"
application_id = "SOME-GUID"
subscription_id = "SOME-GUID"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

# Updating your ssh config not yet supported on Azure :(
ssh_config_pubkey_file = "~/.ssh/minicloud.pub"
ssh_config_user = "yourcoolusername"
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

### Openstack

Openstack is supported. This solution relies on the clouds.yaml file for
openstack configuration. This simplifies setting up authentication
considerably.

#### Minicloud Openstack support

minicloud has a custom setup where the you have to ssh with a special port
depending on the IP address you get, if you enable minicloud we do this
computation for you and tell you where to ssh to, but we also have support
to update your ~/ssh/config for you.

Please note that minicloud takes a while to update its ports / mac address
tables, and so you may not be able to log in until after about 5 minutes after
you are able to create the nodes. Have patience.

Your terraform.tfvars may look something like:

```
instance_prefix = "my-random-project"

image_name = "Debian 10 ppc64le"
flavor_name = "minicloud.tiny"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

ssh_config_pubkey_file = "~/.ssh/minicloud.pub"
ssh_config = "~/.ssh/config"
ssh_config_user = "debian"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"

```

### AWS - Amazon Web Services

AWS is supported. For authentication we rely on the shared credentials file,
so you must have the file:

```
~/.aws/credentials
```

This file is rather simple with a structure as follows:

```
[default]
aws_access_key_id = SOME_ACCESS_KEY
aws_secret_access_key = SECRET_KEY
```

The profile above is "default", and you can multiple profiles. By default
our tarraform's aws vars.tf assumes ~/.aws/credentials as the default
credentials location, and the profile as "default". If this is different
for you, you can override with the variables:

```
aws_shared_credentials_file
aws_profile
```

But if your credentials file is `~/.aws/credentials` and the profile
target is `default`, then your minimum `terraform.tfvars` file should look
something like this:

```
aws_region = "us-west-1"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2


ssh_config_pubkey_file = "~/.ssh/my-aws.pub"
ssh_config_user = "mcgrof"
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To read more about shared credentails refer to:

  * https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
  * https://docs.aws.amazon.com/powershell/latest/userguide/shared-credentials-in-aws-powershell.html

### GCE - Google Cloude Compute

This ansible role also supports the GCE on terraform. Below is an example
terraform.tfvars you may end up with:

```
project = "demo-kdevops"
limit_num_boxes = 2

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

ssh_config_pubkey_file = "~/.ssh/my-gce.pub"
ssh_config_user = "mcgrof"
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To ramp up, you'll need to get the json for your service account through
the IMA interface. This is documented below. The default name for the
json credentails file is account.json, you can override this and its
path with:

```
credentials = /home/foo/path/to/some.json
```

https://www.terraform.io/docs/providers/google/getting_started.html
https://www.terraform.io/docs/providers/google/index.html
https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource
