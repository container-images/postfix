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

function modify_dovecot_conf() {
    update_dovecot_conf "mail_location" "mbox:~/mail:INBOX=/var/mail/%u"
    update_dovecot_conf "disable_plaintext_auth" "no"
    update_dovecot_conf "auth_mechanisms" "plain login"
    update_dovecot_conf "mail_privileged_group" "mail"
    update_dovecot_conf "auth_debug" "yes"
    update_dovecot_conf "auth_verbose" "yes"
    update_dovecot_conf "mail_debug" "yes"
    update_dovecot_conf "debug_log_path" "/var/dovecot/dovecot-debug.log"
    update_dovecot_conf "info_log_path" "/var/dovecot/dovecot-info.log"
    update_dovecot_conf "log_path" "/var/dovecot/dovecot.log"
    update_dovecot_conf "protocols" "imap"

    doveconf -n | grep "ssl"
    if [[ $? -eq 1 ]]; then
        echo "ssl = yes" >> /etc/dovecot/conf.d/10-ssl.conf
    else
        sed -i 's/^ssl\(\s*\)=\(\s*\).*/ssl\1=\2yes/g' /etc/dovecot/conf.d/10-ssl.conf
    fi
    doveconf -n | grep "service imap-login"
    if [[ $? -eq 1 ]]; then
        cat /files/dovecot_imap.conf >> /etc/dovecot/conf.d/10-master.conf
    fi
    echo "docker_submission inet n       y       n       -       -       smtpd -v
      -o syslog_name=postfix/submission
      -o smtpd_tls_security_level=encrypt
      -o smtpd_sasl_auth_enable=yes
      -o smtpd_tls_wrappermode=no
      -o smtpd_sasl_type=dovecot
      -o smtpd_sasl_path=private/auth
      -o smtpd_sasl_local_domain=localhost" >> /etc/postfix/master.cf

}

if [[ -f "/var/run/nologin" ]]; then
    rm -f /var/run/nologin
fi

DOVECOT_PKI="/etc/pki/dovecot"
if [[ ! -f "$DOVECOT_PKI/private/dovecot.pem" ]]; then
    SSLDIR=$DOVECOT_PKI OPENSSLCONFIG="$DOVECOT_PKI/dovecot-openssl.cnf" \
    /usr/libexec/dovecot/mkcert.sh /dev/null 2>&1
fi
if [[ ! -f "/var/lib/dovecot/ssl-parametrs.dat" ]]; then
    /usr/libexec/dovecot/ssl-params >/dev/null 2>&1
fi

if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi

source /files/common.sh

mkdir -p /var/certs
chown root:root /var/certs
mkdir -p /var/dovecot
chown root:root /var/dovecot
cp /files/*.{crt,pem} /etc/postfix/


modify_etc_services
modify_main_cf
modify_master_cf
modify_dovecot_conf

dovecot -n
