#!/usr/bin/env bash


modify_main_cf() {
    # Configuration changes needed in main.cf
    echo "Changing postfix configuration"
    postconf -e inet_interfaces=all
    postconf -e mydomain=${MYHOSTNAME}
    postconf -e myhostname=mail.${MYHOSTNAME}
    postconf -e myorigin=/etc/mailname
    postconf -e mynetworks='127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
    postconf -e smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination'
    postconf -e mydestination=${MYHOSTNAME}
}

modify_master_cf(){
    echo "Changing postfix $MASTER configuration file."
    MASTER="/etc/postfix/master.cf"
    grep 'docker_smtp' "$MASTER"
    if [[ $? -eq 1 ]]; then
        sed -i 's/^smtp\(\s*\)inet\(.*\)/docker_smtp\1inet  n\ty\tn\t-\t-\tsmtpd/g' "$MASTER"
    fi
}

modify_etc_services() {
    SERVICES="/etc/services"
    echo "Changing $SERVICES file."
    grep -n ' $POSTFIX_SMTP_PORT/tcp' "$SERVICES"
    if [[ $? -eq 1 ]]; then
        echo "Add docker_smtp port into $SERVICES."
        echo "docker_smtp   $POSTFIX_SMTP_PORT/tcp  mail" >> "$SERVICES"
        echo "docker_smtp   $POSTFIX_SMTP_PORT/udp  mail" >> "$SERVICES"
    else
        echo "docker_smtp port already exists in $SERVICES file."
    fi
}


if [[ -z ${MYHOSTNAME} ]]; then
    MYHOSTNAME=localhost
fi

modify_etc_services
modify_main_cf
modify_master_cf

echo "Reloading postfix configuration..."
postfix reload
echo "Reloading postfix configuration done."
mkdir -p /var/log
