# SPDX-License-Identifier: copyleft-next-0.3.1

include workflows/common/Makefile

BOOTLINUX_ARGS	:=
ifeq (y,$(CONFIG_BOOTLINUX))
include workflows/linux/Makefile
endif # CONFIG_BOOTLINUX == y

KDEVOPS_WORKFLOW_FSTESTS_CLEAN :=

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS))
include workflows/fstests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS == y

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS))
include workflows/blktests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS == y

ifeq (y,$(CONFIG_WORKFLOWS_REBOOT_LIMIT))
include workflows/demos/reboot-limit/Makefile
endif # CONFIG_WORKFLOWS_REBOOT_LIMIT == y
