# SPDX-License-Identifier: GPL-2.0
source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

FS=$CONFIG_FSTESTS_FSTYP
STRING='CONFIG_FSTESTS_FSTYP='

PID_LIST=$(ps -fu $USER | awk '{print $2}')

for i in $PID_LIST; do
	CONFIG_TARGET="/proc/$i/cwd/.config"
	if [[ ! -f  $CONFIG_TARGET ]]; then
		continue
	fi
	FS_TARGET=$(grep $STRING /proc/$i/cwd/.config | awk -F"=" '{print $2}' | sed -e 's|"||g')
	if [[ "$FS" != "$FS_TARGET" ]]; then
		continue
	fi

	grep -q run_kernel_ci /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		continue
	fi

	grep -q ansible-playbook /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		kill -SIGTERM -- -${i}
		kill -SIGALRM -- -${i}
		kill -SIGALRM ${i}
		continue
	fi

	grep -q make /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		kill -SIGTERM -- -${i}
		kill -SIGTERM ${i}
	fi

	grep -q ssh /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		kill -SIGTERM -- -${i}
		kill -SIGTERM ${i}
	fi
done
