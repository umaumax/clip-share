#!/bin/sh

server=$1
cat c2s.sh | command ssh "$server" | ./s2c.sh

