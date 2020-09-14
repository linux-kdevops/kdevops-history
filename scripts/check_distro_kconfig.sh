#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

if [ -s "${TOPDIR}/vagrant/Kconfig.$1" ]; then
	echo y
else
	echo n
fi
