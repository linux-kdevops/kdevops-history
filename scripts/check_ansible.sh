#!/bin/bash

if which ansible-playbook >/dev/null; then
    echo "ansible existed"
else
    if which pip > /dev/null; then
    	echo "Start to install ansible"
	pip install ansible
    	echo "Ansible installed"
    else
	echo "install pip befoer starting this script"
    fi
fi
