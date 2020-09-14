#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd terraform/${KDEVOPS_CLOUD_PROVIDER}
terraform destroy -auto-approve
