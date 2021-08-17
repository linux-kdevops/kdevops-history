#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd terraform/${KDEVOPS_CLOUD_PROVIDER}
terraform destroy -auto-approve
