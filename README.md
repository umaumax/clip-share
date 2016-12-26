# clip share command

クライアント/サーバ間のクリップボード共有コマンド

required

client : X11, ssh config
server : zsh, xclip or xsel

## installation
```
brew tap umaumax/clip-share
brew install clip-share
```

## preparation

### client

Mac : X11

e.g.
```
brew cask install xquartz
```

その後iTermの再起動でDISPLAYが設定される
もしくはxTermから接続する

add below setting to "~/.ssh.config"
```
ForwardX11 yes
ForwardX11Trusted yes
```

### server

in Ubuntu

maybe need
```
export DISPLAY=':0'
```

#### clipboard command
```
# Ubuntu
sudo apt-get install xclip
```

※ xselとxclipは参照先が異なる

#### vim (if you want to use)

+clipboardの存在を確認

```
vim --version | grep clipboard
```

~/.vimrc
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

# memo
* server側がubuntuの場合実際にopenできないDISPLAYを指定してもclipboardは機能する
* CentOSの場合にはopen可能なDISPLAYを指定しないとclipboardは機能しない
* 証明書認証のサーバでないと途中のパスワード入力でつまずくかも...(未検証)
* サーバ上に一時ファイル"~/.clipboard.tmp.sh"を作成する(sshコマンドでファイルのshell実行とpipeの複数ができればこの一時ファイルは不要)

## NOTE
クリップボードに
```
var hoge = "\n";
```
としたとき、OS-shellの組み合わせで変数展開が異なる(bashに統一すると挙動が安定する)

## References
[ssh - Run local script with local input file on remote host - Unix & Linux Stack Exchange]( http://unix.stackexchange.com/questions/313000/run-local-script-with-local-input-file-on-remote-host )

> assuming both your ssh client passes the LC_* variable (SendEnv in ssh_config) and the sshd server accepts them (AcceptEnv in sshd_config))

[Copy to different user clipboard -Xorg linux - Stack Overflow]( http://stackoverflow.com/questions/10690579/copy-to-different-user-clipboard-xorg-linux )
