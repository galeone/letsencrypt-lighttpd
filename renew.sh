#!/usr/bin/env bash
set -e

# begin configuration

domains=( nerdz.eu www.nerdz.eu )
email=nessuno@nerdz.eu
w_root=/home/nessuno/
user=nessuno
group=nessuno

# end configuration

if [ "$EUID" -ne 0 ]; then
    echo  "Please run as root"
    exit 1
fi


for domain in "${domains[@]}"; do
    /usr/bin/certbot certonly --agree-tos --renew-by-default --email $email --webroot -w $w_root$domain -d $domain
    cat /etc/letsencrypt/live/$domain/privkey.pem  /etc/letsencrypt/live/$domain/cert.pem > ssl.pem
    cp ssl.pem /etc/lighttpd/$domain.pem
    cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/lighttpd/
    chown -R $user:$group /etc/lighttpd/
    rm ssl.pem
done
