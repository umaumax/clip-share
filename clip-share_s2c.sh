#!/bin/bash

server=$1
cat c2s.sh | command ssh "$server" "bash -s" | ./s2c.sh

