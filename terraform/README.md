# Terraform setup

Terraform will be used instead of Vagrant for cloud solutions such as
Azure, AWS, OpenStack.

Vagrant can still be used to provision via ansible, this is done after the
guests are up, by kicking off vagrant for a managed server:

https://github.com/tknerr/vagrant-managed-servers

Node configuration is shared, and by default kdevops relies on the file
../vagrant/nodes.yaml however you can override this by using the environment
variable:

  * TN_VAR_DEVOPS_NODE_CONFIG

## Azure

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
# Do not check this into SCM.
client_certificate_path = "./service-principal.pfx"
client_certificate_password = "my-cool-passworsd"
tenant_id = "SOME-GUID"
application_id = "SOME-GUID"
subscription_id = "SOME-GUID"
ssh_username = "yourcoolusername"
ssh_pubkey_data = "ssh-rsa AAASNIP"
```

## Openstack

Openstack is supported now. This has been tested with the minicloud openstack.
This solution relies on the new clouds.yaml file for openstack configuration.
This simplifies things considerably.

Since minicoud is an example cloud solution and, since it also has a custom
setup where the you have to ssh with a special port depending on the IP address
you get, if you enable minicloud we do this computation for you and tell you
where to ssh to.
