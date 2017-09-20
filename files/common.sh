#!/usr/bin/env bash

SERVICES="/etc/services"
MASTER="/etc/postfix/master.cf"

function modify_master_cf(){
    echo "Changing postfix $MASTER configuration file."
    MASTER="/etc/postfix/master.cf"
    grep 'docker_smtp' "$MASTER"
    if [[ $? -eq 1 ]]; then
        sed -i 's/^smtp\(\s*\)inet\(.*\)/docker_smtp\1inet\tn\ty\tn\t-\t-\tsmtpd -v/g' "$MASTER"
    fi
}

function modify_main_cf_tls() {
    # Configuration changes needed in main.cf
    if [[ -n "$(find /etc/postfix/certs -iname *.crt)" && -n "$(find /etc/postfix/certs -iname *.key)" ]]; then
        echo "Changing postfix the /etc/postfix/main.cf configuration file for using TLS."
        postconf -e inet_interfaces=all
        postconf -e smtpd_use_tls=yes
        postconf -e smtpd_tls_auth_only=no
        postconf -e myorigin=/etc/mailname
        postconf -e mydomain=${MYHOSTNAME}
        postconf -e myhostname="mail.$MYHOSTNAME"
        postconf -e mydestination=${MYHOSTNAME}
        postconf -e smtpd_tls_CAfile=$(find /etc/postfix/certs -iname cacert.pem)
        postconf -e smtpd_tls_key_file=$(find /etc/postfix/certs -iname *.key)
        postconf -e smtpd_tls_cert_file=$(find /etc/postfix/certs -iname *.crt)
        postconf -e smtpd_tls_loglevel=3
        postconf -e smtpd_tls_received_header=yes
        postconf -e smtpd_tls_session_cache_timeout=3600s
        postconf -e smtpd_tls_security_level=may
        postconf -e tls_random_source=dev:/dev/urandom
        postconf -e smtpd_sasl_auth_enable=yes
        postconf -e broken_sasl_auth_clients=yes
        postconf -e smtpd_relay_restrictions='permit_mynetworks,permit_tls_clientcerts,reject_unauth_destination'
        postconf -e smtpd_recipient_restrictions='permit_sasl_authenticated,reject_unauth_destination'
    fi
}


function modify_main_cf_imap() {
    if [[ -n "$(find /etc/postfix/certs -iname *.crt)" && -n "$(find /etc/postfix/certs -iname *.key)" ]]; then
        # Configuration changes needed in main.cf
        echo "Changing postfix the /etc/postfix/main.cf configuration file for using IMAP."
        postconf -e inet_interfaces=all
        postconf -e smtpd_tls_auth_only=yes
        postconf -e smtpd_tls_CAfile=$(find /etc/postfix/certs -iname cacert.pem)
        postconf -e smtpd_tls_key_file=$(find /etc/postfix/certs -iname *.key)
        postconf -e smtpd_tls_cert_file=$(find /etc/postfix/certs -iname *.crt)
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

function modify_etc_services() {
    SERVICES="/etc/services"
    echo "Changing $SERVICES file."
    grep -n '$POSTFIX_SMTP_PORT/tcp' "$SERVICES"
    if [[ $? -eq 1 ]]; then
        echo "Add docker_smtp port into $SERVICES."
        echo "docker_smtp   $POSTFIX_SMTP_PORT/tcp  mail" >> "$SERVICES"
        echo "docker_smtp   $POSTFIX_SMTP_PORT/udp  mail" >> "$SERVICES"
    else
        echo "docker_smtp port already exists in $SERVICES file."
    fi
    grep -n '$POSTFIX_IMAP_PORT/tcp' "$SERVICES"
    if [[ $? -eq 1 ]]; then
        echo "Add docker_imap port into $SERVICES."
        echo "docker_imap   $POSTFIX_IMAP_PORT/tcp  imap2" >> "$SERVICES"
        echo "docker_imap   $POSTFIX_IMAP_PORT/udp  imap2" >> "$SERVICES"
    else
        echo "docker_imap port already exists in $SERVICES file."
    fi
    grep -n '$POSTFIX_SUBM_PORT/tcp' "$SERVICES"
    if [[ $? -eq 1 ]]; then
        echo "Add docker_imap port into $SERVICES."
        echo "docker_submission   $POSTFIX_SUBM_PORT/tcp  msa" >> "$SERVICES"
        echo "docker_submission   $POSTFIX_SUBM_PORT/udp  msa" >> "$SERVICES"
    else
        echo "docker_submission port already exists in $SERVICES file."
    fi
}

function user_generation() {
    echo "user_generation"
    echo $SMTP_USER | tr , \\n > /tmp/passwd
    while IFS=':' read -r _user _pwd; do
        echo $_pwd | saslpasswd2 -p -c -u ${MYHOSTNAME} $_user
    done < /tmp/passwd
    chown postfix.sasl /etc/sasldb2
}