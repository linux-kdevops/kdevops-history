#!/bin/bash

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd vagrant
vagrant destroy -f
rm -rf .vagrant
