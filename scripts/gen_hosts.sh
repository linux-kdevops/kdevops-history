#!/bin/bash

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

KDEVOPSPYTHONINTERPRETER=$CONFIG_KDEVOPS_PYTHON_INTERPRETER

cat_template_hosts_sed $KDEVOPS_HOSTS_TEMPLATE > $KDEVOPS_HOSTS
