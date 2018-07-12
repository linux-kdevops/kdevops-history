#!/bin/bash

install_basic_reqs()
{
	case "$VERSION_ID" in
	15.0)
		zypper install -n git e2fsprogs automake gcc libuuid1 quota \
			attr make xfsprogs libgdbm4 gawk acl bc \
			dump indent libtool lvm2 psmisc sed xfsdump \
			libacl-devel libattr-devel libaio-devel libuuid-devel \
			openssl-devel xfsprogs-devel ca-certificates-suse
		;;
	esac
}

opensuse-leap_install_gcc()
{
	install_basic_reqs
}

opensuse-leap_install_git()
{
	install_basic_reqs
}

opensuse-leap_install_make()
{
	install_basic_reqs
}

opensuse-leap_install_automake()
{
	install_basic_reqs
}

opensuse-leap_install_gawk()
{
	install_basic_reqs
}

opensuse-leap_install_chattr()
{
	install_basic_reqs
}

opensuse-leap_install_fio()
{
	case "$VERSION_ID" in
	15.0)
		zypper install -n fio
		;;
	esac
}

opensuse-leap_install_dbench()
{
	case "$VERSION_ID" in
	15.0)
		zypper install -n dbench
		;;
	esac
}

opensuse-leap_install_setcap()
{
	case "$VERSION_ID" in
	15.0)
		zypper install -n libcap-progs
		;;
	esac
}

opensuse-leap_install_setfattr()
{
	case "$VERSION_ID" in
	15.0)
		zypper install -n attr libattr1 libattr-devel
		;;
	esac
}

opensuse-leap_read_osfile()
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

setup_xfs_test()
{
	case "$VERSION_ID" in
	15.0)
		mkfs.xfs -f $TEST_DEV
		;;
	esac
}

opensuse-leap_test_dev_setup()
{
	eval $(grep '^TEST_DEV=' configs/$HOST.config)
	eval $(grep '^TEST_DIR=' configs/$HOST.config)
	if [ "$DRY_RUN" = "true" ]; then
		return
	fi
	xfs_info $TEST_DEV 2>/dev/null
	if [ $? -ne 0 ]; then
		if [ ! -z "$VERSION_ID" ]; then
			if [ "$FSTYP" = "xfs" ] ; then
				setup_xfs_test
				mount $TEST_DEV $TEST_DIR
			fi
		fi
	else
		check_mount $TEST_DIR
		if [ $? -ne 0 ]; then
			mount $TEST_DEV $TEST_DIR
		fi
	fi
}

opensuse-leap_special_expunges()
{
	case "$VERSION_ID" in
	15.0) # on 4.12.* kernel
		if [ "$FSTYP" = "xfs" ] ; then
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-y2038.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/reqs-xfsprogs-4.5.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/maybe-broken.txt"
			oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/xfs/xfsprogs-maintainer.txt"
		fi
		;;
	esac
}

opensuse-leap_skip_groups()
{
	case "$VERSION_ID" in
	15.0) # on 4.12.* kernel
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

opensuse-leap_queue_sections()
{
	case "$VERSION_ID" in
	# Note: CONFIG_XFS_RT is not enabled as of OpenSUSE Leap 15
	# as such we always skip the xfs_realtimedev section test :)
	15.0) # on 4.12.* kernel
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

opensuse-leap_restart_ypbind()
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

opensuse-leap_distro_kernel_check()
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
