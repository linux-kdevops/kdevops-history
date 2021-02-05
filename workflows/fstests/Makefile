KDEVOPS_INSTALL_TARGETS += kdevops_fstests_install
KDEVOPS_FSTESTS_SCRIPTS_PATH=workflows/fstests/scripts

KDEVOPS_FSTESTS_PROGS :=
KDEVOPS_FSTESTS_PROGS += $(KDEVOPS_FSTESTS_SCRIPTS_PATH)/gendisks.sh
KDEVOPS_FSTESTS_PROGS += $(KDEVOPS_FSTESTS_SCRIPTS_PATH)/oscheck.sh
KDEVOPS_FSTESTS_PROGS += $(KDEVOPS_FSTESTS_SCRIPTS_PATH)/naggy-check.sh

KDEVOPS_FSTESTS_BASHRC :=  workflows/fstests/.bashrc
KDEVOPS_FSTESTS_SETUP_FILE := .kdevops_fstests_setup
KDEVOPS_FSTESTS_SETUP_FILE_DEST := $(HOME)/$(KDEVOPS_FSTESTS_SETUP_FILE)

FSTESTS=$(subst ",,$(CONFIG_FSTESTS_DATA_TARGET))
FSTESTS_CONFIGS?= $(FSTESTS)/configs
FSTESTS_SETUP_SYSTEM=$(subst ",,$(CONFIG_FSTESTS_SETUP_SYSTEM))
FSTESTS_TEST_DEV=$(subst ",,$(CONFIG_FSTESTS_TEST_DEV))

HOSTNAME := $(shell hostname)
HOSTNAME_CONFIG := $(HOSTNAME).config
ID=$(shell id -u)
BASHRC?= $(HOME)/.bashrc

FSTESTS_ARGS	:=

export FSTYP:=$(subst ",,$(CONFIG_FSTESTS_FSTYP))
KDEVOPS_FSTESTS_CONFIG := workflows/fstests/$(FSTYP)/$(FSTYP).config
KDEVOPS_FSTESTS_CONFIG_TEMPLATE := $(KDEVOPS_FSTESTS_CONFIG).in

KDEVOPS_WORKFLOW_FSTESTS_CLEAN += $(KDEVOPS_FSTESTS_CONFIG)

# We don't use a nodes template for fstests, the file is generated from
# a start file and post file. We set this to empty to ensure it doesn't
# fall as a dependency.
export KDEVOPS_NODES_TEMPLATE :=

export KDEVOPS_HOSTS_TEMPLATE := workflows/fstests/$(FSTYP)/hosts_generated.in
KDEVOPS_WORKFLOW_FSTESTS_CLEAN += $(KDEVOPS_HOSTS_TEMPLATE)
FSTESTS_DATA:=$(subst ",,$(CONFIG_FSTESTS_DATA))
FSTESTS_DATA_TARGET:=$(subst ",,$(CONFIG_FSTESTS_DATA_TARGET))

TARGET_CONFIG := $(FSTESTS_CONFIGS)/$(HOSTNAME_CONFIG)

FSTESTS_ARGS += fstests_fstyp='$(FSTYP)'
FSTESTS_ARGS += fstests_data=\"$(FSTESTS_DATA)\"
FSTESTS_ARGS += fstests_setup_system='$(FSTESTS_SETUP_SYSTEM)'
FSTESTS_ARGS += fstests_data_target='$(FSTESTS_DATA_TARGET)'
FSTESTS_ARGS += fstests_test_dev='$(FSTESTS_TEST_DEV)'

export FSTESTS_SPARSE_FILE_SIZE:=
export FSTESTS_TESTDEV_SPARSEFILE_GENERATION:=
export FSTESTS_SPARSE_FILE_PATH:=
export FSTESTS_SPARSE_FILENAME_PREFIX:=

SPARSE_GEN:=$(subst ",,$(CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION))
FSTESTS_ARGS += sparsefiles_generation='$(SPARSE_GEN)'

ifeq (y,$(CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION))

export FSTESTS_TESTDEV_SPARSEFILE_GENERATION:=y
SPARSE_DEV:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_DEV))
export FSTESTS_SPARSE_FILE_PATH:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_FILE_PATH))
SPARSE_FSTYPE:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_FSTYPE))
SPARSE_LABEL:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_LABEL))
export FSTESTS_SPARSE_FILE_SIZE:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_FILE_SIZE))
export FSTESTS_SPARSE_FILENAME_PREFIX:=$(subst ",,$(CONFIG_FSTESTS_SPARSE_FILENAME_PREFIX))

FSTESTS_ARGS += sparsefiles_device='$(SPARSE_DEV)'
FSTESTS_ARGS += sparsefiles_path='$(FSTESTS_SPARSE_FILE_PATH)'
FSTESTS_ARGS += sparsefiles_fstype='$(SPARSE_FSTYPE)'
FSTESTS_ARGS += sparsefiles_label='$(SPARSE_LABEL)'
FSTESTS_ARGS += sparsefiles_fs_opts='-L$(SPARSE_LABEL)'
FSTESTS_ARGS += sparsefiles_size='$(FSTESTS_SPARSE_FILE_SIZE)'
FSTESTS_ARGS += sparsefiles_filename_prefix='$(FSTESTS_SPARSE_FILENAME_PREFIX)'

endif # CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION == y
WORKFLOW_ARGS += $(FSTESTS_ARGS)

FSTEST_KERNEL_CI_LOOP := false
ifeq (y,$(CONFIG_KERNEL_CI))
FSTEST_KERNEL_CI_LOOP := scripts/workflows/fstests/run_kernel_ci.sh
endif # CONFIG_KERNEL_CI

$(KDEVOPS_HOSTS_TEMPLATE): .config
	$(Q)$(TOPDIR)/scripts/workflows/fstests/$(FSTYP)/gen_manual_hosts.sh

$(KDEVOPS_FSTESTS_CONFIG): $(KDEVOPS_FSTESTS_CONFIG_TEMPLATE) .config
	$(Q)$(TOPDIR)/scripts/workflows/fstests/gen_fstests_config.sh $(KDEVOPS_FSTESTS_CONFIG)

fstests:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/workloads_shared.yml
	$(Q)ansible-playbook -f 30 -i hosts playbooks/fstests.yml --skip-tags run_tests,copy_results

fstests-baseline:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

fstests-baseline-loop:
	$(Q)$(FSTEST_KERNEL_CI_LOOP) baseline

fstests-baseline-skip-kdevops-update:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --skip-tags git_update --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

fstests-baseline-run-oscheck-only:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --skip-tags git_update,reboot,clean_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

fstests-dev:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/fstests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

fstests-baseline-results:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

fstests-dev-results:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/fstests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml

kdevops_fstests_install: $(KDEVOPS_FSTESTS_PROGS) $(KDEVOPS_FSTESTS_CONFIG)
	@if [ $(ID) != "0" ]; then \
		echo "Must run as root" ;\
		exit 1 ;\
	fi
	@mkdir -p $(FSTESTS) $(FSTESTS_SPARSE_FILE_PATH)
	@$(foreach var,$(KDEVOPS_FSTESTS_PROGS), \
		if [ ! -f $(FSTESTS)/$(var) ]; then \
			echo SYMLINK $(var) on $(FSTESTS); \
			ln -sf $(shell readlink -f $(var)) $(FSTESTS); \
		fi; \
		)
	@if [ -f $(BASHRC) ]; then \
		if ! grep $(KDEVOPS_FSTESTS_SETUP_FILE) $(BASHRC) 2>&1 > /dev/null ; then \
			echo "REFER $(KDEVOPS_FSTESTS_SETUP_FILE) on $(BASHRC)" ;\
			cat $(KDEVOPS_FSTESTS_BASHRC) >> $(BASHRC) ;\
		fi \
	else \
		echo "INSTALL $(BASHRC)" ;\
		echo "#!/bin/bash" >> $(BASHRC) ;\
		cat .bashrc >> $(BASHRC) ;\
		chmod 755 $(BASHRC) ;\
	fi
	@echo INSTALL $(KDEVOPS_FSTESTS_SETUP_FILE) $(HOME)
	@echo "#!/bin/bash" > $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTYP='$(FSTYP)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTESTS_SPARSE_FILE_PATH='$(FSTESTS_SPARSE_FILE_PATH)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTESTS_SETUP_SYSTEM='$(FSTESTS_SETUP_SYSTEM)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTESTS_TESTDEV_SPARSEFILE_GENERATION='$(FSTESTS_TESTDEV_SPARSEFILE_GENERATION)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTESTS_SPARSE_FILE_SIZE='$(FSTESTS_SPARSE_FILE_SIZE)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export FSTESTS_SPARSE_FILENAME_PREFIX='$(FSTESTS_SPARSE_FILENAME_PREFIX)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@echo "export TEST_DEV='$(FSTESTS_TEST_DEV)'" >> $(KDEVOPS_FSTESTS_SETUP_FILE_DEST)
	@mkdir -p $(FSTESTS_CONFIGS)
	@echo INSTALL $(HOSTNAME_CONFIG)  $(FSTESTS_CONFIGS)
	@if [ ! -f $(KDEVOPS_FSTESTS_CONFIG) ]; then \
		echo "Unsupported filesystem: $(FSTYP)" ;\
		echo "Consider adding an example fstests config in $(KDEVOPS_FSTESTS_CONFIG) and submit to kdevops upstream" ;\
		exit 1 ;\
	fi
	@install $(KDEVOPS_FSTESTS_CONFIG) $(TARGET_CONFIG)
	@echo INSTALL $(HOSTNAME_CONFIG)  $(FSTESTS_CONFIGS)/.config
	@install $(KDEVOPS_FSTESTS_CONFIG) $(FSTESTS_CONFIGS)/.config
