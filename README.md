# clip share command

## how to use

macでX11を使いたいとき...

```
brew cask install xquartz
```

その後iTermの再起動でDISPLAYが設定される
もしくはxTermから接続する

## 事前設定
add below setting to~/.ssh.config
```
ForwardX11 yes
ForwardX11Trusted yes
```

## vim on server

+clipboardの存在を確認

```
vim --version | grep clipboard
```

.vimrc
```
# mac, CentOS
set clipboard=unnamed,autoselect
# ubuntu
set clipboard=unnamedplus
```

```
sudo apt-get install vim-gtk
sudo apt-get install vim-gnome
# vim.gnome
# vim.gtk
```

```
sudo yum install vim-X11.x86_64
alias vim='vimx'
```

※ xselとxclipは参照先が異なる

# 注意事項
* server側がubuntuの場合実際にopenできないDISPLAYを指定してもclipboardは機能する
* CentOSの場合にはopen可能なDISPLAYを指定しないとclipboardは機能しない
* 証明書認証のサーバでないと途中のパスワード入力でつまずくかも...(未検証)
* サーバ上に一時ファイル"~/.tmp.sh"を作成する(sshコマンドでファイルのshell実行とpipeの複数ができればこの一時ファイルは不要)

# client side

file list

* clip-share.sh
* c2s.ch
* s2c.ch

### on server
tmp file list
* ~/.tmp.sh



## client -> server
```
export LC_CODE=$(cat s2c.sh | base64)
./c2s.sh | ssh lab-uma "echo $LC_CODE | base64 -d > .tmp.sh; zsh ./.tmp.sh"
```

## server -> client

```
cat c2s.sh | ssh lab-uma | ./s2c.sh
```


sshでのコマンド実行では該当なし端末上でずっと動作し続けている?
sleepした後に起こされない?

[ssh - Run local script with local input file on remote host - Unix & Linux Stack Exchange]( http://unix.stackexchange.com/questions/313000/run-local-script-with-local-input-file-on-remote-host )

> assuming both your ssh client passes the LC_* variable (SendEnv in ssh_config) and the sshd server accepts them (AcceptEnv in sshd_config))

[Copy to different user clipboard -Xorg linux - Stack Overflow]( http://stackoverflow.com/questions/10690579/copy-to-different-user-clipboard-xorg-linux )
