# SPDX-License-Identifier: copyleft-next-0.3.1

WORKFLOW_ARGS           :=
WORKFLOW_ARGS_SEPARATED	:=

include workflows/common/Makefile

BOOTLINUX_ARGS	:=
ifeq (y,$(CONFIG_BOOTLINUX))
WORKFLOW_ARGS += kdevops_bootlinux='True'
include workflows/linux/Makefile
endif # CONFIG_BOOTLINUX == y
ifeq (,$(CONFIG_BOOTLINUX))
WORKFLOW_ARGS += kdevops_bootlinux='False'
endif

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS))
WORKFLOW_ARGS += kdevops_workflow_enable_fstests='True'
include workflows/fstests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS == y

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS))
WORKFLOW_ARGS += kdevops_workflow_enable_blktests='True'
include workflows/blktests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS == y

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_CXL))
WORKFLOW_ARGS += kdevops_workflow_enable_cxl='True'
include workflows/cxl/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_CXL == y

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_PYNFS))
include workflows/pynfs/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_PYNFS == y

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_SELFTESTS))
WORKFLOW_ARGS += kdevops_workflow_enable_selftests='True'
include workflows/selftests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_SELFTESTS

ifeq (y,$(CONFIG_WORKFLOWS_REBOOT_LIMIT))
include workflows/demos/reboot-limit/Makefile
endif # CONFIG_WORKFLOWS_REBOOT_LIMIT == y

ANSIBLE_EXTRA_ARGS += $(WORKFLOW_ARGS)
ANSIBLE_EXTRA_ARGS_SEPARATED += $(WORKFLOW_ARGS_SEPARATED)
ANSIBLE_EXTRA_ARGS_DIRECT += $(WORKFLOW_ARGS_DIRECT)
