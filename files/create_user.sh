#!/usr/bin/env bash

grep $1 /etc/passwd
if [[ $? -ne 0 ]]; then
    useradd $1 && usermod -a -G mail $1 && passwd $1
    echo "$1:     postmaster" >> /etc/aliases
    newaliases
    postmap /etc/aliases
    postfix reload
fi
