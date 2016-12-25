#!/bin/sh
cd $(dirname $0)
#exit 0

if [ -z "$1" ]
then
	echo "$0 'server'"
	exit 1
fi

server=$1

echo "[start] clipboard share localhost<-> $server"
./clip-share_c2s.sh "$server" | ./clip-share_s2c.sh "$server"
echo "[end] clipboard share localhost<-> $server"
