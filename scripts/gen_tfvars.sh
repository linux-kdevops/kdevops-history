#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

# Set some defaults and ensure these are locally defined
# variables so we can let our helpers override. These variables
# will be sed replaced.
LIMITBOXES="false"
LIMITNUMBOXES="1"

# Just for our own use
CLOUD_PROVIDER="aws"
TEMPLATE_TFVARS_BASE_DIR="terraform/templates"
TEMPLATE_TFVARS_FILE_NAME="terraform.tfvars"
TEMPLATE_TFVARS_FILE_POSTFIX="${TEMPLATE_TFVARS_FILE_NAME}.in"

# this will also correspond to the directory
if [[ "$CONFIG_TERRAFORM_AWS" == "y" ]]; then
	CLOUD_PROVIDER="aws"
elif [[ "$CONFIG_TERRAFORM_GCE" == "y" ]]; then
	CLOUD_PROVIDER="gce"
elif [[ "$CONFIG_TERRAFORM_AZURE" == "y" ]]; then
	CLOUD_PROVIDER="azure"
elif [[ "$CONFIG_TERRAFORM_OPENSTACK" == "y" ]]; then
	CLOUD_PROVIDER="openstack"
fi

TEMPLATE_TFVARS="${TEMPLATE_TFVARS_BASE_DIR}/${CLOUD_PROVIDER}/${TEMPLATE_TFVARS_FILE_POSTFIX}"
TEMPLATE_TFVARS_TARGET="terraform/${CLOUD_PROVIDER}/${TEMPLATE_TFVARS_FILE_NAME}"

import_generic_terraform_vars
import_${CLOUD_PROVIDER}_terraform_vars

cat_template_terraform_sed $TEMPLATE_TFVARS > $TEMPLATE_TFVARS_TARGET
