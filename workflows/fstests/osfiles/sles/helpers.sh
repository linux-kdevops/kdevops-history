#!/bin/bash

sles_read_osfile()
{
	eval $(grep '^VERSION_ID=' $OS_FILE)
	eval $(grep '^PRETTY_NAME=' $OS_FILE)
	echo "$0 on $PRETTY_NAME ($VERSION_ID) on $(uname -r)"

	if [ ! -e $OS_FILE ]; then
		return
	fi
	if [ -z $OSCHECK_ID ]; then
		return
	fi
}

sles_special_expunges()
{
	case "$VERSION_ID" in
	15.2) # on 5.3 kernel
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-y2038.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/maybe-broken.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		if [ "$FSTYP" = "ext4" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/ext4/xfstests-bld-expunges.txt"
		fi
		;;
	15.3) # on 5.3 kernel
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		if [ "$FSTYP" = "ext4" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/ext4/xfstests-bld-expunges.txt"
		fi
		;;
	15.4)
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		if [ "$FSTYP" = "ext4" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/ext4/xfstests-bld-expunges.txt"
		fi
		;;
	esac
}

sles_skip_groups()
{
	case "$VERSION_ID" in
	15.2) # on 5.3 kernel
		if [ "$FSTYP" = "xfs" ] ; then
			SKIP_GROUPS="tape clone dedupe dax dangerous_repair dangerous_online_repair broken"
		fi
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

sles_queue_sections()
{
	case "$VERSION_ID" in
	15.2) # on 5.3 kernel
		if [ "$FSTYP" = "xfs" ] ; then
			# XXX: we need the hardware to test this.
			# queue_tests dax
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
	fi
}

sles_restart_ypbind()
{
	which ypbind 2 >/dev/null
	if [ $? -ne 0 ]; then
		return
	fi

	case "$VERSION_ID" in
	15.0)
		oscheck_systemctl_restart_ypbind
		;;
	esac
}

sles_distro_kernel_check()
{
	KERNEL_BOOT_CONFIG="/boot/config-$(uname -r)"
	if [ ! -e $KERNEL_BOOT_CONFIG ]; then
		return 1;
	fi
	grep -q "CONFIG_SUSE_KERNEL=y" $KERNEL_BOOT_CONFIG
	if [ $? -eq 0 ]; then
		return 0;
	fi
	return 1
}
