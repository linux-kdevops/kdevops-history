#!/bin/bash

debian_read_osfile()
{
	PRETTY_NAME=$(lsb_release -i -s)
	VERSION_ID="$OSCHECK_RELEASE"
	echo "$0 on $PRETTY_NAME ($OSCHECK_RELEASE) on $(uname -r)"

	if [ ! -e $OS_FILE ]; then
		return
	fi
	if [ -z $OSCHECK_ID ]; then
		return
	fi
}

debian_special_expunges()
{
	case "$OSCHECK_RELEASE" in
	"10")
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-4.20.txt"
		fi
		;;
	"11")
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-5.10.txt"
		fi
		;;
	"testing")
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-5.18.txt"
		fi
		;;
	esac

	if [ "$FSTYP" = "ext4" ] ; then
		oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/ext4/xfstests-bld-expunges.txt"
	fi
}

debian_skip_groups()
{
	if [ "$FSTYP" = "xfs" ] ; then
		SKIP_GROUPS="$SKIP_GROUPS encrypt"
	fi

	_SKIP_GROUPS=
	for g in $SKIP_GROUPS; do
		_SKIP_GROUPS="$_SKIP_GROUPS -x $g"
	done
}

debian_restart_ypbind()
{
	which ypbind 2 >/dev/null
	if [ $? -ne 0 ]; then
		return
	fi
	case "$OSCHECK_RELEASE" in
	"testing")
		oscheck_systemctl_restart_ypbind
		;;
	esac
}

debian_distro_kernel_check()
{
	KERNEL_BOOT_CONFIG="/boot/config-$(uname -r)"
	if [ ! -e $KERNEL_BOOT_CONFIG ]; then
		return 1;
	fi
	CERT="$(grep CONFIG_SYSTEM_TRUSTED_KEYS $KERNEL_BOOT_CONFIG | head -1 | awk -F"=" '{print $2}' | sed -e 's/"//g')"
	echo $CERT | grep -q debian
	if [ $? -eq 0 ]; then
		return 0;
	fi
	return 1
}
