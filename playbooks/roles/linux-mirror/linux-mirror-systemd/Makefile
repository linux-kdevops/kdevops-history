USER_SYSTEM := ~/.config/systemd/user/
MIRROR_PATH := /mirror

ifeq (,$(wildcard $(TOPDIR_PATH)/.config))
else
include $(TOPDIR_PATH)/.config
endif

export TORVALDS		:= $(subst ",,$(CONFIG_MIRROR_TORVALDS_URL))
export STABLE		:= $(subst ",,$(CONFIG_MIRROR_STABLE_URL))
export NEXT		:= $(subst ",,$(CONFIG_MIRROR_NEXT_URL))
export KDEVOPS_LINUS	:= $(subst ",,$(CONFIG_MIRROR_KDEVOPS_LINUS_URL))
export MCGROF		:= $(subst ",,$(CONFIG_MIRROR_MCGROF_URL))
export MCGROF_LINUS	:= $(subst ",,$(CONFIG_MIRROR_MCGROF_LINUS_URL))
export QEMU		:= $(subst ",,$(CONFIG_MIRROR_QEMU_URL))
export QEMU_JIC23	:= $(subst ",,$(CONFIG_MIRROR_QEMU_JIC23_URL))
export KDEVOPS		:= $(subst ",,$(CONFIG_MIRROR_KDEVOPS_URL))
export FSTESTS		:= $(subst ",,$(CONFIG_MIRROR_FSTESTS_URL))
export KDEVOPS_FSTESTS	:= $(subst ",,$(CONFIG_MIRROR_KDEVOPS_FSTESTS_URL))
export BLKTESTS		:= $(subst ",,$(CONFIG_MIRROR_BLKTESTS_URL))

LINUX_SERVICES := linux-mirror.service
LINUX_SERVICES += linux-stable-mirror.service
LINUX_SERVICES += linux-next-mirror.service
LINUX_SERVICES += kdevops-linus-mirror.service
LINUX_SERVICES += mcgrof-next-mirror.service
LINUX_SERVICES += mcgrof-linus-mirror.service

LINUX_TIMERS := linux-mirror.timer
LINUX_TIMERS += linux-stable-mirror.timer
LINUX_TIMERS += linux-next-mirror.timer
LINUX_TIMERS += kdevops-linus-mirror.timer
LINUX_TIMERS += mcgrof-next-mirror.timer
LINUX_TIMERS += mcgrof-linus-mirror.timer

KDEVOPS_SERVICES  := kdevops-mirror.service
KDEVOPS_TIMERS := kdevops-mirror.timer

TOOLS_SERVICES  := fstests-mirror.service
TOOLS_SERVICES  += kdevops-fstests-mirror.service
TOOLS_SERVICES  += blktests-mirror.service
TOOLS_TIMERS := fstests-mirror.timer
TOOLS_TIMERS += kdevops-fstests-mirror.timer
TOOLS_TIMERS += blktests-mirror.timer

QEMU_SERVICES  := qemu-mirror.service
QEMU_SERVICES  += qemu-jic23-mirror.service
QEMU_TIMERS    := qemu-mirror.timer
QEMU_TIMERS    += qemu-jic23-mirror.timer

GIT_DAEMON_FILES := git-daemon@.service
GIT_DAEMON_FILES += git-daemon.socket
LOCAL_SYSTEMD    := /usr/local/lib/systemd/system/

TORVALDS_TARGET		:= $(MIRROR_PATH)/linux.git
STABLE_TARGET		:= $(MIRROR_PATH)/linux-stable.git
NEXT_TARGET		:= $(MIRROR_PATH)/linux-next.git
KDEVOPS_TARGET_LINUS	:= $(MIRROR_PATH)/kdevops-linus.git
MCGROF_TARGET_LINUS	:= $(MIRROR_PATH)/mcgrof-linus.git
MCGROF_TARGET		:= $(MIRROR_PATH)/mcgrof-next.git
QEMU_TARGET     	:= $(MIRROR_PATH)/qemu.git
QEMU_JIC23_TARGET	:= $(MIRROR_PATH)/qemu-jic23.git
KDEVOPS_TARGET		:= $(MIRROR_PATH)/kdevops.git
FSTESTS_TARGET		:= $(MIRROR_PATH)/fstests.git
KDEVOPS_FSTESTS_TARGET	:= $(MIRROR_PATH)/kdevops/fstests.git
BLKTESTS_TARGET		:= $(MIRROR_PATH)/blktests.git

MIRROR_SERVICES := $(LINUX_SERVICES)
MIRROR_SERVICES += $(QEMU_SERVICES)
MIRROR_SERVICES += $(KDEVOPS_SERVICES)
MIRROR_SERVICES += $(TOOLS_SERVICES)

MIRROR_TIMERS   := $(LINUX_TIMERS)
MIRROR_TIMERS   += $(QEMU_TIMERS)
MIRROR_TIMERS   += $(KDEVOPS_TIMERS)
MIRROR_TIMERS   += $(TOOLS_TIMERS)

ifeq ($(V),1)
export Q=
export NQ=true
else
export Q=@
export NQ=@echo
endif

ifneq ($(findstring 2, $(V)),)
  export GIT_VERBOSE := "--verbose"
endif

all: help

help:
	$(NQ) "mirror:     git clone all mirrors"
	$(NQ) "install:    install system timers and git-daemon socket activation"

mirror:
	$(Q)if [ ! -d $(MIRROR_PATH) ]; then \
		mkdir -p $(MIRROR_PATH)     ;\
	fi
	$(NQ) "          Verify $(USER) can write onto $(MIRROR_PATH)"
	$(Q)touch $(MIRROR_PATH)/ignore_kdevops
	$(Q)rm -f $(MIRROR_PATH)/ignore_kdevops
	$(Q)if [ ! -d $(TORVALDS_TARGET) ]; then \
	 echo "          CLONE torvalds/linux tree" ;\
	 git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(TORVALDS) $(TORVALDS_TARGET) ;\
	fi
	$(Q)if [ ! -d $(STABLE_TARGET) ]; then \
	 echo "          CLONE stable/linux" ;\
	 git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(STABLE) --reference /mirror/linux.git $(STABLE_TARGET) ;\
	fi
	$(Q)if [ ! -d $(NEXT_TARGET) ]; then \
	  echo "          CLONE next/linux-next" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(NEXT) --reference /mirror/linux.git $(NEXT_TARGET) ;\
	fi
	$(Q)if [ ! -d $(KDEVOPS_TARGET_LINUS) ]; then \
	  echo "          CLONE kdevops/linux" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(KDEVOPS_LINUS) --reference /mirror/linux.git $(KDEVOPS_TARGET_LINUS) ;\
	fi
	$(Q)if [ ! -d $(MCGROF_TARGET) ]; then \
	  echo "          CLONE mcgrof/linux-next" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(MCGROF) --reference /mirror/linux.git $(MCGROF_TARGET) ;\
	fi
	$(Q)if [ ! -d $(MCGROF_TARGET_LINUS) ]; then \
	  echo "          CLONE mcgrof/linux" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(MCGROF_LINUS) --reference /mirror/linux.git $(MCGROF_TARGET_LINUS) ;\
	fi
	$(Q)if [ ! -d $(QEMU_TARGET) ]; then \
	  echo "          CLONE qemu-project/qemu" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(QEMU) $(QEMU_TARGET) ;\
	fi
	$(Q)if [ ! -d $(QEMU_JIC23_TARGET) ]; then \
	  echo "          CLONE qemu-project/jic23-qemu" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(QEMU_JIC23) --reference /mirror/qemu.git $(QEMU_JIC23_TARGET) ;\
	fi
	$(Q)if [ ! -d $(KDEVOPS_TARGET) ]; then \
	  echo "          CLONE linux-kdevops/kdevops" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(KDEVOPS) $(KDEVOPS_TARGET) ;\
	fi
	$(Q)if [ ! -d $(FSTESTS_TARGET) ]; then \
	  echo "          CLONE fstests" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(FSTESTS) $(FSTESTS_TARGET) ;\
	fi
	$(Q)if [ ! -d $(KDEVOPS_FSTESTS_TARGET) ]; then \
	  echo "          CLONE kdevops-fstests" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(KDEVOPS_FSTESTS) --reference $(FSTESTS_TARGET) $(KDEVOPS_FSTESTS_TARGET) ;\
	fi
	$(Q)if [ ! -d $(BLKTESTS_TARGET) ]; then \
	  echo "          CLONE blktests" ;\
	  git -C $(MIRROR_PATH) clone $(GIT_VERBOSE) --progress --mirror $(BLKTESTS) $(BLKTESTS_TARGET) ;\
	fi

install:
	$(Q)mkdir -p $(USER_SYSTEM)
	$(Q)cp $(MIRROR_SERVICES)   $(USER_SYSTEM)
	$(Q)cp $(MIRROR_TIMERS)     $(USER_SYSTEM)
	$(Q)for i in $(MIRROR_SERVICES); do           \
		echo  "Enabling $$i" ;                \
		systemctl --user enable  $$i ;        \
	done
	$(Q)for i in $(MIRROR_TIMERS); do             \
		echo  "Enabling $$i" ;                \
		systemctl --user enable $$i ;         \
		systemctl --user start $$i ;          \
	done
	$(NQ) "          ENABLE git-daemon"
	$(Q)sudo mkdir -p $(LOCAL_SYSTEMD)
	$(Q)sudo cp $(GIT_DAEMON_FILES) $(LOCAL_SYSTEMD)
	$(Q)sudo systemctl enable git-daemon.socket
	$(Q)sudo systemctl start git-daemon.socket

status:
	$(NQ) systemd timer units list
	$(Q)systemctl --user list-timers
	$(NQ) systemd timer status
	$(Q)systemctl status --user $(MIRROR_TIMERS)
	$(NQ) systemd service units status
	$(Q)systemctl status --user $(MIRROR_SERVICES)
