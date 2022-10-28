USER_SYSTEM := ~/.config/systemd/user/
MIRROR_PATH := /mirror/

LINUX_SERVICES := linux-mirror.service
LINUX_SERVICES += linux-stable-mirror.service
LINUX_SERVICES += linux-next-mirror.service

LINUX_TIMERS := linux-mirror.timer
LINUX_TIMERS += linux-stable-mirror.timer
LINUX_TIMERS += linux-next-mirror.timer

GIT_DAEMON_FILES := git-daemon@.service
GIT_DAEMON_FILES += git-daemon.socket
LOCAL_SYSTEMD    := /usr/local/lib/systemd/system/

TORVALDS := git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
STABLE   := git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
NEXT     := git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

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
	$(NQ) "          CLONE Torvald's tree"
	$(Q)git -C $(MIRROR_PATH) clone --bare $(TORVALDS)
	$(NQ) "          CLONE linux-stable"
	$(Q)git -C $(MIRROR_PATH) clone --bare $(STABLE) --reference /mirror/linux.git linux-stable.git
	$(NQ) "          CLONE linux-next"
	$(Q)git -C $(MIRROR_PATH) clone --bare $(NEXT) --reference /mirror/linux.git linux-next.git

install:
	$(Q)mkdir -p $(USER_SYSTEM)
	$(Q)cp $(LINUX_SERVICES) $(USER_SYSTEM)
	$(Q)cp $(LINUX_TIMERS) $(USER_SYSTEM)
	$(Q)for i in $(LINUX_SERVICES); do            \
		echo  "Enabling $$i" ;                \
		systemctl --user enable  $$i ;        \
	done
	$(Q)for i in $(LINUX_TIMERS); do              \
		echo  "Enabling $$i" ;                \
		systemctl --user enable $$i ;         \
		systemctl --user start $$i ;          \
	done
	$(NQ) "          ENABLE git-daemon"
	$(Q)sudo mkdir -p $(LOCAL_SYSTEMD)
	$(Q)sudo cp $(GIT_DAEMON_FILES) $(LOCAL_SYSTEMD)
	$(Q)sudo systemctl enable git-daemon.socket
	$(Q)sudo systemctl start git-daemon.socket
