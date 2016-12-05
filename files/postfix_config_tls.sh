#!/usr/bin/env bash

function modify_main_cf() {
    # Configuration changes needed in main.cf
    echo "Changing postfix the /etc/postfix/main.cf configuration file."
    postconf -e inet_interfaces=all
    postconf -e smtpd_use_tls=yes
    postconf -e smtpd_tls_auth_only=no
    postconf -e myorigin=/etc/mailname
    postconf -e mydomain=${MYHOSTNAME}
    postconf -e myhostname="mail.$MYHOSTNAME"
    postconf -e mydestination=${MYHOSTNAME}
    postconf -e smtpd_tls_CAfile=/etc/postfix/cacert.pem
    postconf -e smtpd_tls_key_file=/etc/postfix/test.pem
    postconf -e smtpd_tls_cert_file=/etc/postfix/test.pem
    postconf -e smtpd_tls_loglevel=3
    postconf -e smtpd_tls_received_header=yes
    postconf -e smtpd_tls_session_cache_timeout=3600s
    postconf -e smtpd_tls_security_level=may
    postconf -e tls_random_source=dev:/dev/urandom
    postconf -e smtpd_relay_restrictions='permit_mynetworks permit_tls_clientcerts reject_unauth_destination'
}


if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi

source /files/common_postfix.sh

mkdir -p /var/certs
chown root:root /var/certs

modify_etc_services
modify_main_cf
modify_master_cf
