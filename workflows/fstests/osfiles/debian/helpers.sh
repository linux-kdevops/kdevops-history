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
	"testing")
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-y2038.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-4.5.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/maybe-broken.txt"
		fi
		;;
	esac
}

debian_skip_groups()
{
	case "$OSCHECK_RELEASE" in
	"testing")
		if [ "$FSTYP" = "xfs" ] ; then
			SKIP_GROUPS="tape clone dedupe dax dangerous_repair dangerous_online_repair broken"
		fi
		;;
	*)
		;;
	esac

	if [ "$FSTYP" = "xfs" ] ; then
		SKIP_GROUPS="$SKIP_GROUPS encrypt"
	fi

	_SKIP_GROUPS=
	for g in $SKIP_GROUPS; do
		_SKIP_GROUPS="$_SKIP_GROUPS -x $g"
	done
}

debian_queue_sections()
{
	case "$OSCHECK_RELEASE" in
	"testing")
		if [ "$FSTYP" = "xfs" ] ; then
			queue_tests xfs_reflink
			queue_tests xfs_reflink_1024
		fi
		;;
	*)
		;;
	esac

	if [ "$FSTYP" = "xfs" ] ; then
		queue_tests logdev
		queue_tests xfs_nocrc
		queue_tests xfs_nocrc_512
		# As of 4.16.0-2-amd64 Debian still enables CONFIG_XFS_RT
		# this perhaps should soon be reconsidered.
		queue_tests xfs_realtimedev
	fi
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
