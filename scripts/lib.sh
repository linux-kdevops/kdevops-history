# SPDX-License-Identifier: copyleft-next-0.3.1

PLAYBOOKDIR=$CONFIG_KDEVOPS_PLAYBOOK_DIR
INVENTORY=$CONFIG_KDEVOPS_ANSIBLE_INVENTORY_FILE
export KDEVOPSHOSTSPREFIX=$CONFIG_KDEVOPS_HOSTS_PREFIX

MANUAL_KILL_NOTICE_FILE="${TOPDIR}/.running_kill_pids.sh"

KERNEL_CI_FAIL_FILE=".kernel-ci.fail"
KERNEL_CI_OK_FILE=".kernel-ci.ok"
KERNEL_CI_FULL_LOG=".kernel-ci.log"
KERNEL_CI_FAIL_LOG=".kernel-ci.fail.log"
KERNEL_CI_DIFF_LOG=".kernel-ci.diff.log"
KERNEL_CI_LOGTIME=".kernel-ci.logtime.loop"
KERNEL_CI_LOGTIME_FULL=".kernel-ci.logtime.full"

KERNEL_CI_WATCHDOG_LOG=".kernel-ci.watchdog.log"
KERNEL_CI_WATCHDOG_RESULTS_NEW=".kernel-ci.status.new"
KERNEL_CI_WATCHDOG_RESULTS=".kernel-ci.status"

KERNEL_CI_WATCHDOG_FAIL_LOG=".kernel-ci.watchdog.fail.log"
KERNEL_CI_WATCHDOG_HUNG=".kernel-ci.watchdog.hung"
KERNEL_CI_WATCHDOG_TIMEOUT=".kernel-ci.watchdog.timeout"

KOTD_LOG=".kotd.log"
KOTD_TMP="${KOTD_LOG}.tmp"
KOTD_BEFORE=".kotd.uname-before.txt"
KOTD_AFTER=".kotd.uname-after.txt"
KOTD_LOGTIME=".kotd.logtime"

# These started files are used by optional manual watchdog tools.
FSTESTS_STARTED_FILE="${TOPDIR}/workflows/fstests/.begin"
BLKTESTS_STARTED_FILE="${TOPDIR}/workflows/blktests/.begin"
REBOOT_LIMIT_STARTED_FILE="${TOPDIR}/workflows/demos/reboot-limit/.begin"

if [[ "$CONFIG_KDEVOPS_WORKFLOW_FSTESTS" == "y" ]]; then
	FSTYP="$CONFIG_FSTESTS_FSTYP"
	TEST_DEV="$CONFIG_FSTESTS_TEST_DEV"
fi
