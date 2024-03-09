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

ifeq (y,$(CONFIG_KDEVOPS_SETUP_SIW))
KDEVOPS_BRING_UP_DEPS += siw
endif # KDEVOPS_SETUP_SIW

bringup: $(KDEVOPS_BRING_UP_DEPS)

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

bringup-setup-help-end:
	@echo ""

HELP_TARGETS += bringup-setup-help-end
