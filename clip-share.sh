#!/usr/bin/env bash
function is_remote() { [[ $CLIPSHARE_MODE == "remote" ]]; }
function is_local() { [[ -z $CLIPSHARE_MODE ]] || [[ $CLIPSHARE_MODE == "local" ]]; }

! is_remote && ! is_local && echo "set CLIPSHARE_MODE [local] or [remote]" && exit 1
is_local && [[ $# == 0 ]] && echo "$0 <remote host>" && exit 1
is_local && host="$1"
is_local && CLIPSHARE_MODE='local'

is_remote && [[ -z $DISPLAY ]] && export DISPLAY=':0'

cmdcheck() { type >/dev/null 2>&1 "$@"; }

# for alias
shopt -s expand_aliases
if [[ $(uname) == "Darwin" ]]; then
	alias c='pbcopy'
	alias p='pbpaste'
	alias base64encode='base64'
	alias base64decode='base64 -D'
fi
if [[ $(uname -a) =~ "Ubuntu" ]]; then
	if cmdcheck xclip; then
		alias c='xclip -sel clip'
		alias p='xclip -o -sel clip'
	elif cmdcheck xsel; then
		alias c='xsel --clipboard --input'
		alias p='xsel --clipboard --output'
	fi
	alias base64encode='base64 -w 0'
	alias base64decode='base64 -d'
fi
if [[ "$OS" =~ "Windows" ]]; then
	if [[ -e /dev/clipboard ]]; then
		alias p='(cat /dev/clipboard)'
		alias c='(cat > /dev/clipboard)'
	else
		cmdcheck gopaste && alias p='gopaste'
		cmdcheck gocopy && alias c='gocopy'
	fi
	alias base64encode='base64 -w 0'
	alias base64decode='base64 -d'
fi

alias log='echo 1>&2'

# pipe wait loop
function pipe_loop() {
	local clipboard_encoded=$(p | base64encode)
	while read LINE; do
		local clipboard_encoded_tmp="$LINE"
		if [[ -n $clipboard_encoded_tmp ]] && [[ $clipboard_encoded != $clipboard_encoded_tmp ]]; then
			local clipboard_encoded="$clipboard_encoded_tmp"
			log "[$CLIPSHARE_MODE]:pipe_loop [$clipboard_encoded]($(echo $clipboard_encoded | base64decode))"
			echo "$clipboard_encoded" | base64decode | c
		fi
	done
}

# watch clipboard
function watch_loop() {
	local interval="0.25"
	local clipboard_encoded=""
	while true; do
		local clipboard_encoded_tmp=$(p | base64encode)
		if [[ -n $clipboard_encoded_tmp ]] && [[ "$clipboard_encoded" != "$clipboard_encoded_tmp" ]]; then
			local clipboard_encoded="$clipboard_encoded_tmp"
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
	# remote server
	# base64 -d: linux
	# base64 -D: darwin
	watch_loop | ssh $host "bash -c 'CLIPSHARE_MODE=remote && eval \"\$(echo $(cat $0 | base64encode) | if [[ \$(uname) == Darwin ]]; then base64 -D; else base64 -d; fi)\"'" | pipe_loop
fi
