# SPDX-License-Identifier: copyleft-next-0.3.1

FSTESTS=$(subst ",,$(CONFIG_FSTESTS_DATA_TARGET))
FSTESTS_SETUP_SYSTEM=$(subst ",,$(CONFIG_FSTESTS_SETUP_SYSTEM))
FSTESTS_TEST_DEV=$(subst ",,$(CONFIG_FSTESTS_TEST_DEV))

FSTESTS_ARGS	        :=
FSTESTS_ARGS_SEPARATED	:=

export FSTYP:=$(subst ",,$(CONFIG_FSTESTS_FSTYP))

ifeq (y,$(CONFIG_WORKFLOWS_DEDICATED_WORKFLOW))
export KDEVOPS_HOSTS_TEMPLATE := fstests.j2
endif

FSTESTS_GIT:=$(subst ",,$(CONFIG_FSTESTS_GIT))
FSTESTS_DATA:=$(subst ",,$(CONFIG_FSTESTS_DATA))
FSTESTS_DATA_TARGET:=$(subst ",,$(CONFIG_FSTESTS_DATA_TARGET))

FSTESTS_ARGS += fstests_git=$(FSTESTS_GIT)
FSTESTS_ARGS += fstests_fstyp='$(FSTYP)'
FS_CONFIG='$(FSTYP)/$(FSTYP).config'
FSTESTS_ARGS += fs_config_role_path='roles/fstests/templates/$(FS_CONFIG)'
FSTESTS_ARGS += fstests_data=\"$(FSTESTS_DATA)\"
FSTESTS_ARGS += fstests_setup_system='$(FSTESTS_SETUP_SYSTEM)'
FSTESTS_ARGS += fstests_data_target='$(FSTESTS_DATA_TARGET)'
FSTESTS_ARGS += fstests_test_dev='$(FSTESTS_TEST_DEV)'

ifeq (y,$(CONFIG_QEMU_ENABLE_NVME_ZNS))
FSTESTS_ARGS += fstests_test_dev_zns='$(subst ",,$(CONFIG_FSTESTS_TEST_DEV_ZNS))'
FSTESTS_ARGS += fstests_zns_enabled='$(subst ",,$(CONFIG_QEMU_ENABLE_NVME_ZNS))'
endif

export FSTESTS_SPARSE_FILE_SIZE:=
export FSTESTS_TESTDEV_SPARSEFILE_GENERATION:=
export FSTESTS_SPARSE_FILE_PATH:=
export FSTESTS_SPARSE_FILENAME_PREFIX:=
export FSTESTS_SCRATCH_MNT:=
export FSTESTS_LOGWRITES_DEV:=

FSTESTS_TEST_DIR:=$(subst ",,$(CONFIG_FSTESTS_TEST_DIR))
FSTESTS_ARGS += fstests_test_dir='$(FSTESTS_TEST_DIR)'

FSTESTS_SCRATCH_MNT:=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_MNT))
FSTESTS_ARGS += fstests_scratch_mnt='$(FSTESTS_SCRATCH_MNT)'

FSTESTS_LOGWRITES_DEV:=$(subst ",,$(CONFIG_FSTESTS_LOGWRITES_DEV))
FSTESTS_ARGS += fstests_logwrites_dev='$(FSTESTS_LOGWRITES_DEV)'

FSTESTS_SCRATCH_LOGDEV:=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_LOGDEV))
FSTESTS_ARGS += fstests_scratch_logdev='$(FSTESTS_SCRATCH_LOGDEV)'

FSTESTS_SCRATCH_RTDEV:=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_RTDEV))
FSTESTS_ARGS += fstests_scratch_rtdev='$(FSTESTS_SCRATCH_RTDEV)'

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
export FSTESTS_RUN_LARGE_DISK_TESTS:=$(subst ",,$(CONFIG_FSTESTS_RUN_LARGE_DISK_TESTS))
export FSTESTS_RUN_AUTO_GROUP_TESTS:=$(subst ",,$(CONFIG_FSTESTS_RUN_AUTO_GROUP_TESTS))
export FSTESTS_RUN_CUSTOM_GROUP_TESTS:=$(subst ",,$(CONFIG_FSTESTS_RUN_CUSTOM_GROUP_TESTS))


FSTESTS_ARGS += sparsefiles_device='$(SPARSE_DEV)'
FSTESTS_ARGS += sparsefiles_path='$(FSTESTS_SPARSE_FILE_PATH)'
FSTESTS_ARGS += sparsefiles_fstype='$(SPARSE_FSTYPE)'
FSTESTS_ARGS += sparsefiles_label='$(SPARSE_LABEL)'
FSTESTS_ARGS += sparsefiles_fs_opts='-L$(SPARSE_LABEL)'
FSTESTS_ARGS += sparsefiles_size='$(FSTESTS_SPARSE_FILE_SIZE)'
FSTESTS_ARGS += sparsefiles_filename_prefix='$(FSTESTS_SPARSE_FILENAME_PREFIX)'
FSTESTS_ARGS += run_large_disk_tests='$(FSTESTS_RUN_LARGE_DISK_TESTS)'
FSTESTS_ARGS += run_auto_group_tests='$(FSTESTS_RUN_AUTO_GROUP_TESTS)'
FSTESTS_ARGS += run_custom_group_tests='$(FSTESTS_RUN_CUSTOM_GROUP_TESTS)'

ifeq (y,$(CONFIG_FSTESTS_ENABLE_RUN_CUSTOM_TESTS))
export FSTESTS_CUSTOM_TESTS:=$(subst ",,$(CONFIG_FSTESTS_RUN_CUSTOM_TESTS))
FSTESTS_ARGS_SEPARATED += limit_tests='$(subst $(space),+,$(FSTESTS_CUSTOM_TESTS))'
endif

FSTESTS_SCRATCH_DEVPOOL=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_DEV_POOL))
FSTESTS_ARGS_SEPARATED += fstests_scratch_devpool='$(subst $(space),+,$(FSTESTS_SCRATCH_DEVPOOL))'

endif # CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION == y

ifeq (y,$(CONFIG_QEMU_ENABLE_NVME_ZNS))
FSTESTS_SCRATCH_DEVPOOL_ZNS=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_DEV_POOL_ZNS))
FSTESTS_ARGS_SEPARATED += fstests_scratch_devpool_zns='$(subst $(space),+,$(FSTESTS_SCRATCH_DEVPOOL_ZNS))'
endif # CONFIG_QEMU_ENABLE_NVME_ZNS

WORKFLOW_ARGS += $(FSTESTS_ARGS)
WORKFLOW_ARGS_SEPARATED += $(FSTESTS_ARGS_SEPARATED)

FSTEST_KERNEL_CI_LOOP := false
FSTEST_KERNEL_CI_LOOP_KOTD := false
ifeq (y,$(CONFIG_KERNEL_CI))
FSTEST_KERNEL_CI_LOOP := scripts/workflows/fstests/run_kernel_ci.sh
FSTEST_KERNEL_CI_LOOP_KOTD := scripts/workflows/fstests/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

fstests:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/fstests.yml --skip-tags run_tests,copy_results $(LIMIT_HOSTS)

fstests-kdevops-setup: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts playbooks/fstests.yml --tags vars,kdevops_fstests_setup $(LIMIT_HOSTS)

fstests-baseline:
	$(Q)PYTHONUNBUFFERED=1 ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-loop: $(KDEVOPS_EXTRA_VARS)
	$(Q)$(FSTEST_KERNEL_CI_LOOP) baseline $(LIMIT_HOSTS)

fstests-baseline-kernelci: $(KDEVOPS_EXTRA_VARS)
	$(Q)$(FSTEST_KERNEL_CI_LOOP_KOTD) baseline $(LIMIT_HOSTS)

fstests-baseline-skip-kdevops-update: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --skip-tags git_update --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-run-oscheck-only: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags run_tests,copy_results --skip-tags git_update,reboot,clean_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-dev: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/fstests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-results: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/fstests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-dev-results: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/fstests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_fstests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-help-menu:
	@echo "fstests options:"
	@echo "fstests                                 - Git clones fstests, builds and install it"
	@echo "fstests-kdevops-setup                   - Install kdevops specific files, the fstests and running test targets also runs this"
	@echo "fstests-baseline                        - Run fstests on baseline hosts and collect results"
	@echo "fstests-dev                             - Run fstests on dev hosts and collect results"
	@echo "fstests-baseline-results                - Only collect results for baseline hosts"
	@echo "fstests-dev-results                     - Only collect results for dev hosts"
	@echo "fstests-baseline-skip-kdevops-update    - Run fstests but skip updating kdevops"
	@echo "fstests-baseline-run-oscheck-only       - Only run oscheck"
	@echo "fstests-baseline-loop                   - Run fstests in a loop until a failure is found or steady state is reached"
	@echo "fstests-baseline-kernelci               - Run fstests kernel-ci loop"
	@echo ""

HELP_TARGETS += fstests-help-menu
