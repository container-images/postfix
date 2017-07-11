FROM modularitycontainers/boltron-preview:latest

ENV POSTFIX_SMTP_PORT=10025  NAME=postfix ARCH=x86_64
LABEL MAINTAINER "Petr Hracek" <phracek@redhat.com>
LABEL   summary="Postfix is a Mail Transport Agent (MTA)." \
        name="$FGC/$NAME" \
        version="0" \
        release="1.$DISTTAG" \
        architecture="$ARCH" \
        com.redhat.component="$NAME" \
        usage="docker run -it -e MYHOSTNAME=localhost -p 25:10025 -v $(pwd)/tmp/postfix:/var/spool/postfix -v $(pwd)/tmp/mail:/var/spool/mail postfix" \
        help="Runs postfix, which listens on port 25. No dependencies. See Help File belowe for more detailes." \
        description="Postfix is mail transfer agent that routes and delivers mail." \
        io.k8s.description="Postfix is mail transfer agent that routes and delivers mail." \
        io.k8s.diplay-name="Postfix 3.1" \
        io.openshift.expose-services="10025:postfix" \
        io.openshift.tags="postfix,mail,mta"

RUN dnf install -y --rpm --nodocs findutils && \
    dnf install -y --nodocs postfix && \
    dnf -y clean all

ADD files /files
ADD README.md /

RUN /files/postfix_config.sh

EXPOSE 10025

# Postfix UID based from Fedora
# USER 89

VOLUME ['/var/spool/postfix']
VOLUME ['/var/spool/mail']

CMD ["/files/start.sh"]
