# clip share command

for clipboard sharing between local and remote environment

## how to use
1. install at local environment
1. `clip-share.sh <host name at ssh config>`

__Threre is no need to install tools at remote environment.__

* `local host`: `windows(MSYS,WSL)`, `Mac OS X`, `Ubuntu`
* `remote host`: `Mac OS X`, `Ubuntu`

## environment variable
* `CLIPSHARE_SSH_RETRY_INTERVAL`: default value is `3[sec]`
* `CLIPSHARE_DROP_WINDOWS_CR`: default value is `1(enable)`

## Sequence Diagram

``` mermaid
sequenceDiagram
    participant local
    participant remote

    loop monitoring clipboard with ssh
        opt if local local clipboard has changed
            local->>remote: send clipboard via ssh tunnel
            Note right of remote: base64 format
            remote ->> remote: update clipboard
        end
        opt if remote clipboard has changed
            remote ->> local: send clipboard via ssh tunnel
            Note left of local: base64 format
            local ->> local: update clipboard
        end

        Note left of local: break by ctrl-c
    end
```

## FYI
`wait loop (local) <-- ssh pipe --> pipe wait loop (remote) | clipboard wait loop (remote) <-- ssh pipe --> pipe loop (local)`

### ubuntu clipboard bug
* [Clipboard error : Target STRING not available when running · Issue \#2642 · neovim/neovim · GitHub]( https://github.com/neovim/neovim/issues/2642 )
* [Error : target STRING not available · Issue \#38 · astrand/xclip · GitHub]( https://github.com/astrand/xclip/issues/38 )
* [ClipboardPersistence \- Ubuntu Wiki]( https://wiki.ubuntu.com/ClipboardPersistence )

## FMI
* [ssh - Run local script with local input file on remote host - Unix & Linux Stack Exchange]( http://unix.stackexchange.com/questions/313000/run-local-script-with-local-input-file-on-remote-host )

> assuming both your ssh client passes the LC_* variable (SendEnv in ssh_config) and the sshd server accepts them (AcceptEnv in sshd_config))

* [Copy to different user clipboard -Xorg linux - Stack Overflow]( http://stackoverflow.com/questions/10690579/copy-to-different-user-clipboard-xorg-linux )
