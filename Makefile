USER_SYSTEM := .  config/systemd/user/

LINUX_SERVICES := linux-mirror.service
LINUX_SERVICES += linux-stable-mirror.service
LINUX_SERVICES += linux-next-mirror.service

LINUX_TIMERS := linux-mirror.timer
LINUX_TIMERS += linux-stable-mirror.timer
LINUX_TIMERS += linux-next-mirror.timer

TORVALDS := git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
STABLE   := git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
NEXT     := git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

all:

mirror:
	mkdir -p /mirror/
	mkdir git clone 
	cd /mirror
	git clone --bare $(TORVALDS)
	git clone --bare $(STABLE) --reference /mirror/linux.git linux-stable.git
	git clone --bare $(NEXT) --reference /mirror/linux.git linux-next.git
	
install:
	@mkdir -p $(USER_SYSTEM)
	@cp $(LINUX_SERVICES) $(USER_SYSTEM)
	@cp $(LINUX_TIMERS) $(USER_SYSTEM)
	@for i in $(LINUX_SERVICES); do            \
		systemctl --user enable  $$i ;     \
	done
	@for i in $(LINUX_TIMERS); do              \
		systemctl --user enable $$i ;      \
		systemctl --user start $$i ;       \
	done
