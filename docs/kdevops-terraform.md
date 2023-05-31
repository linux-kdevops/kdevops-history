# Terraform support

kdevops allows you to provide variability for Terraform using kconfig,
and uses Ansible to deploy the files needed to get you going with
a Terraform plan.

Terraform is used to deploy your development hosts on cloud virtual machines.
Below are the list of clouds providers currently supported:

  * azure - Microsoft Azure
  * aws - Amazon Web Service
  * gce - Google Cloud Compute
  * oci - Oracle Cloud Infrastructure
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
"Node bring up method (Vagrant for local virtualization (KVM / VirtualBox))".
Click on that and then change the option to "Terraform for cloud environments".
That should let you start configuring your cloud provider options. You can
use the same main menu to configure specific workflows supported by kdevops,
by defaults no workflows are enabled, and so all you get is the bringup.

## Installing dependencies

To install the dependencies of everything which you just enabled just run:

```bash
make
```

## Provisioning (bringup) with Terraform

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
### Terraform SSH config update - The add-host-ssh-config Terraform module

We provide support for updating your configured SSH configuration file
(typically `~/.ssh/config`) automatically for you, however each cloud provider
requires support to be added in order for this to work. At the time of this
writing we support this for all cloud providers we support.

After `make bringup` you should have had your SSH configuration file updated
automatically with the provisioned hosts. The Terraform module
`add-host-ssh-config` is used to do the work of updating your SSH configuration,
a module is used to share the code with provisioning with vagrant.

The Terraform module on the registry:

  * https://registry.terraform.io/modules/mcgrof/add-host-ssh-config/kdevops/latest

The Terraform source code:

  * https://github.com/mcgrof/terraform-kdevops-add-host-ssh-config

Because the same code is shared between the vagrant Ansible role and the
Terraform module, a git subtree is used to maintain the shared code. The
Terraform code downloads the module on its own, while the code for
the Vagrant Ansible role has the code present on the kdevops tree as
part of its local directories in under:

  * `playbooks/roles/update_ssh_config_vagrant/update_ssh_config/`

Patches for code for in `update_ssh_config` can go against
the `playbooks/roles/update_ssh_config_vagrant/update_ssh_config/`
directory, but should be made atomic so that these changes can
be pushed onto the standalone git tree for update_ssh_config on
a regular basis. For details on the development workflow for it,
read the documentation on:

 * [update_ssh_config documentation](playbooks/roles/update_ssh_config_vagrant/update_ssh_config/README.md)

## Destroying nodes with Terraform

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

We run the devconfig Ansible role after we update your SSH configuration,
as part of the bring up process. If can happen that this can fail due to
connectivity issues. In such cases, you can run the Ansible role yourself
manually:

```bash
ansible-playbook -i hosts -l kdevops playbooks/devconfig.yml
```

Note that there a few configuration items you may have enabled, for things
which we are aware of that we need to pass in as extra arguments to
the roles we support we automatically build an `extra_vars.yaml` with all
known extra arguments. We do use this for one argument for the devconfig
role, and a series of these for the bootlinux role. The `extra_args.yaml`
file is read by all kdevops Ansible roles, it does this on each role with
a task, so that users do not have to specify the
`--extra-args=@extra_args.yaml` argument themselves. We however strive to
make inferences for sensible defaults for most things.

## Running Ansible for workflows

Before running Ansible make sure you can SSH into the hosts listed on
ansible/hosts.

```bash
make uname
```

There is documentation about different workflows supported on the top level
documentation.

## Getting set up with cloud providers

To get set up with cloud providers with Terraform we provide some more
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

Use the documentation to get your tenant ID, the application id, the
subscription ID. You will need this to set these variables up:

```
$ cat terraform.tfvars
client_certificate_path = "./service-principal.pfx"
client_certificate_password = "my-cool-password"
tenant_id = "SOME-GUID"
application_id = "SOME-GUID"
subscription_id = "SOME-GUID"

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

minicloud has a custom setup where the you have to SSH with a special port
depending on the IP address you get, if you enable minicloud we do this
computation for you and tell you where to SSH to, but we also have support
to update your ~/ssh/config for you.

Please note that minicloud takes a while to update its ports / mac address
tables, and so you may not be able to log in until after about 5 minutes after
you are able to create the nodes. Have patience.

Your terraform.tfvars may look something like:

```
instance_prefix = "my-random-project"

image_name = "Debian 10 ppc64le"
flavor_name = "minicloud.tiny"

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
our Terraform's AWS vars.tf assumes ~/.aws/credentials as the default
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

ssh_config_pubkey_file = "~/.ssh/my-aws.pub"
ssh_config_user = "mcgrof"
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To read more about shared credentials refer to:

  * https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
  * https://docs.aws.amazon.com/powershell/latest/userguide/shared-credentials-in-aws-powershell.html

### GCE - Google Compute Engine

This Ansible role also supports the GCE on Terraform. Below is an example
terraform.tfvars you may end up with:

```
project = "demo-kdevops"

ssh_config_pubkey_file = "~/.ssh/my-gce.pub"
ssh_config_user = "mcgrof"
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To ramp up, you'll need to get the JSON for your service account through
the Identity and Access Management (IAM) interface. This is documented below.
The default name for the JSON credentials file is account.json, you can
override this and its path with:

```
credentials = /home/foo/path/to/some.json
```

https://www.terraform.io/docs/providers/google/getting_started.html
https://www.terraform.io/docs/providers/google/index.html
https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource

### OCI - Oracle Cloud Infrastructure
OCI documentation is located at
1. https://docs.oracle.com/en-us/iaas/Content/home.htm
2. https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraform.htm

The following is a list of OCI specific configuration variables that the user
needs to provide values (through `make menuconfig` interface).
  1. `CONFIG_TERRAFORM_SSH_CONFIG_USER`
	 - User name used for the logging into the cloud instance.
     - Please use,
	   - `opc` for Oracle Linux.
	   - `ubuntu` for Ubuntu Linux
  2. `CONFIG_TERRAFORM_SSH_CONFIG_PUBKEY_FILE`
     - Path to user's ssh public key (e.g. `~/.ssh/id_rsa.pub`).
     - This key will be copied over to the cloud instance during its
       creation.
  3. `CONFIG_TERRAFORM_OCI_REGION`
	 - String representing the name of the region (e.g. `us-ashburn-1`).
     - https://docs.oracle.com/en-us/iaas/Content/anomaly/using/regions.htm
     - List of the regions can be found at
       https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm 
  4. `CONFIG_TERRAFORM_OCI_TENANCY_OCID`
	 - OCID of the tenancy being used.
     - In order to obtain the OCID, Please refer to
	   https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Finding_Your_Tenancy_OCID_Oracle_Cloud_Identifier.htm 
  5. `CONFIG_TERRAFORM_OCI_USER_OCID`
	 - OCID of the user.
     - In order to obtain the OCID, Please refer to
       https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
  6. `CONFIG_TERRAFORM_OCI_USER_PRIVATE_KEY_PATH`
	 - Path to API private key.
	 - Documentation
	   - Generating API keys.
	     Refer to section `Generating an API Signing Key (Linux and Mac OS X)`
	     at
	     https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm
	   - Uploading Public API key.
	     Refer to section `How to Upload the Public Key` at
	     https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm 
       - Video: https://www.youtube.com/watch?v=LMvYOSkXF1k
  7. `CONFIG_TERRAFORM_OCI_USER_FINGERPRINT`
     - Finger print of the API key.
  8. `CONFIG_TERRAFORM_OCI_AVAILABLITY_DOMAIN` ="VkEH:US-ASHBURN-AD-3"
     - String specifying the availability domain to use in the region
	 - Availability domain names can be obtained from the web page used to
       launch an cloud instance.
  9. `CONFIG_TERRAFORM_OCI_COMPARTMENT_OCID`
	 - OCID of the compartment can be obtained by following the instructions
	   at
	   https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Finding_the_OCID_of_a_Compartment.htm
  10. `CONFIG_TERRAFORM_OCI_SHAPE`="VM.Standard.E2.8"
      - String representing the name of the compute shape to create.
      - https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
  11. `CONFIG_TERRAFORM_OCI_OS_IMAGE_OCID`
	  - OCID of the OS image to be installed.
      - Image's OCID can be obtained by following instructions at
	    https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformbestpractices_topic-Referencing_Images.htm
  12. `CONFIG_TERRAFORM_OCI_SUBNET_OCID`
	  - OCID of the subnet to be assigned to the cloud instance.
      - Overview:
        https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/Overview_of_VCNs_and_Subnets.htm
      - Instructions on how to get a list of available subnets can be found at
        https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/get-subnet.htm 
      - Click on the hamburger menu provided the right side of a subnet entry
        and select `Copy OCID`.
  13. `CONFIG_TERRAFORM_OCI_DATA_VOLUME_DISPLAY_NAME`
	  - String representing the name for the `data` disk.
      - This is used for storing sources and binaries corresponding to Linux
        kernel, Fstests & Kdevops.
  14. `CONFIG_TERRAFORM_OCI_DATA_VOLUME_DEVICE_FILE_NAME`
      - Device node to be used for `data` disk.
      - Please specify `/dev/oracleoci/oraclevdb` as the device file.
  15. `CONFIG_TERRAFORM_OCI_SPARSE_VOLUME_DISPLAY_NAME`
	  - String representing the name for the `sparse` disk.
      - This is used for creating regular files to back loop devices.
  16. `CONFIG_TERRAFORM_OCI_SPARSE_VOLUME_DEVICE_FILE_NAME`
      - Device node to be used for `sparse` disk.
      - Please specify `/dev/oracleoci/oraclevdc` as the device file.
  17. `CONFIG_TERRAFORM_OCI_INSTANCE_FLEX_OCPUS`
      - Number of OCPUs for a flexiable compute shape.
      - https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm#flexible
  18. `CONFIG_TERRAFORM_OCI_INSTANCE_FLEX_MEMORY_IN_GBS`
      - Amount of RAM in GB for a flexiable compute shape.
      - https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm#flexible
