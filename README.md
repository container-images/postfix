# postfix
Postfix mail server container.


## How to build the container

```docker build --tag=postfix .```

## How to use the container over standard 25 port

Command for running postfix docker container:
```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025\
    -v $(pwd)/tmp/postfix:/var/spool/postfix \
    -v $(pwd)/tmp/mail:/var/spool/mail postfix
```

## How to use the container over standard TLS

Docker file for TLS port is Dockerfile.TLS.

Before you run postfix container store certificates needed for Postfix
container into proper directory. In this case ```$(pwd)/certs```.
Command for running postfix docker container:
```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025 \
    -v $(pwd)/certs:/var/certs
    postfix
```

## How to test the postfix mail server

Commands for testing Postfix docker container:

```telnet localhost 25```

```HELO test.localhost```

```MAIL FROM:<yourname>@<domain.com>```

```RCPT TO:<demo@localhost>```

```DATA``` and type whatever you want
```
Subject: My testing docker container image

Hi, Testing message
regards
Docker
.
```

## How to test the postfix mail server with TLS

Command for testing Postfix docker container with
enabled TLS is ```openssl```.

Telnet has not to be used because of all
communication is encrypted from the beginning.

```
openssl s_client -starttls smtp -crlf -connect localhost:25
```