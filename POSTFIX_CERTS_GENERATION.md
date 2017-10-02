# Steps for generation self-signed SSL certificate for postfix
Let's create a self-signed SSL certificate in cert directory.
In order to do it let's create `certs` directory.
The `certs` directory supposes to be in /etc/postfix directory.
First generate a private key and certificate request for the server

```bash
$ openssl req -new -newkey rsa:2048 -nodes -keyout localhost.key -out localhost.csr
```

The output should be:
```bash
Generating a 2048 bit RSA private key
..........................................................................................................+++
.......................................................+++
writing new private key to 'localhost.key'
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
Common Name (eg, your name or your server's hostname) []:
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

```

Now let's sign self-signed certificate
```bash
$ openssl req -x509 -days 365 -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.crt
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


```bash
$ chmod 600 localhost.key
$ chmod 600 cakey.pem
```