#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

for i in $(virsh list | awk '{print $2'}| grep kdevops); do
	virsh reset $i
done
