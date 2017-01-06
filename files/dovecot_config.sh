#!/usr/bin/env bash

DOVECOT_CONF="/etc/dovecot/dovecot.conf"
VIRTUAL="/var/mail"

function modify_main_cf() {
    # Configuration changes needed in main.cf
    echo "Changing postfix the /etc/postfix/main.cf configuration file."
    postconf -e inet_interfaces=all
    postconf -e smtpd_tls_auth_only=yes
    postconf -e smtpd_tls_CAfile=/etc/postfix/ca-bundle.crt
    postconf -e smtpd_tls_key_file=/etc/postfix/test.pem
    postconf -e smtpd_tls_cert_file=/etc/postfix/test.pem
    postconf -e smtpd_tls_loglevel=3
    postconf -e smtpd_tls_received_header=yes
    postconf -e smtpd_tls_session_cache_timeout=3600s
    postconf -e smtpd_tls_security_level=may
    postconf -e smtpd_sasl_type=dovecot
    postconf -e smtpd_sasl_path=private/auth
    postconf -e smtpd_sasl_auth_enable=yes
    postconf -e broken_sasl_auth_clients=yes
    postconf -e smtpd_sasl_security_options=noanonymous
    postconf -e myorigin=${MYHOSTNAME}
    postconf -e mydomain=${MYHOSTNAME}
    postconf -e myhostname=mail.${MYHOSTNAME}
    postconf -e mydestination=${MYHOSTNAME}
    postconf -e debug_peer_level=3
    postconf -e debug_peer_list=${MYHOSTNAME}
}

if [[ -f "/var/run/nologin" ]]; then
    rm -f /var/run/nologin
fi

if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi

source /files/common.sh

mkdir -p /var/certs
chown root:root /var/certs
cp /files/*.{crt,pem} /etc/postfix/


modify_etc_services
modify_main_cf
modify_master_cf