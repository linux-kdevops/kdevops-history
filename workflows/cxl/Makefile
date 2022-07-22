# SPDX-License-Identifier: copyleft-next-0.3.1

CXL_ARGS :=
CXL_ARGS += ndctl_git='$(subst ",,$(CONFIG_NDCTL_GIT))
CXL_ARGS += ndctl_data=\"$(subst ",,$(CONFIG_NDCTL_DATA))\"
CXL_ARGS += ndctl_version='$(subst ",,$(CONFIG_NDCTL_VERSION))'

WORKFLOW_ARGS += $(CXL_ARGS)

EXTRA_VAR_INPUTS += extend-extra-args-blktests

cxl:
	$(Q)ansible-playbook -f 30 -i hosts playbooks/cxl.yml $(LIMIT_HOSTS)

cxl-help-menu:
	@echo "cxl development:"
	@echo "cxl   - Git clones ncdtl to compile and install the /usr/bin/cxl binary"
	@echo ""

HELP_TARGETS += cxl-help-menu
