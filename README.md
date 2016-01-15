Let's Encrypt renewal for Lighttpd
==================================

This script automatize the renewal process for certificates issued by Let's Encrypt.


# Setup Let's Encrypt on Lighttpd (for the first time)

Long story short, run as root:

```bash
letsencrypt certonly --manual
```

Follow the steps required for every domain (and subdomain) and then for every domain do:

```bash
cd /etc/letsencrypt/live/yourdomain
cat privkey.pem cert.pem > ssl.pem
```

My lighttpd configuration follows the following convention:

> put every certificate in /etc/lighttpd using the domainname.pem syntax to distinguish them

Every virtual hosts have its own folder in my home.

Therefore, for every virtual host (and for every certificate) my lighttpd.conf looks like

```conf
    $SERVER["socket"] == ":443" {
        ssl.engine = "enable"
        ssl.ca-file = "/etc/lighttpd/fullchain.pem"
        ssl.pemfile = "/etc/lighttpd/www.nerdz.eu.pem"
		ssl.dh-file = "/etc/lighttpd/dhparams.pem"
        #
        # Mitigate BEAST attack:
        #
        # A stricter base cipher suite. For details see:
        # http://blog.ivanristic.com/2011/10/mitigating-the-beast-attack-on-tls.html
        #
        ssl.cipher-list = "ECDHE-RSA-CHACHA20-POLY1305 ECDHE-ECDSA-CHACHA20-POLY1305 AES128+EECDH:AES128+EDH:!aNULL:!eNULL"
        #
        # Make the server prefer the order of the server side cipher suite instead of the client suite.
        # This is necessary to mitigate the BEAST attack (unless you disable all non RC4 algorithms).
        # This option is enabled by default, but only used if ssl.cipher-list is set.
        #
        ssl.honor-cipher-order = "enable"
        #
        # Mitigate CVE-2009-3555 by disabling client triggered renegotation
        # This is enabled by default.
        #
        ssl.disable-client-renegotiation = "enable"
        #
        # Disable SSLv2 because is insecure
        ssl.use-sslv2= "disable"
        #
        # Disable SSLv3 (can break compatibility with some old browser) /cares
        ssl.use-sslv3 = "disable"
    }
```

Where `www.nerdz.eu` is the domain.
There's another configuration for the document root, that differs from the one above for the line:

```conf
ssl.pemfile = "/etc/lighttpd/nerdz.eu.pem"
```

# Monthly renew, using webroot

You have to change the first lines of `renew.sh` according to your configuration.

You have to change the path of this script in the `letsencrypt-lighttpd.service` file according to your configuration.

After that, you can activate the montly renew:

```bash
cp letsencrypt-lighttpd.* /etc/systemd/system/
systemct enable letsencrypt-lighttpd.timer
```

That's all.

