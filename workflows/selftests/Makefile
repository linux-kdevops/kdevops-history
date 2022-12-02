# SPDX-License-Identifier: copyleft-next-0.3.1

SELFTESTS_ARGS :=
SELFTESTS_ARGS += selftests_git='$(subst ",,$(CONFIG_SELFTESTS_PATH))
WORKFLOW_ARGS += $(SELFTESTS_ARGS)

DYNAMIC_RUNTIME_VARS := "kdevops_run_selftests": True
ifneq (,$(RUN_FAILURES))
DYNAMIC_RUNTIME_VARS += , "run_tests_on_failures": True
endif

ifneq (,$(SKIP_RUN))
DYNAMIC_RUNTIME_VARS += , "selftests_skip_run": True
endif

selftests:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/selftests.yml --skip-tags run_tests,copy_results $(LIMIT_HOSTS)

selftests-help-menu:
	@echo "selftests options:"
	@echo "selftests                         - Runs all enabled selftests"
	@echo "selftests-firmware                - Runs selftests for firmware_loader"
	@echo "selftests-kmod                    - Runs selftests for kmod"
	@echo "selftests-sysctl                  - Runs selftests for proc sysctl"
	@echo ""

HELP_TARGETS += selftests-help-menu
