#!/bin/bash

# Copy all certificates
#cp /var/certs/*.{crt,pem} /etc/postfix/
# Wait before postfix is really started.

if [[ ! -z "${DEBUG_MODE}" ]]; then
    rpm -q syslog-ng
    if [[ $? -ne 0 ]]; then
        dnf -y --setopt=tsflags=nodocs install syslog-ng && \
        dnf -y clean all
        syslog-ng
    fi
fi

postfix start

while true; do
    state=$(script -c 'postfix status' | grep postfix/postfix-script)
    if [[ "$state" != "${state/is running/}" ]]; then
        PID=${state//[^0-9]/}
        if [[ -z $PID ]]; then
            continue
        fi
        if [[ ! -d "/proc/$PID" ]]; then
            echo "Postfix proces $PID does not exist."
            break
        fi
        sleep 10
    else
        echo "Postfix is not running."
        break
    fi
done
