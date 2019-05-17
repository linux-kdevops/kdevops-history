#!/bin/bash
# oscheck fstests cloud-init script.
#
# This script accepts the following variables set and passed:
#
# user_data_log_dir
# user_data_enabled
#
# new_hostname
#
# Note: terraform passed variables must be in the form: dollar{variable},
# where dollar is $ and provides an implicit restriction on bash variables to
# not use this same form for bash variables *not* coming from terraform. This
# restriction applies even to bash comments such as this one. Terraform
# processes these variables prior to giving the file to the host. We cannot
# use this form of variables for user_data scripts then. Or another way to
# say it, terraform implicates restrictions on user_data bash scripts to
# only one way to use bash variables because of how it processes its own
# variables.
#
# Note 2: "let" returns non-zero if the argument passed is 0, use "let" to
# increment variables with care in your bash scripts if using "set -e"

ADMIN_LOG="${user_data_log_dir}/admin.txt"
USERDATA_ENABLED="${user_data_enabled}"

NEW_HOSTNAME="${new_hostname}"

set -e

run_cmd_admin()
{
        if $@ ; then
		DATE=$(date)
                echo "$DATE --- $@" >> $ADMIN_LOG
		return 0
        else
		DATE=$(date)
                echo "$DATE --- Return value: $? --- Command failed: $@ --- " >> $ADMIN_LOG
		return 1
        fi
}

mkdir -p ${user_data_log_dir}

if [ "$USERDATA_ENABLED" != "yes" ]; then
	run_cmd_admin echo "cloud-init: fstests script user data processing disabled"
	exit 0
fi

run_cmd_admin echo "cloud-init: fstests script user data processing enabled"
run_cmd_admin echo "Nothing to do..."

# Add more functionality below if you see fit. Be sure to use a variable
# to allow to easily enable / disable each mechanism.
