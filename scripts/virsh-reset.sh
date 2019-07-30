#!/bin/bash

for i in $(virsh list | awk '{print $2'}| grep kdevops); do
	virsh reset $i
done
