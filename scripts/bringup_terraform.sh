#!/bin/bash

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd terraform/${KDEVOPS_CLOUD_PROVIDER}
terraform init
terraform plan
terraform apply -auto-approve
