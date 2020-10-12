#!/bin/bash

REPO_URL=$1
REPO_NAME=$2

YAST_REPOS=$(zypper lr -d | grep yast2 | awk '{print $1}')
for i in $YAST_REPOS; do
	zypper rr $i
done

zypper mr -e $REPO_NAME 2>&1 > /dev/null
if [[ $? -eq 0 ]]; then
	exit 0
fi

zypper ar -f -c $REPO_URL $REPO_NAME
zypper --non-interactive --gpg-auto-import-keys refresh $REPO_NAME
