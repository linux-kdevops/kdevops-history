#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/scripts/workflows/fstests/ext4/lib.sh

add_ansible_host()
{
	TARGET_HOST=$1
	TARGET_FILE=$2

	echo "$TARGET_HOST" >> $TARGET_FILE
}

add_ansible_hosts_by_section()
{
	TARGET_FILE=$1
	TARGET_PYTHON_INTERPRETER=$2
	TARGET_SECTION=$3

	if [[ "$TARGET_SECTION" == "dev" && "$CONFIG_KDEVOPS_BASELINE_AND_DEV" != "y" ]]; then
		return
	fi

	echo "[$TARGET_SECTION]" >> $TARGET_FILE

	KCONFIG_SECTION_PREFIX="CONFIG_FSTESTS_EXT4_SECTION_"
	for i in $EXT4_SECTIONS; do
		SECTION_POSTFIX="${i^^}"
		SECTION="${KCONFIG_SECTION_PREFIX}${SECTION_POSTFIX}"
		SECTION_HOSTNAME_POSTFIX="$(echo $i | sed -e 's|_|-|')"
		grep -q "^$SECTION=y" ${TOPDIR}/.config
		if [[ "$CONFIG_FSTESTS_EXT4_MANUAL_COVERAGE" == "y" && $? -ne 0 ]]; then
			continue
		fi
		TARGET_HOSTNAME="${KDEVOPSHOSTSPREFIX}-ext4-${SECTION_HOSTNAME_POSTFIX}"

		case "$TARGET_SECTION" in
		all)
			add_ansible_host $TARGET_HOSTNAME $TARGET_FILE
			;;
		baseline)
			add_ansible_host $TARGET_HOSTNAME $TARGET_FILE
			;;
		dev)
			;;
		esac

		if [[ "$CONFIG_KDEVOPS_BASELINE_AND_DEV" == "y" ]]; then
			SECTION_HOSTNAME_POSTFIX="$(echo $i | sed -e 's|_|-|')"
			TARGET_HOSTNAME="${KDEVOPSHOSTSPREFIX}-ext4-${SECTION_HOSTNAME_POSTFIX}-dev"

			case "$TARGET_SECTION" in
			all)
				add_ansible_host $TARGET_HOSTNAME $TARGET_FILE
				;;
			baseline)
				;;
			dev)
				add_ansible_host $TARGET_HOSTNAME $TARGET_FILE
				;;
			esac
		fi
	done

	echo "[${TARGET_SECTION}:vars]" >> $TARGET_FILE
	echo "ansible_python_interpreter =  \"@${TARGET_PYTHON_INTERPRETER}@\"" >> $TARGET_FILE
}

add_ansible_hosts_all()
{
	TMP_ANSIBLE_HOSTS=$(mktemp)
	if [ ! -f $TMP_ANSIBLE_HOSTS ]; then
		echo "Cannot create temporary file: $TMP_ANSIBLE_HOSTS do you have mktemp installed?"
		exit 1
	fi

	add_ansible_hosts_by_section $TMP_ANSIBLE_HOSTS KDEVOPSPYTHONINTERPRETER all
	add_ansible_hosts_by_section $TMP_ANSIBLE_HOSTS KDEVOPSPYTHONINTERPRETER baseline
	add_ansible_hosts_by_section $TMP_ANSIBLE_HOSTS KDEVOPSPYTHONINTERPRETER dev

	mv $TMP_ANSIBLE_HOSTS $KDEVOPS_HOSTS_TEMPLATE
}

add_ansible_hosts_all
