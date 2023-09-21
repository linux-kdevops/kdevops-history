# We can later remove kconfig options which match their respective ansible
# name once kconfig gets extra_vars.yaml output support. That means this
# Makfile can become empty :) in the future !
#
# When we do add support to kconfig to output extra_vars.yaml we will also
# add support so that only kconfig symbols which have an associated new option,
# say, select_yaml_output, will it be used to also be output to the yaml file.
# That would ensure that our extra_vars.yaml file won't be as long as our
# existing .config files.

FSTESTS_ARGS += fstests_tmpfs_enable='True'

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_DEFAULT))
FSTESTS_ARGS += fstests_tmpfs_section_default=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_ENABLE_NOSWAP))
FSTESTS_ARGS += fstests_tmpfs_enable_noswap=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_NOSWAP_HUGE_NEVER))
FSTESTS_ARGS += fstests_tmpfs_section_noswap_huge_never=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_NOSWAP_HUGE_ALWAYS))
FSTESTS_ARGS += fstests_tmpfs_section_noswap_huge_always=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_NOSWAP_HUGE_WITHIN_SIZE))
FSTESTS_ARGS += fstests_tmpfs_section_noswap_huge_within_size=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_NOSWAP_HUGE_ADVISE))
FSTESTS_ARGS += fstests_tmpfs_section_noswap_huge_advise=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_ENABLE_HUGE))
FSTESTS_ARGS += fstests_tmpfs_enable_huge=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_HUGE_ALWAYS))
FSTESTS_ARGS += fstests_tmpfs_section_huge_always=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_HUGE_WITHIN_SIZE))
FSTESTS_ARGS += fstests_tmpfs_section_huge_within_size=True
endif

ifeq (y,$(CONFIG_FSTESTS_TMPFS_SECTION_HUGE_ADVISE))
FSTESTS_ARGS += fstests_tmpfs_section_huge_advise=True
endif
