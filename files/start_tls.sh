#!/bin/bash

# Copy all certificates
#cp /var/certs/*.{crt,pem} /etc/postfix/

# Wait before postfix is really started.
postfix start

while true; do
    state=$(script -c 'postfix status' | grep postfix/postfix-script)
    echo $state
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
