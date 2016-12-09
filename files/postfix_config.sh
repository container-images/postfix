#!/usr/bin/env bash


function modify_main_cf() {
    # Configuration changes needed in main.cf
    echo "Changing postfix configuration"
    postconf -e inet_interfaces=all
    postconf -e myorigin=/etc/mailname
    postconf -e mynetworks='127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
    postconf -e smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination'
    postconf -e mydomain=${MYHOSTNAME}
    postconf -e myhostname=mail.${MYHOSTNAME}
    postconf -e mydestination=${MYHOSTNAME}
}



if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi

source /files/common_postfix.sh

modify_etc_services
modify_main_cf
modify_master_cf

