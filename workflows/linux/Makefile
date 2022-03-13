# SPDX-License-Identifier: copyleft-next-0.3.1

TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_NAME:=$(subst .git,,$(TREE_NAME))
TREE_TAG:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_TAG))

TREE_CONFIG:=config-$(TREE_TAG)

# Describes the Linux clone
BOOTLINUX_ARGS	+= target_linux_git=$(TREE_URL)
BOOTLINUX_ARGS	+= target_linux_tree=$(TREE_NAME)
BOOTLINUX_ARGS	+= target_linux_tag=$(TREE_TAG)
BOOTLINUX_ARGS	+= target_linux_config=$(TREE_CONFIG)

ifeq (y,$(CONFIG_WORKFLOW_MAKE_CMD_OVERRIDE))
BOOTLINUX_ARGS	+= target_linux_make_cmd='$(WORKFLOW_MAKE_CMD)'
endif

WORKFLOW_ARGS += $(BOOTLINUX_ARGS)
linux-help-menu:
	@echo "Linux git kernel development options"
	@echo "linux              - Git clones a linux git tree, build linux and reboots into it"
	@echo ""

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

HELP_TARGETS+=linux-help-menu
