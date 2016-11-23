# postfix

Postfix mail server container.


## How to build the container

```docker build --tag=postfix .```

## How to use the container

Command for running postfix docker container:
```
docker run -it -p 25:25 -p 587:587 \
    -v $(pwd)/tmp/postfix:/var/spool/postfix \
    -v $(pwd)/tmp/mail:/var/spool/mail \
    -v $(pwd)/tmp/log:/var/log/postfix postfix
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
