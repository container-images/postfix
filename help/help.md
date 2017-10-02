% POSTFIX(1) Container Image Pages
% Petr Hracek
% September 19, 2017

# NAME
{{ spec.envvars.name }} - {{ spec.short_description }}

# DESCRIPTION
{{ spec.description }}

# USAGE
To get the {{ spec.envvars.name }} container image on your local system, run the following:

    docker pull hub.docker.io/modularitycontainers/{{ spec.envvars.name }}

Commands for testing {{ spec.envvars.name }} docker container:

```$ telnet localhost 25```

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

## How to test the {{ spec.envvars.name }} mail server with TLS

Command for testing {{ spec.envvars.name }} docker container with
enabled TLS is ```openssl```.

Telnet can not be used because of communication is encrypted.

```
$ openssl s_client -starttls smtp -crlf -connect localhost:25
```

## How to test the {{ spec.envvars.name }} with IMAP enabled

Command for testing {{ spec.envvars.name }} docker container
dovecot is ```openssl```.

Telnet can not be used because of communication is encrypted.

Testing {{ spec.envvars.name }} service with ```openssl```

```
$ openssl s_client -debug -starttls smtp -crlf -connect localhost:587
```

The result will be similar like this:
```bash
$ openssl s_client -debug -starttls smtp -crlf -connect localhost:587
CONNECTED(00000003)
read from 0x20e33e0 [0x20fee80] (4096 bytes => 0 (0x0))
write to 0x20e33e0 [0x20ffe90] (23 bytes => 23 (0x17))
0000 - 45 48 4c 4f 20 6d 61 69-6c 2e 65 78 61 6d 70 6c   EHLO mail.exampl
0010 - 65 2e 63 6f 6d 0d 0a                              e.com..
read from 0x20e33e0 [0x20fee80] (4096 bytes => 0 (0x0))
didn't find starttls in server response, trying anyway...
write to 0x20e33e0 [0x7ffe9cad7fb0] (10 bytes => -1 (0xFFFFFFFFFFFFFFFF))
read from 0x20e33e0 [0x2022d80] (8192 bytes => 0 (0x0))
write to 0x20e33e0 [0x210d600] (254 bytes => -1 (0xFFFFFFFFFFFFFFFF))
write:errno=32
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 23 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : 0000
    Session-ID: 
    Session-ID-ctx: 
    Master-Key: 
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1505908275
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
---

```
  
# ENVIRONMENT VARIABLES

The image recognizes the following environment variables that you can set
during initialization be passing `-e VAR=VALUE` to the Docker run command.

|    Variable name         |      Description                              |
| :----------------------- | --------------------------------------------- |
|  `POSTFIX_DEBUG_MODE`    | Turn on debug mode                            |  
|  `ENABLE_TLS`            | Enables TLS used in postfix                   |
|  `ENABLE_IMAP`           | Enables IMAP for using together with dovecot  |

        
# SECURITY IMPLICATIONS
Lists of security-related attributes that are opened to the host.

-p 25:10025
    Opens container port 10025 and maps it to the port 25 on the host. The port is used by SMTP protocol for outgoing mail usage.

-p 143:10143
    Opens container port 10143 and maps it to the port 143 on the host. The port is used by IMAP incomming mail. For plain text/encrypted session

-p 587:10587
    Opens container port 10587 and maps it to the port 587 on the host. The port is used by submission protocol for outgoing mail.

# SEE ALSO
Postfix page
<https://postfix.org/>
