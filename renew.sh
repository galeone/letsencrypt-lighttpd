#!/usr/bin/env bash 
set -eu

# begin configuration

# domain_subdomains syntax: 2 avaialble
# 1: domain subdomain1 subdomain2 ...
# 2: subdomain.domain

domain_subdomains=( \
"nerdz.eu w ww www mobile static" \
"example.com sub" \
"otherwebsite.net sub1 sub2" \
"domain.duckdns.org" \
)
email=nessuno@nerdz.eu
w_root=/home/nessuno/
user=nessuno
group=nessuno

# end configuration

if [ "$EUID" -ne 0 ]; then
    echo  "Please run as root"
    exit 1
fi

for domain_set_string in "${domain_subdomains[@]}"; do
    domain_set=(${domain_set_string// / })
    domain=${domain_set[0]}
    unset domain_set[0]

    all_subdomains="-d $domain"
    if [ ${#domain_set[@]} -gt 0 ]; then
        for sub_domain in "${domain_set[@]}"; do
            all_subdomains="$all_subdomains -d $sub_domain.$domain"
        done
    fi

    /usr/bin/certbot certonly --agree-tos --renew-by-default \
        --rsa-key-size 4096 --email $email --webroot -w $w_root$domain \
        $all_subdomains
    cat /etc/letsencrypt/live/$domain/privkey.pem \
        /etc/letsencrypt/live/$domain/cert.pem \
        > /etc/lighttpd/$domain.pem
    cp /etc/letsencrypt/live/$domain/fullchain.pem \
       /etc/lighttpd/
    chown -R $user:$group /etc/lighttpd/
done
