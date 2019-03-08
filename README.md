# clip share command

for clipboard sharing between local and remote environment

## how to use
1. install at local environment
1. `clip-share.sh <host name at ssh config>`

__Threre is no need to install tools at remote environment.__

## Sequence Diagram

```plantuml
@startuml

title clip-share

participant "local" as Local
participant "remote" as Remote

== ssh ==

loop monitoring clipboard
    opt if local local clipboard has changed
        activate Local
        Local -> Remote: send clipboard via ssh tunnel
        note right #lightgreen: base64\nformat
        Remote -> Remote: update clipboard
    end

    opt if remote clipboard has changed
        activate Remote
        Remote -> Local: send clipboard via ssh tunnel
        note left #lightgreen: base64\nformat
        Local -> Local: update clipboard
    end

    break ctrl-c
    end
end

@enduml
```

## FYI
`wait loop (local) <-- ssh pipe --> pipe wait loop (remote) | clipboard wait loop (remote) <-- ssh pipe --> pipe loop (local)`

## FMI
[ssh - Run local script with local input file on remote host - Unix & Linux Stack Exchange]( http://unix.stackexchange.com/questions/313000/run-local-script-with-local-input-file-on-remote-host )

> assuming both your ssh client passes the LC_* variable (SendEnv in ssh_config) and the sshd server accepts them (AcceptEnv in sshd_config))

[Copy to different user clipboard -Xorg linux - Stack Overflow]( http://stackoverflow.com/questions/10690579/copy-to-different-user-clipboard-xorg-linux )
