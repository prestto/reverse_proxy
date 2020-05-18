# Niginx Docker Test

## Intro

A small project to demonstrate running 2 containers with web servers using an nginx container.

## Creating a SSL Certificate

To avoid buying an SSL certificate, we create a certificate authority, which must be trusted by the user's browser.

### Creating the CA

This section is for posterity and does not need to be repeated.

https://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

For the certificate authority:

```bash
# Create the root key
openssl genrsa -out certs/rootCA.key 2048

# self sign the certificate
openssl req -x509 -new -nodes -key certs/rootCA.key -sha256 -days 1024 -out certs/rootCA.pem

# We now have a self signed root certificate and can act as a Certificate authority
# certs/rootCA.pem
```

### Self signing a certificate

For the server:

```bash
# create a certificate for the device
openssl genrsa -out certs/device.key 2048

# create the certificate signing request
# Common name = "dali.dev.local"
openssl req -new -key certs/device.key -out certs/device.csr

# sign the cert
# note the importance of -extfile:
# https://stackoverflow.com/questions/43665243/invalid-self-signed-ssl-cert-subject-alternative-name-missing
openssl x509 -req -in certs/device.csr -CA certs/rootCA.pem -CAkey certs/rootCA.key -CAcreateserial -out certs/device.crt -days 500 -sha256 -extfile projnginx/snippets/v3.ext

# use the certificate:
# certs/device.crt
cp certs/device.crt projnginx/certs/server.crt
cp certs/device.key projnginx/private/server.key
```

### Setup on the end user machine

We need to trust the CA on the end user machine.  This can be done by adding the CA to the list of trusted CAs in the browser.

A guide can be found [here](https://support.google.com/chrome/a/answer/6342302?hl=en)
