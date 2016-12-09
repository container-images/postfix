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

update_dovecot_conf() {
    option=$1
    value=$2
    file_name="/etc/dovecot/dovecot.conf"
    doveconf -n | grep "^$option"
    if [[ $? -eq 1 ]]; then
        echo "$option = $value" >> $file_name
    fi
}

