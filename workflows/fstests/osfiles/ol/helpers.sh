#!/bin/bash

ol_read_osfile()
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

ol_skip_groups()
{
	if [ "$FSTYP" = "xfs" ] ; then
		SKIP_GROUPS="$SKIP_GROUPS encrypt"
	fi

	_SKIP_GROUPS=
	for g in $SKIP_GROUPS; do
		_SKIP_GROUPS="$_SKIP_GROUPS -x $g"
	done
}

ol_distro_kernel_check()
{
        KERNEL_BOOT_CONFIG="/boot/config-$(uname -r)"
        if [ ! -e $KERNEL_BOOT_CONFIG ]; then
                return 1;
        fi
        rpm -qf $KERNEL_BOOT_CONFIG 2>&1 > /dev/null
        if [ $? -eq 0 ]; then
                return 0;
        fi
        return 1
}
