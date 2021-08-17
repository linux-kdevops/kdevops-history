# SPDX-License-Identifier: copyleft-next-0.3.1

kconfig_y_to_true_false()
{
	if [[ "$1" == "y" ]]; then
		echo "true"
	else
		echo "false"
	fi
}

import_generic_terraform_vars()
{
	LIMITBOXES=$(kconfig_y_to_true_false $CONFIG_TERRAFORM_LIMIT_BOXES)
	LIMITNUMBOXES=$CONFIG_TERRAFORM_LIMIT_NUM_BOXES
	if [[ "$LIMITNUMBOXES" == "" ]]; then
		LIMITNUMBOXES=1
	fi

	SSHCONFIGPUBKEYFILE=$CONFIG_TERRAFORM_SSH_CONFIG_PUBKEY_FILE
	SSHCONFIGUSER=$CONFIG_TERRAFORM_SSH_CONFIG_USER
	SSHCONFIGFILE=$CONFIG_KDEVOPS_SSH_CONFIG
	SSHCONFIGUPDATE="$(kconfig_y_to_true_false $CONFIG_KDEVOPS_SSH_CONFIG_UPDATE)"
	SSHCONFIGSTRICT="$(kconfig_y_to_true_false $CONFIG_KDEVOPS_SSH_CONFIG_UPDATE_STRICT)"
	SSHCONFIGBACKUP="$(kconfig_y_to_true_false $CONFIG_KDEVOPS_SSH_CONFIG_UPDATE_BACKUP)"
}
