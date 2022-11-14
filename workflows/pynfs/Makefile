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
	@echo "pynfs-baseline                    - Run the pynfs test on baseline hosts and collect results"
	@echo "pynfs-dev                         - Run pynfs on dev hosts and collect results"
	@echo "pynfs-baseline-kernelci           - Run pynfs kernel-ci loop"
	@echo ""

HELP_TARGETS += pynfs-help-menu
