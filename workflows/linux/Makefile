# SPDX-License-Identifier: copyleft-next-0.3.1

TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_NAME:=$(subst .git,,$(TREE_NAME))
TREE_TAG:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_TAG))
TREE_LOCALVERSION:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_LOCALVERSION))
TREE_SHALLOW_DEPTH:=$(subst ",,$(CONFIG_BOOTLINUX_SHALLOW_CLONE_DEPTH))

TREE_CONFIG:=config-$(TREE_TAG)

# Describes the Linux clone
BOOTLINUX_ARGS	+= target_linux_git=$(TREE_URL)
BOOTLINUX_ARGS	+= target_linux_tree=$(TREE_NAME)
BOOTLINUX_ARGS	+= target_linux_tag=$(TREE_TAG)
BOOTLINUX_ARGS	+= target_linux_config=$(TREE_CONFIG)
BOOTLINUX_ARGS	+= target_linux_localversion=$(TREE_LOCALVERSION)

ifeq (y,$(CONFIG_BOOTLINUX_SHALLOW_CLONE))
TREE_SHALLOW_DEPTH:=$(subst ",,$(CONFIG_BOOTLINUX_SHALLOW_CLONE_DEPTH))
BOOTLINUX_ARGS	+= target_linux_shallow_depth=$(TREE_SHALLOW_DEPTH)
endif

ifeq (y,$(CONFIG_WORKFLOW_MAKE_CMD_OVERRIDE))
BOOTLINUX_ARGS	+= target_linux_make_cmd='$(WORKFLOW_MAKE_CMD)'
endif

ifeq (y,$(CONFIG_BOOTLINUX_TEST_MESSAGE_ID))
BOOTLINUX_ARGS	+= target_linux_apply_patch_message_id='$(CONFIG_BOOTLINUX_TEST_MESSAGE_ID_THREAD_ID)'
BOOTLINUX_ARGS	+= target_linux_install_b4='$(CONFIG_BOOTLINUX_TEST_MESSAGE_ID_INSTALL_B4)'
endif


WORKFLOW_ARGS += $(BOOTLINUX_ARGS)
linux-help-menu:
	@echo "Linux git kernel development options"
	@echo "linux              - Git clones a linux git tree, build linux and reboots into it"
	@echo "linux-grub-setup   - Ensures the appropriate target kernel is set to boot"
	@echo "linux-reboot       - Reboot guests"
	@echo "uname              - Prints current running kernel"
	@echo ""

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

PHONY += linux-grub-setup
linux-grub-setup: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags manual-update-grub,saved,vars

PHONY += linux-reboot
linux-reboot: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags vars,reboot

PHONY += uname
uname: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags uname,vars

HELP_TARGETS+=linux-help-menu
