FROM fedora:24

MAINTAINER "Petr Hracek" <phracek@redhat.com>

ADD files /files

EXPOSE 25 587

VOLUME ['/var/spool/postfix', '/var/spool/mail', '/var/log']

CMD ["/files/start.sh"]
