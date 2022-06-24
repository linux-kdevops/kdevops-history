# SPDX-License-Identifier: copyleft-next-0.3.1

export KDEVOPS_BLKTESTS_CONFIG :=
export KDEVOPS_BLKTESTS_CONFIG_TEMPLATE :=

KDEVOPS_BLKTESTS_SCRIPTS_PATH=workflows/blktests/scripts

BLKTESTS_TEST_DEVS=$(subst ",,$(CONFIG_BLKTESTS_TEST_DEVS))

ID=$(shell id -u)

BLKTESTS_ARGS	:=

ifeq (y,$(CONFIG_WORKFLOWS_DEDICATED_WORKFLOW))
export KDEVOPS_HOSTS_TEMPLATE := blktests.j2
endif

BLKTESTS_GIT:=$(subst ",,$(CONFIG_BLKTESTS_GIT))
BLKTESTS_DATA:=$(subst ",,$(CONFIG_BLKTESTS_DATA))

BLKTRACE_GIT:=$(subst ",,$(CONFIG_BLKTRACE_GIT))
BLKTRACE_DATA:=$(subst ",,$(CONFIG_BLKTRACE_DATA))

NBD_GIT:=$(subst ",,$(CONFIG_NBD_GIT))
NBD_VERSION:=$(subst ",,$(CONFIG_NBD_VERSION))
NBD_DATA:=$(subst ",,$(CONFIG_NBD_DATA))

BLKTESTS_DATA_TARGET:=$(subst ",,$(CONFIG_BLKTESTS_DATA_TARGET))

BLKTESTS_ARGS += blktests_git='$(BLKTESTS_GIT)'
BLKTESTS_ARGS += blktests_data=\"$(BLKTESTS_DATA)\"

BLKTESTS_ARGS += blktrace_git='$(BLKTRACE_GIT)'
BLKTESTS_ARGS += blktrace_data=\"$(BLKTRACE_DATA)\"

BLKTESTS_ARGS += nbd_git='$(NBD_GIT)'
BLKTESTS_ARGS += nbd_version=$(NBD_VERSION)
BLKTESTS_ARGS += nbd_data=\"$(NBD_DATA)\"

BLKTESTS_ARGS += blktests_data_target='$(BLKTESTS_DATA_TARGET)'

WORKFLOW_ARGS += $(BLKTESTS_ARGS)

BLKTEST_KERNEL_CI_LOOP := false
BLKTEST_KERNEL_CI_LOOP_KOTD := false
ifeq (y,$(CONFIG_KERNEL_CI))
BLKTEST_KERNEL_CI_LOOP := scripts/workflows/blktests/run_kernel_ci.sh
BLKTEST_KERNEL_CI_LOOP_KOTD := scripts/workflows/blktests/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

EXTRA_VAR_INPUTS += extend-extra-args-blktests

extend-extra-args-blktests:
	@if [[ "$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS)" == "y" ]]; then \
		echo "blktests_test_devs: '$(CONFIG_BLKTESTS_TEST_DEVS)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi

blktests:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/blktests.yml --skip-tags run_tests,copy_results $(LIMIT_HOSTS)

blktests-baseline:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/blktests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-baseline-loop:
	$(Q)$(BLKTEST_KERNEL_CI_LOOP) baseline $(LIMIT_HOSTS)

blktests-baseline-kernelci:
	$(Q)$(BLKTEST_KERNEL_CI_LOOP_KOTD) baseline $(LIMIT_HOSTS)

blktests-baseline-skip-kdevops-update:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/blktests.yml --tags run_tests,copy_results --skip-tags git_update --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-baseline-run-oscheck-only:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/blktests.yml --tags run_tests,copy_results --skip-tags git_update,reboot,clean_results --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-dev:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/blktests.yml --tags run_tests,copy_results --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-baseline-results:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/blktests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-dev-results:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/blktests.yml --tags copy_results,print_results --extra-vars '{ kdevops_run_blktests: True }' --extra-vars=@./extra_vars.yaml $(LIMIT_HOSTS)

blktests-help-menu:
	@echo "blktests options:"
	@echo "blktests                                 - Git clones blktests, builds and install it"
	@echo "blktests-baseline                        - Run blktests on baseline hosts and collect results"
	@echo "blktests-dev                             - Run blktests on dev hosts and collect results"
	@echo "blktests-baseline-results                - Only collect results for baseline hosts"
	@echo "blktests-dev-results                     - Only collect results for dev hosts"
	@echo "blktests-baseline-skip-kdevops-update    - Run blktests but skip updating kdevops"
	@echo "blktests-baseline-run-oscheck-only       - Only run oscheck"
	@echo "blktests-baseline-loop                   - Run blktests in a loop until a failure is found or steady state is reached"
	@echo "blktests-baseline-kernelci               - Run blktests kernel-ci loop"
	@echo ""

HELP_TARGETS += blktests-help-menu
