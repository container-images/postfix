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

LABEL summary="Postfix is a Mail Transport Agent (MTA)." \
    version="1.0" \
    description="Postfix is mail transfer agent that routes and delivers mail." \
    io.k8s.description="Postfix is mail transfer agent that routes and delivers mail." \
    io.k8s.diplay-name="Postfix 3.1" \
    io.openshift.expose-services="10025:postfix" \
    io.openshift.tags="postfix,mail,mta"

MAINTAINER "Petr Hracek" <phracek@redhat.com>

ENV POSTFIX_SMTP_PORT=10025

ADD files /files

RUN /files/postfix_config.sh

EXPOSE 10025
EXPOSE 10587
EXPOSE 10465

# Postfix UID based from Fedora
# USER 89

VOLUME ['/var/spool/postfix']
VOLUME ['/var/spool/mail']

CMD ["/files/start.sh"]
