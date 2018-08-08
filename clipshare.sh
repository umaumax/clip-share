#!/usr/bin/env bash
function is_remote() { [[ $CLIPSHARE_MODE == remote ]]; }
function is_local() { [[ $CLIPSHARE_MODE == local ]]; }

is_remote || is_local || (echo "set CLIPSHARE_MODE [local] or [remote]" && exit 1)
is_local && [[ $# == 0 ]] && echo "$0 <remote host>" && exit 1
is_local && host="$1"

is_remote && export DISPLAY=':0'

shopt -s expand_aliases
if [[ $(uname) == "Darwin" ]]; then
	alias c='pbcopy'
	alias p='pbpaste'
	alias base64encode='base64'
	alias base64decode='base64 -D'
fi
if [[ $(uname -a) =~ "Ubuntu" ]]; then
	alias c='xsel -bi'
	alias p='xsel -bo'
	alias base64encode='base64 -w 0'
	alias base64decode='base64 -d'
fi
if [[ "$OS" =~ "Windows" ]]; then
	alias p='gopaste'
	alias c='gocopy'
	alias base64encode='base64 -w 0'
	alias base64decode='base64 -d'
fi

alias log='echo 1>&2'

clipboard_encoded=$(p | base64encode)
# pipe wait loop
function pipe_loop() {
	while read LINE; do
		clipboard_encoded_tmp="$LINE"
		if [[ $clipboard_encoded != $clipboard_encoded_tmp ]]; then
			clipboard_encoded="$clipboard_encoded_tmp"
			log "[$CLIPSHARE_MODE]:pipe_loop [$clipboard_encoded]($(echo $clipboard_encoded | base64decode))"
			echo "$clipboard_encoded" | base64decode | c
		fi
	done
}

# watch clipboard
function watch_loop() {
	interval=1
	clipboard_encoded=$(p | base64encode)
	while true; do
		clipboard_encoded_tmp=$(p | base64encode)
		if [[ "$clipboard_encoded" != "$clipboard_encoded_tmp" ]]; then
			clipboard_encoded="$clipboard_encoded_tmp"
			# to local or remote
			echo "$clipboard_encoded"
			log "[$CLIPSHARE_MODE]:watch_loop [$clipboard_encoded]($(echo $clipboard_encoded | base64decode))"
		fi
		sleep "$interval"
	done
}

if is_remote; then
	pipe_loop | watch_loop
fi

if is_local; then
	# base64 -d: linux
	# base64 -D: darwin
	watch_loop | ssh $host "bash -c 'CLIPSHARE_MODE=remote && eval \$(echo $(cat $0 | base64encode) | base64 -D)'" | pipe_loop
fi
