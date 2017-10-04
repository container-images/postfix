#!/bin/bash

# Wait before postfix is really started.

source /files/common.sh

function get_state {
    echo $(script -c 'postfix status' | grep postfix/postfix-script)
}

if [[ -z "${ENABLE_TLS}" ]]; then
    modify_main_cf_tls
fi

if [[ -z "${ENABLE_IMAP}" ]]; then
    modify_main_cf_imap
fi

if [[ ! -z "${DEBUG_MODE}" ]]; then
    rpm -q syslog-ng
    if [[ $? -ne 0 ]]; then
        dnf -y --setopt=tsflags=nodocs install syslog-ng && \
        dnf -y clean all
        syslog-ng
    fi
fi
postfix start
echo $(get_state)

while true; do
    state=$(get_state)
    if [[ "$state" != "${state/is running/}" ]]; then
        PID=${state//[^0-9]/}
        if [[ -z $PID ]]; then
            continue
        fi
        if [[ ! -d "/proc/$PID" ]]; then
            echo "Postfix proces $PID does not exist."
            break
        fi
    else
        echo "Postfix is not running."
        break
    fi
done


