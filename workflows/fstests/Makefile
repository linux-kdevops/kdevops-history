# SPDX-License-Identifier: copyleft-next-0.3.1

FSTESTS=$(subst ",,$(CONFIG_FSTESTS_DATA_TARGET))
FSTESTS_SETUP_SYSTEM=$(subst ",,$(CONFIG_FSTESTS_SETUP_SYSTEM))
FSTESTS_TEST_DEV=$(subst ",,$(CONFIG_FSTESTS_TEST_DEV))

FSTESTS_ARGS	        :=
FSTESTS_ARGS_SEPARATED	:=
FSTESTS_ARGS_DIRECT :=

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

ifeq (y,$(CONFIG_FSTESTS_TFB_COPY_ENABLE))
FSTESTS_ARGS += fstests_tfp_copy_enable='True'
endif


ifeq (y,$(CONFIG_FSTESTS_NFS))
FSTESTS_ARGS += fstests_nfs_enable='True'
FSTESTS_NFS_SERVER_HOST:=$(subst ",,$(CONFIG_FSTESTS_NFS_SERVER_HOST))
ifeq (y,$(CONFIG_FSTESTS_USE_KDEVOPS_NFSD))
FSTESTS_NFS_SERVER_HOST:=$(subst ",,$(CONFIG_KDEVOPS_HOSTS_PREFIX))-nfsd
FSTESTS_ARGS += fstests_nfs_use_kdevops_nfsd='True'
endif # CONFIG_FSTESTS_USE_KDEVOPS_NFSD
FSTESTS_ARGS += fstests_nfs_server_host='$(FSTESTS_NFS_SERVER_HOST)'
endif # CONFIG_FSTESTS_NFS

ifeq (y,$(CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION))
FSTESTS_ARGS += fstests_test_dev='$(FSTESTS_TEST_DEV)'
endif

ifeq (y,$(CONFIG_FSTESTS_XFS))
include $(TOPDIR)/workflows/fstests/Makefile.xfs
endif

ifeq (y,$(CONFIG_FSTESTS_BTRFS))
include $(TOPDIR)/workflows/fstests/btrfs/Makefile
endif

ifeq (y,$(CONFIG_FSTESTS_NFS))
include $(TOPDIR)/workflows/fstests/nfs/Makefile
endif

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

# For now we only use this to ensure you know what you are doing...
ifeq (y,$(CONFIG_FSTESTS_TESTDEV_UNDER_DEVELOPMENT))
FSTESTS_ARGS += fstests_testdev_under_developmen='True'

# Only 1 real NVMe drive is required use PCIe passthrough with make dynconfig
ifeq (y,$(CONFIG_FSTESTS_TESTDEV_NVME_PARTITION_EUIS))
FSTESTS_ARGS += fstests_testdev_nvme_partition_euis='True'
endif

# 7 drives are needed, use PCIe passthrough onto the guest with make dynconfig
ifeq (y,$(CONFIG_FSTESTS_TESTDEV_NVME_EUIS))
FSTESTS_ARGS += fstests_testdev_nvme_euis='True'
endif

ifeq (y,$(CONFIG_FSTESTS_TESTDEV_NVME_FALLBACK_MODEL_SERIAL))
FSTESTS_ARGS += fstests_testdev_nvme_fallback_model_serial='True'
endif

endif # CONFIG_FSTESTS_TESTDEV_UNDER_DEVELOPMENT

ifeq (y,$(CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION))
FSTESTS_LOGWRITES_DEV:=$(subst ",,$(CONFIG_FSTESTS_LOGWRITES_DEV))
FSTESTS_ARGS += fstests_logwrites_dev='$(FSTESTS_LOGWRITES_DEV)'

FSTESTS_SCRATCH_LOGDEV:=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_LOGDEV))
FSTESTS_ARGS += fstests_scratch_logdev='$(FSTESTS_SCRATCH_LOGDEV)'

FSTESTS_SCRATCH_RTDEV:=$(subst ",,$(CONFIG_FSTESTS_SCRATCH_RTDEV))
FSTESTS_ARGS += fstests_scratch_rtdev='$(FSTESTS_SCRATCH_RTDEV)'

SPARSE_GEN:=$(subst ",,$(CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION))
FSTESTS_ARGS += fstests_testdev_sparsefile_generation='True'
FSTESTS_ARGS += sparsefiles_generation='$(SPARSE_GEN)'
endif

ifeq (y,$(CONFIG_CONFIG_BOOTLINUX))
TREE_TAG:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_TAG))
FSTESTS_ARGS += fstests_perf_config='$(PROJECTRELEASE)-kernel-$(TREE_TAG)'
endif
ifeq (,$(CONFIG_CONFIG_BOOTLINUX))
FSTESTS_ARGS += fstests_perf_config='$(PROJECTRELEASE)-kernel-distro'
endif

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
WORKFLOW_ARGS_DIRECT += $(FSTESTS_ARGS_DIRECT)

FSTEST_KERNEL_CI_LOOP := false
FSTEST_KERNEL_CI_LOOP_KOTD := false
ifeq (y,$(CONFIG_KERNEL_CI))
FSTEST_KERNEL_CI_LOOP := scripts/workflows/fstests/run_kernel_ci.sh
FSTEST_KERNEL_CI_LOOP_KOTD := scripts/workflows/fstests/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

DYNAMIC_RUNTIME_VARS := "kdevops_run_fstests": True
ifneq (,$(RUN_FAILURES))
DYNAMIC_RUNTIME_VARS += , "run_tests_on_failures": True
endif

ifneq (,$(SKIP_RUN))
DYNAMIC_RUNTIME_VARS += , "fstests_skip_run": True
endif

ifneq (,$(INITIAL_BASELINE))
DYNAMIC_RUNTIME_VARS += , "fstests_initial_baseline": True
endif

fstests:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts playbooks/fstests.yml --skip-tags run_tests,copy_results $(LIMIT_HOSTS)

fstests-kdevops-setup: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts playbooks/fstests.yml \
		--tags vars,kdevops_fstests_setup,gendisks \
		$(LIMIT_HOSTS)

fstests-baseline:
	$(Q)PYTHONUNBUFFERED=1 ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags vars,run_tests,copy_results \
		--extra-vars '{ $(DYNAMIC_RUNTIME_VARS) }' \
		--extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-loop: $(KDEVOPS_EXTRA_VARS)
	$(Q)$(FSTEST_KERNEL_CI_LOOP) baseline $(LIMIT_HOSTS)

fstests-baseline-kernelci: $(KDEVOPS_EXTRA_VARS)
	$(Q)$(FSTEST_KERNEL_CI_LOOP_KOTD) baseline $(LIMIT_HOSTS)

fstests-baseline-skip-kdevops-update: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags run_tests,copy_results \
		--skip-tags git_update \
		--extra-vars \
		'{ $(DYNAMIC_RUNTIME_VARS) }' \
		--extra-vars=@./extra_vars.yaml \
		$(LIMIT_HOSTS)

fstests-baseline-run-oscheck-only: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags run_tests,copy_results \
		--skip-tags git_update,reboot,clean_results \
		--extra-vars \
		'{ $(DYNAMIC_RUNTIME_VARS) }' \
		--extra-vars=@./extra_vars.yaml \
		$(LIMIT_HOSTS)

fstests-config: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags vars,generate-fstests-config \
		--extra-vars=@./extra_vars.yaml \
		$(LIMIT_HOSTS)

fstests-config-debug: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		playbooks/fstests.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		-e 'fstests_debug_localhost=True' \
		--tags vars,generate-fstests-config \
		--extra-vars=@./extra_vars.yaml

fstests-dev: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/fstests.yml \
		--tags vars,run_tests,copy_results \
		--extra-vars \
		'{ $(DYNAMIC_RUNTIME_VARS) }' \
		--extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-results-tfb-ls: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags vars,tfb \
		--skip-tags copy_final \
		--extra-vars \
		'{ fstests_tfp_copy_enable_list: True }' \
		--extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-results-tfb-trim: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags vars,tfb \
		--skip-tags copy_final \
		--extra-vars \
		'{ fstests_tfp_copy_enable: True }' \
		--extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

fstests-baseline-results: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/fstests.yml \
		--tags copy_results,print_results,tfb \
		--extra-vars '{ kdevops_run_fstests: True }' \
		--extra-vars=@./extra_vars.yaml \
		$(LIMIT_HOSTS)

fstests-results: fstests-baseline-results

fstests-dev-results: $(KDEVOPS_EXTRA_VARS)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/fstests.yml \
		--tags copy_results,print_results \
		--extra-vars '{ kdevops_run_fstests: True }' \
		--extra-vars=@./extra_vars.yaml \
		$(LIMIT_HOSTS)

fstests-help-menu:
	@echo "fstests options:"
	@echo "fstests                                 - Git clones fstests, builds and install it"
	@echo "fstests-kdevops-setup                   - Install kdevops specific files, the fstests and running test targets also runs this"
	@echo "fstests-baseline                        - Run fstests on baseline hosts and collect results"
	@echo "fstests-dev                             - Run fstests on dev hosts and collect results"
	@echo ""
	@echo "fstests-config                          - Generates the filesystem configuration file only onto target systems"
	@echo "fstests-config-debug                    - Generates the filesystem configuration file locally, useful for debugging"
	@echo ""
	@echo "fstests-baseline-results-tfb-ls         - Only show a listing of TFB results files other than XML files which are TFB"
	@echo "fstests-baseline-results-tfb-trim       - Trim all TFB results file other than xml files"
	@echo "fstests-baseline-results                - Only collect results for baseline hosts"
	@echo "fstests-dev-results                     - Only collect results for dev hosts"
	@echo "fstests-baseline-skip-kdevops-update    - Run fstests but skip updating kdevops"
	@echo "fstests-baseline-run-oscheck-only       - Only run oscheck"
	@echo "fstests-baseline-loop                   - Run fstests in a loop until a failure is found or steady state is reached"
	@echo "fstests-baseline-kernelci               - Run fstests kernel-ci loop"
	@echo ""

HELP_TARGETS += fstests-help-menu
