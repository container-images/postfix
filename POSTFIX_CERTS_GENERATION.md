# Steps for generation self signed SSL key for postfix
Let's create a self signed SSL key in cert directory.
In order to do it let's create `certs` directory.
First generate a private key for the server

```bash
$ openssl genrsa -des3 -out localhost.key 2048
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
$ openssl req -new -key localhost.key -out localhost.csr
```

The output should be like:
```bash
$ openssl req -new -key localhost.key -out localhost.csr
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
$ openssl x509 -req -days 365 -in localhost.csr -signkey localhost.key -out localhost.crt
Signature ok
subject=C = XX, L = Default City, O = Default Company Ltd, CN = localhost
Getting Private key
Enter pass phrase for localhost.key:

```

Let's remove password from private certificate.
We do this, so we don't have to enter a password when you restart postfix.
```bash
$ openssl rsa -in localhost.key -out localhost.key.nopass
$ mv localhost.key.nopass localhost.key
```

Make ourself a trusted CA. This is simplest option.
You will get a warning message about an untrusted certificate.
It can be used for private mail server.
It is quickly created and without price, like no costs.

```bash
$ openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650
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
$ chmod 600 localhost.key
$ chmod 600 cakey.pem
```