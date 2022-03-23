#!/bin/bash
OS_FILE="/etc/os-release"

if [[ ! -f $OS_FILE ]]; then
	echo n
fi

check_distro()
{
	grep -qi $1 $OS_FILE
	if [[ $? -eq 0 ]]; then
		echo y
		exit
	fi
	echo n
	exit
}

check_distro_redhat()
{
	grep -qi fedora $OS_FILE
	if [[ $? -eq 0 ]]; then
		echo n
		exit
	fi
	grep -qi redhat $OS_FILE
	if [[ $? -eq 0 ]]; then
		echo y
		exit
	fi
	echo n
	exit
}

check_distro_suse()
{
	grep -vi opensuse $OS_FILE | grep -qi suse
	if [[ $? -eq 0 ]]; then
		echo y
		exit
	fi
	echo n
	exit
}

check_distro_ubuntu()
{
	grep -vi debian $OS_FILE | grep -qi ubuntu
	if [[ $? -eq 0 ]]; then
		echo y
		exit
	fi
	echo n
	exit
}


case $1 in
debian)
	check_distro $1
	;;
fedora)
	check_distro $1
	;;
opensuse)
	check_distro $1
	;;
redhat)
	check_distro_redhat $1
	;;
suse)
	check_distro_suse $1
	;;
ubuntu)
	check_distro_ubuntu $1
	;;
*)
	echo n
	exit
esac
