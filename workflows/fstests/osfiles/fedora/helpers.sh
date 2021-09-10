#!/bin/bash

fedora_read_osfile()
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

fedora_special_expunges()
{
	case "$VERSION_ID" in
	28) # on 4.16.* kernel
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-y2038.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-4.5.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/maybe-broken.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		;;
	34)
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		if [ "$FSTYP" = "ext4" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/ext4/xfstests-bld-expunges.txt"
		fi
		;;
	esac
}

fedora_skip_groups()
{
	case "$VERSION_ID" in
	28) # on 4.16.* kernel
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

fedora_queue_sections()
{
	case "$VERSION_ID" in
	# Note: Fedora 28 does not enable CONFIG_XFS_RT as such
	# we always skip the section xfs_realtimedev :)
	28) # on 4.16.* kernel
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

fedora_restart_ypbind()
{
	which ypbind 2 >/dev/null
	if [ $? -ne 0 ]; then
		return
	fi

	case "$VERSION_ID" in
	28)
		oscheck_systemctl_restart_ypbind
		;;
	esac
}

fedora_distro_kernel_check()
{
	KERNEL_VMLINUZ="/boot/vmlinuz-$(uname -r)"
	if [ ! -e $KERNEL_VMLINUZ ]; then
		return 1;
	fi
	file $KERNEL_VMLINUZ | grep -q "fedoraproject.org"
	if [ $? -eq 0 ]; then
		return 0;
	fi
	return 1
}
