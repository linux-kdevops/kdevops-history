ifeq (y,$(CONFIG_WORKFLOWS_DEDICATED_WORKFLOW))
export KDEVOPS_HOSTS_TEMPLATE := ltp.j2
endif

LTP_REPO:=$(subst ",,$(CONFIG_LTP_REPO))
LTP_ARGS += ltp_repo=$(LTP_REPO)

LTP_REPO_COMMIT:=$(subst ",,$(CONFIG_LTP_REPO_COMMIT))
LTP_ARGS += ltp_repo_commit=$(LTP_REPO_COMMIT)

ifeq (y,$(CONFIG_LTP_TESTS_CVE))
LTP_ARGS += ltp_tests_cve='True'
LTP_ENABLED_TEST_GROUPS += cve
else
LTP_ARGS += ltp_tests_cve='False'
endif # CONFIG_LTP_TESTS_CVE

ifeq (y,$(CONFIG_LTP_TESTS_FS))
LTP_ARGS += ltp_tests_fs='True'
LTP_ENABLED_TEST_GROUPS += fs
else
LTP_ARGS += ltp_tests_fs='False'
endif # CONFIG_LTP_TESTS_FS

ifeq (y,$(CONFIG_LTP_TESTS_FS_BIND))
LTP_ARGS += ltp_tests_fs_bind='True'
LTP_ENABLED_TEST_GROUPS += fs-bind
else
LTP_ARGS += ltp_tests_fs_bind='False'
endif # CONFIG_LTP_TESTS_FS_BIND

ifeq (y,$(CONFIG_LTP_TESTS_FS_PERMS_SIMPLE))
LTP_ARGS += ltp_tests_fs_perms_simple='True'
LTP_ENABLED_TEST_GROUPS += fs-perms-simple
else
LTP_ARGS += ltp_tests_fs_perms_simple='False'
endif # CONFIG_LTP_TESTS_FS_PERMS_SIMPLE

ifeq (y,$(CONFIG_LTP_TESTS_FS_READONLY))
LTP_ARGS += ltp_tests_fs_readonly='True'
LTP_ENABLED_TEST_GROUPS += fs-readonly
else
LTP_ARGS += ltp_tests_fs_readonly='False'
endif # CONFIG_LTP_TESTS_FS_READONLY

ifeq (y,$(CONFIG_LTP_TESTS_NFS))
LTP_ARGS += ltp_tests_nfs='True'
LTP_ENABLED_TEST_GROUPS += nfs
else
LTP_ARGS += ltp_tests_nfs='False'
endif # CONFIG_LTP_TESTS_NFS

ifeq (y,$(CONFIG_LTP_TESTS_NOTIFY))
LTP_ARGS += ltp_tests_notify='True'
LTP_ENABLED_TEST_GROUPS += notify
else
LTP_ARGS += ltp_tests_notify='False'
endif # CONFIG_LTP_TESTS_NOTIFY

ifeq (y,$(CONFIG_LTP_TESTS_RPC))
LTP_ARGS += ltp_tests_rpc='True'
LTP_ENABLED_TEST_GROUPS += rpc
else
LTP_ARGS += ltp_tests_rpc='False'
endif # CONFIG_LTP_TESTS_RPC

ifeq (y,$(CONFIG_LTP_TESTS_SMACK))
LTP_ARGS += ltp_tests_smack='True'
LTP_ENABLED_TEST_GROUPS += smack
else
LTP_ARGS += ltp_tests_smack='False'
endif # CONFIG_LTP_TESTS_SMACK

ifeq (y,$(CONFIG_LTP_TESTS_TIRPC))
LTP_ARGS += ltp_tests_tirpc='True'
LTP_ENABLED_TEST_GROUPS += tirpc
else
LTP_ARGS += ltp_tests_tirpc='False'
endif # CONFIG_LTP_TESTS_TIRPC

WORKFLOW_ARGS += $(LTP_ARGS)
WORKFLOW_ARGS_SEPARATED += ltp_enabled_test_groups='$(subst $(space),+,$(LTP_ENABLED_TEST_GROUPS))'

LTP_KERNEL_CI_LOOP := false
LTP_KERNEL_CI_LOOP_KOTD := false

ifeq (y,$(CONFIG_KERNEL_CI))
LTP_KERNEL_CI_LOOP      := scripts/workflows/ltp/run_kernel_ci.sh
LTP_KERNEL_CI_LOOP_KOTD := scripts/workflows/ltp/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

ltp:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts playbooks/ltp.yml --skip-tags run_tests,copy_results

ltp-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/ltp.yml \
		--tags vars,run_tests,copy_results \
		--extra-vars=@./extra_vars.yaml

ltp-baseline-loop:
	$(Q)$(LTP_KERNEL_CI_LOOP) baseline

ltp-baseline-kernelci:
	$(Q)$(LTP_KERNEL_CI_LOOP_KOTD) baseline

ltp-dev-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/ltp.yml \
		--tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

ltp-dev-loop:
	$(Q)$(LTP_KERNEL_CI_LOOP) dev

ltp-dev-kernelci:
	$(Q)$(LTP_KERNEL_CI_LOOP_KOTD) dev

ltp-dev-reset:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/ltp.yml \
		--tags vars,reset --extra-vars=@./extra_vars.yaml

ltp-help-menu:
	@echo "ltp options:"
	@echo "ltp                              - Git clone ltp, build and install it"
	@echo "ltp-{baseline,dev}               - Run the ltp test on baseline or dev hosts and collect results"
	@echo "ltp-{baseline,dev}-loop"         - Run ltp in a loop until error or steady state
	@echo "ltp-{baseline,dev}-kernelci      - Run ltp kernel-ci loop"
	@echo ""

HELP_TARGETS += ltp-help-menu
