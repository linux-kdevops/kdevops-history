#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

if [ -s "${TOPDIR}/vagrant/Kconfig.$1" ]; then
	echo y
else
	echo n
fi
