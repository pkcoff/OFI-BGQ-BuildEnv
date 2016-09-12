#!/bin/bash

function print_status () {
	local _jobid=$1

	local _file=`find . -path "./testsuite*" | grep $_jobid.xml`

	echo -en "`grep STATUS $_file | grep pass | wc -l` / `grep STATUS $_file | wc -l` \t"
}

_all="$*"

echo "Monitoring testsuite summary file(s)..."
echo
for _one in $_all; do
	_pwd=`pwd`
	echo "  $_one    `find $_pwd -path "$_pwd/testsuite*" | grep $_one.xml`"
done
echo

for _one in $_all; do
	echo -en "- $_one -\t"
done
echo
echo

while true; do
	echo -en "\r"
	for _one in $_all; do
		print_status $_one
	done

	sleep 5
done



