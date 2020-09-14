#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd vagrant
vagrant destroy -f
rm -rf .vagrant
