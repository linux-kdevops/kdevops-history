#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config

add_host_entry()
{
	TARGET_HOST=$1
	SECOND_IP=$2
	TARGET_FILE=$3

	echo "  - name: $TARGET_HOST" >> $TARGET_FILE
	echo "    ip: $SECOND_IP" >> $TARGET_FILE
}
