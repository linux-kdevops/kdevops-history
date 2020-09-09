#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/scripts/workflows/fstests/lib.sh

XFS_SECTIONS="crc"
XFS_SECTIONS="$XFS_SECTIONS nocrc"
XFS_SECTIONS="$XFS_SECTIONS nocrc_512"
XFS_SECTIONS="$XFS_SECTIONS reflink"
XFS_SECTIONS="$XFS_SECTIONS reflink"
XFS_SECTIONS="$XFS_SECTIONS reflink_1024"
XFS_SECTIONS="$XFS_SECTIONS reflink_normapbt"
XFS_SECTIONS="$XFS_SECTIONS logdev"
XFS_SECTIONS="$XFS_SECTIONS rtdev"

if [[ "$CONFIG_FSTESTS_XFS_SECTION_BIGBLOCK" == "y" ]]; then
	XFS_SECTIONS="$XFS_SECTIONS bigblock"
fi

export XFS_SECTIONS

add_host_entry()
{
	TARGET_HOST=$1
	SECOND_IP=$2
	TARGET_FILE=$3

	echo "  - name: $TARGET_HOST" >> $TARGET_FILE
	echo "    ip: $SECOND_IP" >> $TARGET_FILE
}

xfs_generate_nodes_file()
{
	TMP_INIT_NODE=$(mktemp)
	if [ ! -f $TMP_INIT_NODE ]; then
		echo "Cannot create temporary file: $TMP_INIT_NODE do you have mktemp installed?"
		exit 1
	fi
	TMP_FINAL_NODE=$(mktemp)
	if [ ! -f $TMP_FINAL_NODE ]; then
		echo "Cannot create temporary file: $TMP_FINAL_NODE"
		exit 1
	fi

	cp $GENERIC_SPLIT_START $TMP_INIT_NODE

	KCONFIG_SECTION_PREFIX="CONFIG_FSTESTS_XFS_SECTION_"
	SECOND_IP_START="172.17.8."
	IP_LAST_OCTET_START="100"
	CURRENT_IP="1"
	for i in $XFS_SECTIONS; do
		SECTION_POSTFIX="${i^^}"
		SECTION="${KCONFIG_SECTION_PREFIX}${SECTION_POSTFIX}"
		SECTION_HOSTNAME_POSTFIX="$(echo $i | sed -e 's|_|-|')"
		PROCESS_SECTION="y"
		grep -q "$SECTION=y" ${TOPDIR}/.config
		if [[ $? -ne 0 && "$CONFIG_FSTESTS_XFS_MANUAL_COVERAGE" == "y" ]]; then
			continue
		fi
		let IP_LAST_OCTET="$IP_LAST_OCTET_START+$CURRENT_IP"
		SECOND_IP="${SECOND_IP_START}${IP_LAST_OCTET}"
		TARGET_HOSTNAME="kdevops-xfs-${SECTION_HOSTNAME_POSTFIX}"
		add_host_entry $TARGET_HOSTNAME $SECOND_IP $TMP_INIT_NODE
		let CURRENT_IP="$CURRENT_IP+1"
		if [[ "$CONFIG_FSTESTS_XFS_BASELINE_AND_DEV" == "y" ]]; then
			SECTION_HOSTNAME_POSTFIX="$(echo $i | sed -e 's|_|-|')"
			let IP_LAST_OCTET="$IP_LAST_OCTET_START+$CURRENT_IP"
			SECOND_IP="${SECOND_IP_START}${IP_LAST_OCTET}"
			TARGET_HOSTNAME="kdevops-xfs-${SECTION_HOSTNAME_POSTFIX}-dev"
			add_host_entry $TARGET_HOSTNAME $SECOND_IP $TMP_INIT_NODE
			let CURRENT_IP="$CURRENT_IP+1"
		fi
	done

	cat $TMP_INIT_NODE $GENERIC_SPLIT_END > $TMP_FINAL_NODE
	cat_template_nodes_sed $TMP_FINAL_NODE > $KDEVOPS_NODES

	rm -f $TMP_INIT_NODE $TMP_FINAL_NODE
}
