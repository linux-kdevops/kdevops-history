# SPDX-License-Identifier: copyleft-next-0.3.1

ifeq (,$(wildcard $(CURDIR)/.config))
else
# stage-2-y targets gets called after all local config files have been generated
stage-2-$(CONFIG_TERRAFORM)			+= kdevops_terraform_deps
stage-2-$(CONFIG_LIBVIRT_INSTALL)	+= kdevops_install_libvirt
stage-2-$(CONFIG_LIBVIRT_CONFIGURE)	+= kdevops_configure_libvirt
stage-2-$(CONFIG_VAGRANT)			+= kdevops_vagrant_install_vagrant
stage-2-$(CONFIG_VAGRANT_INSTALL_PRIVATE_BOXES)	+= kdevops_vagrant_boxes
stage-2-$(CONFIG_LIBVIRT_VERIFY)	+= kdevops_verify_libvirt_user
stage-2-$(CONFIG_LIBVIRT_STORAGE_POOL_CREATE)	+= kdevops_libvirt_storage_pool_create

kdevops_stage_2: .config
	$(Q)$(MAKE) -f Makefile.kdevops $(stage-2-y)

ifneq (,$(stage-2-y))
DEFAULT_DEPS += kdevops_stage_2
endif

endif

ifeq (y,$(CONFIG_KDEVOPS_SETUP_NFSD))
KDEVOPS_BRING_UP_DEPS += nfsd
endif # KDEVOPS_SETUP_NFSD

ifeq (y,$(CONFIG_KDEVOPS_SETUP_KTLS))
KDEVOPS_BRING_UP_DEPS += ktls
KDEVOPS_DESTROY_DEPS += ktls-destroy
endif # KDEVOPS_SETUP_KTLS

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE))

JOURNAL_REMOTE:=$(subst ",,$(CONFIG_DEVCONFIG_SYSTEMD_JOURNAL_REMOTE_URL))
ANSIBLE_EXTRA_ARGS += devconfig_systemd_journal_remote_url=$(JOURNAL_REMOTE)
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_journal_remote='True'

journal-client:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--extra-vars '{ kdevops_cli_install: True }' \
		--tags vars_simple,journal \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-server:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/install_systemd_journal_remote.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

journal-restart:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal-upload-restart \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-status:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal-status \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-ls:
	@$(Q)./workflows/kdevops/scripts/jounal-ls.sh /var/log/journal/remote/

journal-ln:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal_ln \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

KDEVOPS_BRING_UP_DEPS += journal-server

endif

update_etc_hosts:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts playbooks/update_etc_hosts.yml

bringup: $(KDEVOPS_BRING_UP_DEPS) update_etc_hosts

destroy: $(KDEVOPS_DESTROY_DEPS)

bringup-help-menu:
	@echo "Bringup targets:"
	@echo "bringup            - Brings up target hosts"
	@echo "destroy            - Destroy all target hosts"
	@echo "cleancache	  - Remove all cached images"
	@echo ""

HELP_TARGETS+=bringup-help-menu

bringup-setup-help-menu:
	@echo "Generic bring up set up targets:"
	@echo "kdevops-deps        - Installs what we need on the localhost"

HELP_TARGETS += bringup-setup-help-menu

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE))
journal-help:
	@echo "journal-server	   - Setup systemd-journal-remote on localhost"
	@echo "journal-client	   - Setup systemd-journal-upload on clients"
	@echo "journal-restart	   - Restart client upload service"
	@echo "journal-status	   - Ensure systemd-journal-remote works"
	@echo "journal-ls          - List journals available and sizes"
	@echo "journal-ln          - Add symlinks with hostnames"

HELP_TARGETS += journal-help
endif

bringup-setup-help-end:
	@echo ""

HELP_TARGETS += bringup-setup-help-end
