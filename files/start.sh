#!/bin/bash

if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi
postconf -e inet_interfaces=all
postconf -e mydomain=${MYHOSTNAME}
postconf -e myhostname=mail.${MYHOSTNAME}
postconf -e myorigin=/etc/mailname
postconf -e mynetworks='127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
postconf -e smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination'
postconf -e mydestination=${MYHOSTNAME}

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
