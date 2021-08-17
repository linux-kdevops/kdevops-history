#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# Generates the ansible hosts files for workflow agnostic setups.

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

KDEVOPSPYTHONINTERPRETER=$CONFIG_KDEVOPS_PYTHON_INTERPRETER
KDEVOPSPYTHONOLDINTERPRETER=$CONFIG_KDEVOPS_PYTHON_OLD_INTERPRETER

cat_template_hosts_sed $KDEVOPS_HOSTS_TEMPLATE > $KDEVOPS_HOSTS
