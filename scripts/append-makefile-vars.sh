#!/bin/bash

STR=""

while [[ ${#1} -gt 0 ]]; do
	STR="${STR}${1}"
	shift
done

echo $STR
