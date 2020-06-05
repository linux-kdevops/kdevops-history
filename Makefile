# Perhaps you use a different location for these. These helpers
# allow your project to define these and just include this file.
KDEVOPS_TERRAFORM_DIR ?=	terraform
KDEVOPS_PLAYBOOKS_DIR ?=	playbooks
KDEVOPS_HOSTFILE ?=		hosts

all: kdevops_all
PHONY := all

kdevops_all: kdevops_deps
PHONY := kdevops_all

kdevops_terraform_deps:
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/install_terraform.yml
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_terraform.yml 
	@if [ -d $(KDEVOPS_TERRAFORM_DIR) ]; then \
		make -C $(KDEVOPS_TERRAFORM_DIR) deps; \
	fi
PHONY += kdevops_terraform_deps

kdevops_vagrant_deps:
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/install_vagrant.yml
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/libvirt_user.yml
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_vagrant.yml
PHONY += kdevops_vagrant_deps

verify-vagrant-user:
	@ansible-playbook -i hosts $(KDEVOPS_PLAYBOOKS_DIR)/libvirt_user.yml -e "only_verify_user=True"
PHONY += verify-vagrant-user

kdevops_ansible_deps:
	@ansible-galaxy install --force -r requirements.yml
PHONY += kdevops_ansible_deps

kdevops_deps: kdevops_ansible_deps kdevops_terraform_deps kdevops_vagrant_deps
	@echo Installed dependencies
PHONY += kdevops_deps

kdevops_terraform_clean:
	@if [ -d $(KDEVOPS_TERRAFORM_DIR) ]; then \
		make -C $(KDEVOPS_TERRAFORM_DIR) clean ; \
	fi
PHONY += kdevops_terraform_clean

kdevops_clean: kdevops_terraform_clean
	@echo Cleaned up
PHONY += kdevops_clean

.PHONY: $(PHONY)
