ifeq (y,$(CONFIG_WORKFLOWS_DEDICATED_WORKFLOW))
export KDEVOPS_HOSTS_TEMPLATE := gitr.j2
endif

GITR_MNT:=$(subst ",,$(CONFIG_GITR_MNT))
GITR_ARGS += gitr_mnt=$(GITR_MNT)

ifeq (y,$(CONFIG_GITR_XFS))
include $(TOPDIR)/workflows/gitr/xfs/Makefile
endif

ifeq (y,$(CONFIG_GITR_BTRFS))
include $(TOPDIR)/workflows/gitr/btrfs/Makefile
endif

ifeq (y,$(CONFIG_GITR_EXT4))
include $(TOPDIR)/workflows/gitr/ext4/Makefile
endif

ifeq (y,$(CONFIG_GITR_NFS))
include $(TOPDIR)/workflows/gitr/nfs/Makefile
endif

ifeq (y,$(CONFIG_GITR_TMPFS))
include $(TOPDIR)/workflows/gitr/tmpfs/Makefile
endif

GITR_REPO:=$(subst ",,$(CONFIG_GITR_REPO))
GITR_ARGS += gitr_repo=$(GITR_REPO)

GITR_REPO_COMMIT:=$(subst ",,$(CONFIG_GITR_REPO_COMMIT))
GITR_ARGS += gitr_repo_commit=$(GITR_REPO_COMMIT)

WORKFLOW_ARGS_DIRECT += $(GITR_ARGS)

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_DEDICATE_GITR))
WORKFLOW_ARGS_SEPARATED += gitr_enabled_test_groups='$(subst $(space),+,$(GITR_ENABLED_TEST_GROUPS))'
endif

GITR_KERNEL_CI_LOOP := false
GITR_KERNEL_CI_LOOP_KOTD := false

ifeq (y,$(CONFIG_KERNEL_CI))
GITR_KERNEL_CI_LOOP      := scripts/workflows/gitr/run_kernel_ci.sh
GITR_KERNEL_CI_LOOP_KOTD := scripts/workflows/gitr/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

gitr:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts playbooks/gitr.yml --skip-tags run_tests,copy_results

gitr-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/gitr.yml \
		--tags vars,run_tests,copy_results \
		--extra-vars=@./extra_vars.yaml

gitr-baseline-loop:
	$(Q)$(GITR_KERNEL_CI_LOOP) baseline

gitr-baseline-kernelci:
	$(Q)$(GITR_KERNEL_CI_LOOP_KOTD) baseline

gitr-dev-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/gitr.yml --tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

gitr-dev-loop:
	$(Q)$(GITR_KERNEL_CI_LOOP) dev

gitr-dev-kernelci:
	$(Q)$(GITR_KERNEL_CI_LOOP_KOTD) dev

gitr-dev-reset:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/gitr.yml --tags vars,reset --extra-vars=@./extra_vars.yaml

gitr-help-menu:
	@echo "gitr options:"
	@echo "gitr                              - Git clone git, build and install it"
	@echo "gitr-{baseline,dev}               - Run the gitr test on baseline or dev hosts and collect results"
	@echo "gitr-{baseline,dev}-loop"         - Run gitr in a loop until error or steady state
	@echo "gitr-{baseline,dev}-kernelci      - Run gitr kernel-ci loop"
	@echo ""

HELP_TARGETS += gitr-help-menu
