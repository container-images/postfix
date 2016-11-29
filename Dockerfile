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

ENV POSTFIX_SMTP_PORT=10025 POSTFIX_SSL_PORT=10587 POSTFIX_SMTPS_PORT=10465

ADD files /files

RUN /files/postfix_config.sh

EXPOSE 10025
EXPOSE 10587
EXPOSE 10465

# In order to drop the root user, we have to make some directories
# world writable as OpenShift default security model is to run the container
# under random UID
RUN chmod -R a+rwx /var/spool/mail && \
    chmod -R a+rwx /var/spool/postfix && \
    chmod -R a+rwx /var/log && \
    chown -R 89:0 /var/spool && \
    chown -R 89:0 /var/log && \
    chmod -R 755 /etc/postfix && \
    chmod 644 /etc/postfix/*.cf

# Postfix UID based from Fedora
# USER 89

VOLUME ['/var/spool/postfix']
VOLUME ['/var/spool/mail']
VOLUME ['/var/log']

CMD ["/files/start.sh"]
