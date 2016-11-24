FROM fedora:24

# Postfix image for OpenShift.
#
# Volumes:
#  * /var/spool/postfix -
#  * /var/spool/mail -
#  * /var/log/postfix - Postfix log directory
# Environment:
#  * $MYHOSTNAME - Hostname for Postfix image
# Additional packages
#  * findutils are needed in case fedora:24 is loaded from docker.io.

RUN dnf install -y --setopt=tsflags=nodocs postfix findutils && \
    dnf -y clean all

MAINTAINER "Petr Hracek" <phracek@redhat.com>

ADD files /files

EXPOSE 25 587

VOLUME ['/var/spool/postfix', '/var/spool/mail', '/var/log']

CMD ["/files/start.sh"]
