# Reboot-limit demo Makefile
#
# This serves a both the reboot-limit workflow Makefile but also documentation
# which we should probably move out to another place eventually. For now this
# Makefile is flooded with verbose documentation over each step to serve as
# documentation so that it is easier for folks to add more workflows.

# This simple workflow relies on the default setting of the variable
# KDEVOPS_NODES_TEMPLATE which to generate your target nodes. This can
# either be used by vagrant or terraform when building the nodes it will
# create for bringup. The template file relies on jinja2 templating for
# its parsing and generation and we rely on the ansible template module
# to process this template file.
#
# The default KDEVOPS_NODES_TEMPLATE file is designed to be generic enough
# for most Linux kernel development and test workflows, you can however
# override it by simply setting the variable KDEVOPS_NODES_TEMPLATE to an
# empty string as is done with fstests. Look at the fstests workflow for a
# more complex example.

# We first remove the string "" delimiters from what kconfig gives us.
REBOOT_LIMIT_TEST_TYPE :=$(subst ",,$(CONFIG_REBOOT_LIMIT_TEST_TYPE))

# Now use a local varible to store the arguments we want to eventually append
# into the file extra_vars.yaml. The extra_vars.yaml file is always used as an
# argument to ansible so that it reads our manually converted kconfig varibles
# in ansible. We typically call a playbook with something like:
# ansible-playbook -f 30 -i hosts -l baseline playbooks/foo.yml --tags bar --extra-vars=@./extra_vars.yaml
#
# Likewise most playbooks also have something like the following as their first
# task in their playbooks, so that they don't have to be specifying the
# --extra_vars argument to each ansible call:
#
#- name: Import optional extra_args file
#  include_vars: "{{ item }}"
#  ignore_errors: yes
#  with_first_found:
#  - files:
#    - "../extra_vars.yml"
#    - "../extra_vars.yaml"
#    - "../extra_vars.json"
#  skip: true
#  tags: vars
REBOOT_LIMIT_ARGS += reboot_limit_test_type='$(REBOOT_LIMIT_TEST_TYPE)'

ifeq (y,$(CONFIG_REBOOT_LIMIT_ENABLE_DATA_COLLECTION))
REBOOT_LIMIT_DATA :=$(subst ",,$(CONFIG_REBOOT_LIMIT_DATA))
REBOOT_LIMIT_ARGS += reboot_limit_data=\"$(REBOOT_LIMIT_DATA)\"

# This is an example of how to map a boolean from kconfig into ansible
ifeq (y,$(CONFIG_REBOOT_LIMIT_ENABLE_SYSTEMD_ANALYZE))
REBOOT_LIMIT_ARGS += reboot_limit_enable_systemd_analyze=True
endif
endif

# This defines how many times we believe running a reboot should mean
# it works OK. Note that if enabling kernel-ci the steady state there
# is separate. And so if this reboot_limit_max is 100 and steady state
# is 100, we'd have to reboot 10,000 times before reaching steady state.
REBOOT_LIMIT_MAX:=$(subst ",,$(CONFIG_REBOOT_LIMIT_BOOT_MAX))
REBOOT_LIMIT_ARGS += reboot_limit_max='$(REBOOT_LIMIT_MAX)'

ifeq (y,$(CONFIG_REBOOT_LIMIT_BOOT_COUNT_CRASH_ENABLE))
REBOOT_LIMIT_ARGS += reboot_limit_boot_count_crash_enable=True
REBOOT_LIMIT_BOOT_CRASH_COUNT:=$(subst ",,$(CONFIG_REBOOT_LIMIT_BOOT_COUNT_CRASH))
REBOOT_LIMIT_ARGS += reboot_limit_boot_crash_count='$(REBOOT_LIMIT_BOOT_CRASH_COUNT)'
endif

# The variables we append to WORKFLOW_ARGS automatically get used to write
# the extra_vars.yaml file.
WORKFLOW_ARGS += $(REBOOT_LIMIT_ARGS)

# The default is our workflow does not have kernel-ci enabled
REBOOT_LIMIT_KERNEL_CI_LOOP := false
REBOOT_LIMIT_KERNEL_CI_LOOP_KOTD := false

# If kdevops was configured to enable kernel-ci we define our scripts
ifeq (y,$(CONFIG_KERNEL_CI))
REBOOT_LIMIT_KERNEL_CI_LOOP      := scripts/workflows/demos/reboot-limit/run_kernel_ci.sh
REBOOT_LIMIT_KERNEL_CI_LOOP_KOTD := scripts/workflows/demos/reboot-limit/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

# By default KDEVOPS_HOSTS_TEMPLATE is defined to be hosts.in, if you want an
# alternative you can define one, or even have a dynamic one. For an example
# of how to make a dynamic KDEVOPS_HOSTS_TEMPLATE refer to the
# workflows/fstests/Makefile.

# We move on to defining your first targets. These should have the same name
# of the workflow. That target should just do the installation onto each node
# of whatever software it needs. In the case of the reboot-limit test we don't
# have anything to really keep persistant on the target node, but for the sake
# of an example we will copy a few files over.
#
# To ensure you have data which will be persistant on the nodes you first
# ansible task should be to include the extra extra_vars.yaml and then after
# that to include create_data_partition playbook. This will setup the /data/
# partition on each node. If you don't have to have persistant data this is not
# needed. We enable it just for demonstration purposes as most workflows might
# need it. In our case the /data partition will be used if you enabled data
# collection through CONFIG_REBOOT_LIMIT_ENABLE_DATA_COLLECTION. The only
# supported method of data collection right now is systemd-analyze data results.
#
# The playbook reboot-limit.yml is used to run all tasks defined except those
# with tags "run_tests" or "copy_results".
reboot-limit:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts playbooks/reboot-limit.yml --skip-tags run_tests,copy_results

# kdevops supports generic workflows such as the enabling you to then use the
# /data/ partition to git clone linux, compile linux, install it and reboot
# into it, with the linux workflow. These workflows don't have a "baseline"
# test, they just have a target. In the case of linux, its just 'make linux'.
#
# If you are working a test workflow though, you may want to define a baseline
# target on your Makefile. kdevops Makefile targets with a postfix of -baseline
# are intended to not fail. The idea is that baseline is the known set of tests
# for that test workflow which are known to not fail. In the case of the
# reboot-limit test, it will reboot the system and ensure things are OK.
#
# The end goal though is to see how many times the system can reboot without
# an issue. For this we rely on the setting of CONFIG_REBOOT_LIMIT_MAX.
#
# By default, if virtualization is used, two guests are created for you, one
# for working on the baseline and one for development purposes. You associate
# tasks from ansible you want to run for the baseline group of nodes by using
# the -l baseline. The baseline group may grow to have more nodes than just one,
# depending on your test. You refer to the group of development nodes with the
# argument -l dev.
#
# The playbook reboot-limit.yml is used to run *only* tasks defined with the
# tags "first_run" first and then "run_tests" and "copy_results". We always
# use the vars tag to ensure we get variables defined which we construct on the
# fly.
reboot-limit-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/reboot-limit.yml --tags vars,first_run,reset --extra-vars=@./extra_vars.yaml
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/reboot-limit.yml --tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

# Once you know the baseline works, you may want to run the baseline in a loop
# up to the number of times you define. We define this goal in kdevops as
# the CONFIG_KERNEL_CI_STEADY_STATE_GOAL.
reboot-limit-baseline-loop:
	$(Q)$(REBOOT_LIMIT_KERNEL_CI_LOOP) baseline

# The kdevops kernel-ci target will try to upgrade your kernel to the latest
# and then run the baseline-loop.
reboot-limit-baseline-kernelci:
	$(Q)$(REBOOT_LIMIT_KERNEL_CI_LOOP_KOTD) baseline

# Resets the boot counters so we start from scratch
reboot-limit-baseline-reset:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l baseline playbooks/reboot-limit.yml --tags vars,reset --extra-vars=@./extra_vars.yaml

# Below are the corresponding dev targets
reboot-limit-dev-baseline:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/reboot-limit.yml --tags vars,first_run,reset --extra-vars=@./extra_vars.yaml
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/reboot-limit.yml --tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

reboot-limit-dev-loop:
	$(Q)$(REBOOT_LIMIT_KERNEL_CI_LOOP) dev

reboot-limit-dev-kernelci:
	$(Q)$(REBOOT_LIMIT_KERNEL_CI_LOOP_KOTD) dev

reboot-limit-dev-reset:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts -l dev playbooks/reboot-limit.yml --tags vars,reset --extra-vars=@./extra_vars.yaml

reboot-limit-help-menu:
	@echo "reboot-limit options:"
	@echo "reboot-limit                             - Sets up the /data/reboot-limit directory"
	@echo "reboot-limit-baseline                    - Run the reboot-linit test on baseline hosts and collect results"
	@echo "reboot-limit-baseline-reset              - Reset the test boot counter for baseline"
	@echo "reboot-limit-dev                         - Run the reboot-limti test on dev hosts and collect results"
	@echo "reboot-limit-baseline-kernelci           - Run the reboot-limit kernel-ci loop"
	@echo ""

HELP_TARGETS += reboot-limit-help-menu
