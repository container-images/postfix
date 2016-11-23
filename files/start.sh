#!/bin/bash

postconf -e inet_interfaces=all
postconf -e mynetworks='127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
postconf -e smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination'

mkdir -p /var/log/

/usr/sbin/postfix start

while true; do
    state=$(script -c 'postfix status' | grep postfix/postfix-script)
    if [[ "$state" != "${state/running/}" ]]; then
        PID=${state//[^0-9]/}
        if [[ -z $PID ]]; then
            continue
        fi
        if [[ ! -d "/proc/$PID" ]]; then
            break
        fi
    else
        break
    fi
done
