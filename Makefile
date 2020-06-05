KDEVOPS_PLAYBOOKS_DIR :=	playbooks
KDEVOPS_HOSTFILE :=		hosts

include Makefile.kdevops

# disable built-in rules for this file
.SUFFIXES:

.DEFAULT: kdevops_deps
