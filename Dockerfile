FROM {{ config.docker.registry }}/{{ config.docker.from }}

ENV POSTFIX_SMTP_PORT={{ spec.expose }} \
    POSTFIX_TLS_PORT={{ spec.expose_tls }} \
    POSTFIX_IMAP_PORT={{ spec.expose_imap }} \
    NAME={{ spec.envvars.name }} \
    ARCH={{ spec.envvars.arch }} \
    APP_DATA=/opt/app-root
LABEL maintainer {{ spec.maintainer }}
LABEL   summary="{{ spec.short_description }}" \
        name="$FGC/$NAME" \
        version="0" \
        release="1.$DISTTAG" \
        architecture="$ARCH" \
        com.redhat.component="$NAME" \
        usage="docker run -it -e MYHOSTNAME=localhost -p 25:{{ spec.expose }} -v /var/spool/postfix:/var/spool/postfix -v /var/spool/mail:/var/spool/mail {{ spec.envvars.name }}" \
        help="Runs postfix, which listens on port 25. No dependencies. See Help File belowe for more detailes." \
        description="{{ spec.description }}" \
        io.k8s.description="{{ spec.description }}" \
        io.k8s.diplay-name="Postfix 3.1" \
        io.openshift.expose-services="{{ spec.expose }}:{{ spec.envvars.name }}" \
        io.openshift.tags="{{ spec.envvars.name }},mail,mta" \
        io.openshift.s2i.scripts-url="image:///usr/local/s2i"

RUN {{ commands.pkginstaller.install(["findutils", "cyrus-sasl", "cyrus-sasl-plain", "openssl-libs", "postfix"]) }} && \
    {{ commands.pkginstaller.cleancache() }}

ADD files /files
ADD README.md /


COPY ./s2i/bin/ /usr/local/s2i

RUN mkdir -p ${APP_DATA}/src

WORKDIR ${APP_DATA}/src

RUN /files/postfix_config.sh

EXPOSE {{ spec.expose }} {{ spec.expose_tls }} {{ spec.expose_imap }}

# Postfix UID based from Fedora
# USER 89

VOLUME ["/var/spool/postfix"]
VOLUME ["/var/spool/mail"]
VOLUME ["/var/log"]
VOLUME ["/var/mail"]

CMD ["/usr/local/s2i/run"]
