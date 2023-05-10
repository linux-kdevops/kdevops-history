# SPDX-License-Identifier: copyleft-next-0.3.1

TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_NAME:=$(subst .git,,$(TREE_NAME))
TREE_TAG:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_TAG))
TREE_LOCALVERSION:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_LOCALVERSION))
TREE_SHALLOW_DEPTH:=$(subst ",,$(CONFIG_BOOTLINUX_SHALLOW_CLONE_DEPTH))

TREE_CONFIG:=config-$(TREE_TAG)
ifeq (y,$(CONFIG_BOOTLINUX_PURE_IOMAP))
TREE_CONFIG:=config-$(TREE_TAG)-pure-iomap
endif

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

LINUX_CLONE_DEFAULT_TYPE := linux-clone-clients
ifeq (y,$(CONFIG_BOOTLINUX_9P))
BOOTLINUX_ARGS	+= bootlinux_9p=True
BOOTLINUX_ARGS	+= bootlinux_9p_host_path='$(subst ",,$(CONFIG_BOOTLINUX_9P_HOST_PATH))'
BOOTLINUX_ARGS	+= bootlinux_9p_msize='$(subst ",,$(CONFIG_BOOTLINUX_9P_MSIZE))'
BOOTLINUX_ARGS	+= bootlinux_9p_fsdev='$(subst ",,$(CONFIG_BOOTLINUX_9P_FSDEV))'
BOOTLINUX_ARGS	+= bootlinux_9p_security_model='$(subst ",,$(CONFIG_BOOTLINUX_9P_SECURITY_MODEL))'
BOOTLINUX_ARGS	+= bootlinux_9p_driver='$(subst ",,$(CONFIG_BOOTLINUX_9P_DRIVER))'
BOOTLINUX_ARGS	+= bootlinux_9p_mount_tag='$(subst ",,$(CONFIG_BOOTLINUX_9P_MOUNT_TAG))'
LINUX_CLONE_DEFAULT_TYPE := linux-clone-9p
endif

BOOTLINUX_ARGS += bootlinux_cxl_test=$(CONFIG_ENABLE_CXL_TEST)
WORKFLOW_ARGS += $(BOOTLINUX_ARGS)

PHONY +=  linux-help-menu
linux-help-menu:
	@echo "Linux git kernel development options"
	@echo "linux              - Git clones a linux git tree, build Linux, installs and reboots into it"
	@echo "linux-deploy       - Builds, installs, updates GRUB and reboots - useful for rapid development"
	@echo "linux-install      - Only builds and installs Linux"
	@echo "linux-clone        - Only clones Linux"
	@echo "linux-grub-setup   - Ensures the appropriate target kernel is set to boot"
	@echo "linux-reboot       - Reboot guests"
	@echo "uname              - Prints current running kernel"

PHONY += linux-help-end
linux-help-end:
	@echo ""

LINUX_HELP_EXTRA :=

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

PHONY += linux-deploy
linux-deploy: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--tags vars,build-linux,install-linux,manual-update-grub,saved,vars,reboot \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

PHONY += linux-install
linux-install: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--tags vars,build-linux,install-linux \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

linux-clone-clients: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) \
		--tags vars,deps,clone

PHONY += linux-clone-9p
linux-clone-9p: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		--extra-vars="$(BOOTLINUX_ARGS)" \
		--tags vars,deps,clone

PHONY += linux-clone
linux-clone: $(KDEVOPS_NODES) $(LINUX_CLONE_DEFAULT_TYPE)

PHONY += linux-grub-setup
linux-grub-setup: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags manual-update-grub,saved,vars

PHONY += linux-reboot
linux-reboot: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags vars,reboot

PHONY += uname
uname: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS) --tags uname,vars

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_CXL))
PHONY += linux-cxl
linux-cxl: $(KDEVOPS_NODES)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--tags 'vars,cxl-build,cxl-install'                             \
		--extra-vars="$(BOOTLINUX_ARGS)" $(LIMIT_HOSTS)

PHONY += linux-help-cxl
linux-help-cxl:
	@echo "linux-cxl          - Builds cxl_test only and installs it"

LINUX_HELP_EXTRA += linux-help-cxl
endif

HELP_TARGETS+=linux-help-menu
HELP_TARGETS+=$(LINUX_HELP_EXTRA)
HELP_TARGETS+=linux-help-end
