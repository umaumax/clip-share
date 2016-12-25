#!/bin/sh
# run on server

_log() {
	true
	#	echo "$@" 1>&2
}

if [ -n "$1" ]; then
	export DISPLAY=$1
fi

if [[ `uname` == "Darwin" ]]; then
	_Darwin="True"
elif [[ `uname -a` =~ "Ubuntu" ]]; then
	_Ubuntu="True"
fi

if [[ `uname` == "Linux" ]]; then
	_Linux="True"
fi

if [ -n "$_Ubuntu" ]; then
	# DISPLAY=Xサーバー名:ディスプレイ番号.スクリーン番号
	# UbuntuではDISPLAYの値ごとにclipboardが異なる
	export DISPLAY=':0'
	alias c='xsel -bi'
	alias p='xsel -bo'
	alias b64e='stdbuf -i0 -o0 -e0 base64'
	alias b64d='base64 -d'
elif [ -n "$_Linux" ]; then
	# DISPLAY=Xサーバー名:ディスプレイ番号.スクリーン番号
	#	if [ ! -n "$DISPLAY" ]; then
	#	export DISPLAY=':0'
	#	fi
	alias c='xclip -i'
	alias p='xclip -o'
	alias b64e='stdbuf -i0 -o0 -e0 base64'
	alias b64d='base64 -d'
fi

if [ -n "$_Darwin" ]; then
	alias c='pbcopy'
	alias p='pbpaste'
	alias b64e='base64'
	alias b64d='base64 -D'
fi

# check clipboard
_tmp=$(p 2>&1)
code="$?"
if [ "$code" != "0" ]; then
	echo "$_tmp" 1>&2
	exit 1
fi

interval=1

host=$(hostname)":c2s"
_log "[$host] DISPLAY=$DISPLAY"
_log "[$host] negotiation start"
# negotiation
printf "Y2xpcC1zaGFyZQo=\n"
_log "[$host] negotiation end"

_log "[$host] start send loop"
clipboard=""
while true; do
	tmp=$(p)
	if [ "$clipboard" != "$tmp" ]; then
		clipboard=$tmp
		ret=$(echo "$clipboard" | b64e)
		printf "%s\n" "$ret"
		printf "\n"
		_log "[$host] send [$clipboard]"
	fi
	sleep "$interval"
done

_log "[$host] end"
