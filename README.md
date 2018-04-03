# postfix
Postfix is a Mail Transport Agent (MTA).

## How to build the container

Command for building container:

```
make build
```

To change `BASE` image, add the `DISTRO` argument into the build command, like:

```
make build DISTRO=fedora-28-x86_64
```

## How to use the container over standard 25 port

Command for running postfix docker container:

```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025\
    -v /var/spool/postfix:/var/spool/postfix \
    -v /var/spool/mail:/var/spool/mail postfix
    -d docker.io/modularitycontainers/postfix
```

## How to use the container over standard TLS

Command for running postfix docker container:
```
docker run -it -e ENABLE_TLS -e DEBUG_MODE -e MYHOSTNAME=localhost \
    -p 25:10025 \
    postfix -d docker.io/modularitycontainers/postfix
```

Environment variable DEBUG_MODE is used for debugging purposes
from postfix point of view.

## How to use the container with IMAP.

Command for running postfix docker container:
```
POSTFIX_CERTS_PATH=/etc/postfix/certs
docker run -it -e ENABLE_IMAP -e MYHOSTNAME=localhost
    -e DEBUG_MODE \
    -p 587:10587 \
    -v ${POSTFIX_CERTS_PATH}:/etc/postfix/certs \
    postfix -d docker.io/modularitycontainers/postfix
```
POSTFIX_CERTS_PATH contains certificates used by postfix, like self signed certificate, keys, etc.

The example tree generated for localhost certificate can look like:
```bash
$ tree /etc/postfix/certs/
/etc/postfix/certs/
├── localhost.crt
├── localhost.csr
└── localhost.key

```

Environment variable DEBUG_MODE is used for debugging purposes from postfix.

# How to generate self signed SSL certificate for postfix

In case, you enable TLS support for postfix, you need to have certificates for postfix service.

For more information about Postfix TLS support see `http://www.postfix.org/TLS_README.html`

The page [POSTFIX_CERTS_GENERATION.md](/POSTFIX_CERTS_GENERATION.md) will help you with generation self signed certificate used by postfix.

## S2I extensibility
You can configure this container to adhere your needs using [Source-to-Image](https://github.com/openshift/source-to-image) and shell scripts. To create a new Docker image named  `postfix-app`, that will be configured by your needs, just setup this directory: `./app-name/postfix-pre-init` that will contain `*.sh` scripts that will be executed right before postfix will start, so you can use `postconf` and other tools to configure postfix. Then just excute the s2i build:
```
s2i build file://path/to/app-name docker.io/modularitycontainers/postfix postfix-app
```
You can execute such image as you would non-s2i one:
```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025\
    -v /var/spool/postfix:/var/spool/postfix \
    -v /var/spool/mail:/var/spool/mail \
    -d postfix-app
```
In this repo you can find an example for you to try this out. It implements an example of a null client configuration, as described [here](http://www.postfix.org/STANDARD_CONFIGURATION_README.html#null_client). All it does is display the configuration, change it according to example and display it again. Assuming your working directory is this repository, just run:

```
s2i build file://$(pwd)/example docker.io/modularitycontainers/postfix postfix-example
```
And then run it:
```
docker run -it \
    -p 25:10025\
    -v /var/spool/postfix:/var/spool/postfix \
    -v /var/spool/mail:/var/spool/mail \
    -d postfix-example
```
## How to test the postfix mail server

See `help/help.md` file.
