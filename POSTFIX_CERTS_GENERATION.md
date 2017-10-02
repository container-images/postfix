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

Then sign the certificate signing request with the private key localhost.key:
```
openssl x509 -req -days 365 -in localhost.csr -signkey localhost.key -out localhost.crt
```
Instead of your own private key `localhost.key`,
you can sign your certificate by some certificate authority.