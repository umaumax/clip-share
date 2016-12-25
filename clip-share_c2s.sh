#!/bin/sh
server=$1

export LC_CODE=$(cat s2c.sh | base64)
# macをserver側にする場合にはbase64 -Dとなる
./c2s.sh | command ssh "$server" "echo $LC_CODE | base64 -d > .clip-share-tmp.sh; zsh ./.clip-share-tmp.sh"

