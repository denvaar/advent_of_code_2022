#!/usr/bin/env bash

COMMANDS=$(cat ../input.txt | \
	sed -e "s/\$ cd \//cd ~\/root/" \
	    -e "s/\$ cd \(.*\)/cd \1/" \
	    -e "/\$ ls/d" \
	    -e "s/dir \(.*\)/mkdir \1/" | \
	    sed -E -e "s/([0-9]+) (.*)$/dd of=\2 bs=\1 seek=1 count=0/")

# eval "$COMMANDS"


mkdir ~/root
while IFS= read -r cmd; do
  eval " $cmd";
done <<< "$COMMANDS"

cd ~

find root -maxdepth 5000000 -type f -sparse -print0 | \
	xargs -0 ls -l | \
	awk '{print $9, $5}' | \
	sort
