# postfix
Postfix mail server container.


## How to build the container on 25 port

```docker build --tag=postfix .```


## How to build the container with TLS enabled

```docker build -f Docker.TLS --tag=postfix . ```

## How to build the container with dovecot service

```docker build -f Docker.IMAP --tag=postfix .```

## How to use the container over standard 25 port

Command for running postfix docker container:

```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025\
    -v $(pwd)/tmp/postfix:/var/spool/postfix \
    -v $(pwd)/tmp/mail:/var/spool/mail postfix
```

## How to use the container over standard TLS

Dockerfile for TLS port is Dockerfile.TLS.

Command for running postfix docker container:
```
docker run -it -e DEBUG_MODE=yes -e MYHOSTNAME=localhost \
    -p 25:10025 \
    postfix
```

Environment variable DEBUG_MODE is used for debugging proposes
from Postfix and dovecot point of views.

## How to use the container with IMAP with TLS enabled (dovecot and Postfix)

Dockerfile which uses IMAP is Dockerfile.IMAP.

Command for running postfix docker container:
```
docker run -it -e MYHOSTNAME=localhost -e DEBUG_MODE \
    -p 25:10025 -p 587:10587 -p 143:10143 \
    postfix
```

Environment variable DEBUG_MODE is used for debugging proposes
from Postfix and dovecot point of views.

Docker container does NOT share user from HOST system. Therefore
I prefer to create users in container. This is not yet automated. Will be SOON.

Steps are:

```docker exec -n postfix /bin/bash```
```/file/create_user.sh <user_name>```

Now the user can be used for mail clients.

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

## How to test the postfix with dovecot service

Command for testing Postfix docker container with
dovecot is ```openssl```.

Telnet has not to be used because of all
communication is encrypted from the beginning.

Testing dovecot service with ```openssl```

```
openssl s_client -starttls imap -connect localhost:143
```

Testing postfix service with ```openssl```

```
openssl s_client -debug -starttls smtp -crlf -connect localhost:25
```