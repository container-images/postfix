# postfix
{{ spec.short_description }}.

## How to build the container on 25 port

```docker build --tag={{ spec.image_registry }} .```

## How to use the container over standard 25 port

Command for running postfix docker container:

```
docker run -it -e MYHOSTNAME=localhost \
    -p 25:10025\
    -v /var/spool/postfix:/var/spool/postfix \
    -v /var/spool/mail:/var/spool/mail postfix
    -d {{ spec.image_registry }}
```

## How to use the container over standard TLS

Command for running postfix docker container:
```
docker run -it -e ENABLE_TLS -e DEBUG_MODE=yes -e MYHOSTNAME=localhost \
    -p 25:10025 \
    postfix -d {{ spec.image_registry }}
```

Environment variable DEBUG_MODE is used for debugging proposes
from Postfix and dovecot point of views.

## How to use the container with IMAP.

Command for running postfix docker container:
```
docker run -it -e ENABLE_IMAP -e MYHOSTNAME=localhost
    -e DEBUG_MODE \
    -p 587:10587 \
    -v <path_tocertificates>:/etc/postfix/certs \
    postfix -d {{ spec.image_registry }}
```

Environment variable DEBUG_MODE is used for debugging proposes
from Postfix and dovecot point of views.

# How to generate self signed SSL key for {{ spec.envvars.name }}

Let's create a self signed SSL key in cert directory. In order to do it let's create `certs` directory.
First generate a private key for the server

```bash
    openssl genrsa -des3 -out localhost.key 2048
```

The output should be:
```bash
Generating RSA private key, 2048 bit long modulus
..............................................................................................................+++
.........................................................+++
e is 65537 (0x010001)
Enter pass phrase for localhost.key: <- ENTER PASSWORD
Verifying - Enter pass phrase for localhost.key: ENTER PASSWORD

```

Now let's create a certificate request:
```bash
openssl req -new -key localhost.key -out localhost.csr
```

The output should be like:
```bash
openssl req -new -key localhost.key -out localhost.csr
Enter pass phrase for localhost.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []: <- ENTER YOUR DOMAIN           
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []: <- LEAVE EMPTY
An optional company name []:

```

Now let's create a self signed key.
```bash
openssl x509 -req -days 365 -in localhost.csr -signkey localhost.key -out localhost.crt
Signature ok
subject=C = XX, L = Default City, O = Default Company Ltd, CN = localhost
Getting Private key
Enter pass phrase for localhost.key:

```

Let's remove password from private certificate
```bash
openssl rsa -in localhost.key -out localhost.key.nopass
mv localhost.key.nopass localhost.key
```

Make ourself a trusted CA:
```bash
openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650
Generating a 2048 bit RSA private key
....................+++
................................................................................................+++
writing new private key to 'cakey.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:localhost
Email Address []:
```

```bash
chmod 600 localhost.key
chmod 600 cakey.pem
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

## How to test the postfix with IMAP enabled

Command for testing Postfix docker container with
dovecot is ```openssl```.

Telnet has not to be used because of all
communication is encrypted from the beginning.

Testing postfix service with ```openssl```

```
openssl s_client -debug -starttls smtp -crlf -connect localhost:587
```

The result will be similar like this:
```bash
openssl s_client -debug -starttls smtp -crlf -connect localhost:587
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