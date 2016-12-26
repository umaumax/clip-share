#!/bin/bash
# run on server

_log() {
	true
	# echo "$@" 1>&2
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

	running_shell=$(readlink /proc/$$/exe)
	running_shell=${running_shell##*/}
	if [ "$running_shell" = "bash" ]; then
		c() {
			xsel -bi $@
		}
		p() {
			xsel -bo $@
		}
		b64e() {
			stdbuf -i0 -o0 -e0 base64 $@
		}
		b64d() {
			base64 -d $@
		}
	else
		alias c='xsel -bi'
		alias p='xsel -bo'
		alias b64e='stdbuf -i0 -o0 -e0 base64'
		alias b64d='base64 -d'
	fi
elif [ -n "$_Linux" ]; then
	# DISPLAY=Xサーバー名:ディスプレイ番号.スクリーン番号
	#	if [ ! -n "$DISPLAY" ]; then
	#	export DISPLAY=':0'
	#	fi
	running_shell=$(readlink /proc/$$/exe)
	running_shell=${running_shell##*/}
	if [ "$running_shell" = "bash" ]; then
		c() {
			xclip -i $@
		}
		p() {
			xclip -o $@
		}
		b64e() {
			stdbuf -i0 -o0 -e0 base64 $@
		}
		b64d() {
			base64 -d $@
		}
	else
		alias c='xclip -i'
		alias p='xclip -o'
		alias b64e='base64'
		alias b64d='base64 -d'
	fi
fi

if [ -n "$_Darwin" ]; then
	running_shell=$(ps $$ | tail -n 1 | sed "s/\s\+/ /g" | tr -s ' ' | cut -d" " -f5)
	running_shell=${running_shell##*/}

	if [ "$running_shell" = "bash" ]; then
		c() {
			pbcopy $@
		}
		p() {
			pbpaste $@
		}
		b64e() {
			base64 $@
		}
		b64d() {
			base64 -D $@
		}
	else
		alias c='pbcopy'
		alias p='pbpaste'
		alias b64e='base64'
		alias b64d='base64 -D'
	fi
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
		clipboard="$tmp"
		ret=$(echo "$clipboard" | b64e)
		printf "%s\n" "$ret"
		printf "\n"
		_log "[$host] send [$clipboard] [$ret]"
	fi
	sleep "$interval"
done

_log "[$host] end"
