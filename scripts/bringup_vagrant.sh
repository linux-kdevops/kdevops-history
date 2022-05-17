#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

# This is just a workaround for fedora since we have an old vagrant-libvirt
# plugin that doesn't work with parallel
ARG=
vagrant plugin list | grep -q 'vagrant-libvirt (0.7.0, system)'
[ $? -eq 0 ] && ARG='--no-parallel'

cd vagrant
vagrant up $ARG
