USER_SYSTEM := ~/.config/systemd/user/
MIRROR_PATH := /mirror/

LINUX_SERVICES := linux-mirror.service
LINUX_SERVICES += linux-stable-mirror.service
LINUX_SERVICES += linux-next-mirror.service

LINUX_TIMERS := linux-mirror.timer
LINUX_TIMERS += linux-stable-mirror.timer
LINUX_TIMERS += linux-next-mirror.timer

QEMU_SERVICES  := qemu-mirror.service
QEMU_TIMERS    := qemu-mirror.timer

GIT_DAEMON_FILES := git-daemon@.service
GIT_DAEMON_FILES += git-daemon.socket
LOCAL_SYSTEMD    := /usr/local/lib/systemd/system/

TORVALDS        := git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
TORVALDS_TARGET := $(MIRROR_PATH)/linux.git

STABLE          := git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
STABLE_TARGET   := $(MIRROR_PATH)/linux-stable.git

NEXT            := git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
NEXT_TARGET     := $(MIRROR_PATH)/linux-next.git

QEMU            := https://github.com/qemu/qemu.git
QEMU_TARGET     := $(MIRROR_PATH)/qemu.git

MIRROR_SERVICES := $(LINUX_SERVICES)
MIRROR_SERVICES += $(QEMU_SERVICES)

MIRROR_TIMERS   := $(LINUX_TIMERS)
MIRROR_TIMERS   += $(QEMU_TIMERS)

ifeq ($(V),1)
export Q=
export NQ=true
else
export Q=@
export NQ=@echo
endif

all: help

help:
	$(NQ) "mirror:     git clone all mirrors about linux"
	$(NQ) "install:    install system timers and git-daemon socket activation"

mirror:
	$(Q)if [ ! -d $(MIRROR_PATH) ]; then \
		mkdir -p $(MIRROR_PATH)     ;\
	fi
	$(NQ) "          Verify $(USER) can write onto $(MIRROR_PATH)"
	$(Q)touch $(MIRROR_PATH)/ignore_kdevops
	$(Q)rm -f $(MIRROR_PATH)/ignore_kdevops
	$(Q)if [ ! -d $(TORVALDS_TARGET) ]; then                            \
	 echo "          CLONE Torvald's tree"                             ;\
	 git -C $(MIRROR_PATH) clone --mirror $(TORVALDS) $(TORVALDS_TARGET) ;\
	fi
	$(Q)if [ ! -d $(STABLE_TARGET) ]; then                                                        \
	 echo "          CLONE linux-stable"                                                         ;\
	 git -C $(MIRROR_PATH) clone --mirror $(STABLE) --reference /mirror/linux.git $(STABLE_TARGET) ;\
	fi
	$(Q)if [ ! -d $(NEXT_TARGET) ]; then                                                      \
	  echo "          CLONE linux-next"                                                       ;\
	  git -C $(MIRROR_PATH) clone --mirror $(NEXT) --reference /mirror/linux.git $(NEXT_TARGET) ;\
	fi
	$(Q)if [ ! -d $(QEMU_TARGET) ]; then                        \
	  echo "          CLONE qemu"                               ;\
	  git -C $(MIRROR_PATH) clone --mirror $(QEMU) $(QEMU_TARGET) ;\
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
