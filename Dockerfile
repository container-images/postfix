FROM fedora:24

# Postfix image for OpenShift.
#
# Volumes:
#  * /var/spool/postfix -
#  * /var/spool/mail -
#  * /var/log/postfix - Postfix log directory
# Environment:
#  * $MYHOSTNAME - Hostname for Postfix image


MAINTAINER "Petr Hracek" <phracek@redhat.com>

ADD files /files

EXPOSE 25 587

VOLUME ['/var/spool/postfix', '/var/spool/mail', '/var/log']

CMD ["/files/start.sh"]
