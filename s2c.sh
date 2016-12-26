#!/bin/bash
# run on client

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
	alias b64e='base64'
	alias b64d='base64 -d'
elif [ -n "$_Linux" ]; then
	# DISPLAY=Xサーバー名:ディスプレイ番号.スクリーン番号
	#	if [ ! -n "$DISPLAY" ]; then
	#	export DISPLAY=':0'
	#	fi
	alias c='xclip -i'
	alias p='xclip -o'
	alias b64e='base64'
	alias b64d='base64 -d'
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

host=$(hostname)":s2c"
_log "[$host] DISPLAY=$DISPLAY"
_log "[$host] negotiation start"

# 1つのcatで入力を受け付けなければ予期せぬ動作をする
# Macの場合は分割catでも入力を受け取れる
# awkの挙動とcatの挙動が異なる

negotiation_flag=""
buf=""
cat | while IFS= read -r line
do
	if [ ! -n "$negotiation_flag" ]; then
		if [ "$line" = "Y2xpcC1zaGFyZQo=" ]; then
			negotiation_flag="on"
			_log "[$host] negotiation end"
		fi
		continue
	fi

	if [ -n "$line" ]; then
		buf="${buf}${line}"
		continue
	fi

	_log "[$host] [line]:$line [buf]:$buf"

	tmp=$(echo "$buf" | b64d)
	buf=""
	clipboard=$(p)
	_log "[$host] recv [$buf] [$tmp]"
	if [ "$clipboard" != "$tmp" ]; then
		echo "$tmp" | c
		clipboard=$tmp
		_log "[$host] copy [$clipboard]"
	fi
done
_log "[$host] end"
