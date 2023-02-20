export KDEVOPS_HOSTS_TEMPLATE := pynfs.j2

PYNFS_GIT:=$(subst ",,$(CONFIG_PYNFS_GIT))

PYNFS_ARGS += pynfs_git=$(PYNFS_GIT)
WORKFLOW_ARGS += $(PYNFS_ARGS)

# The default is our workflow does not have kernel-ci enabled
PYNFS_KERNEL_CI_LOOP := false
PYNFS_KERNEL_CI_LOOP_KOTD := false

# If kdevops was configured to enable kernel-ci we define our scripts
ifeq (y,$(CONFIG_KERNEL_CI))
PYNFS_KERNEL_CI_LOOP      := scripts/workflows/pynfs/run_kernel_ci.sh
PYNFS_KERNEL_CI_LOOP_KOTD := scripts/workflows/pynfs/run_kernel_ci_kotd.sh
endif # CONFIG_KERNEL_CI

# Makefile for pynfs targets
pynfs:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/pynfs.yml --skip-tags run_tests,copy_results

pynfs-baseline:
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/pynfs.yml --tags vars,first_run,reset --extra-vars=@./extra_vars.yaml
	$(Q)ansible-playbook -f 30 -i hosts -l baseline playbooks/pynfs.yml --tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

# Once you know the baseline works, you may want to run the baseline in a loop
# up to the number of times you define. We define this goal in kdevops as
# the CONFIG_KERNEL_CI_STEADY_STATE_GOAL.
pynfs-baseline-loop:
	$(Q)$(PYNFS_KERNEL_CI_LOOP) baseline

# The kdevops kernel-ci target will try to upgrade your kernel to the latest
# and then run the baseline-loop.
pynfs-baseline-kernelci:
	$(Q)$(PYNFS_KERNEL_CI_LOOP_KOTD) baseline

# Below are the corresponding dev targets
pynfs-dev-baseline:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/pynfs.yml --tags vars,first_run,reset --extra-vars=@./extra_vars.yaml
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/pynfs.yml --tags vars,run_tests,copy_results --extra-vars=@./extra_vars.yaml

pynfs-dev-loop:
	$(Q)$(PYNFS_KERNEL_CI_LOOP) dev

pynfs-dev-kernelci:
	$(Q)$(PYNFS_KERNEL_CI_LOOP_KOTD) dev

pynfs-dev-reset:
	$(Q)ansible-playbook -f 30 -i hosts -l dev playbooks/pynfs.yml --tags vars,reset --extra-vars=@./extra_vars.yaml

pynfs-help-menu:
	@echo "pynfs options:"
	@echo "pynfs                             - Git clone pynfs, build and install it"
	@echo "pynfs-{baseline,dev}              - Run the pynfs test on baseline  or dev hosts and collect results"
	@echo "pynfs-{baseline,dev}-loop"        - Run pynfs in a loop until error or steady state
	@echo "pynfs-{baseline,dev}-kernelci     - Run pynfs kernel-ci loop"
	@echo ""

HELP_TARGETS += pynfs-help-menu
