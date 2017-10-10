#!/usr/bin/env bash

function ssl_generate {
    ssl_dir="."
    ssl_password=${ssl_password:-`randpasswd`}

    openssl genrsa -des3 -passout pass:$ssl_password -out $ssl_dir/$domain.key 2048 -noout
    openssl rsa -in $ssl_dir/$domain.key -passin pass:$ssl_password -out $ssl_dir/$domain.key

    openssl req -new -key $ssl_dir/$domain.key \
        -out $ssl_dir/$domain.csr -passin pass:$ssl_password \
        -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

    openssl x509 -req -days 9000 -in $ssl_dir/$domain.csr \
        -signkey $ssl_dir/$domain.key -out $ssl_dir/$domain.crt

    rm $ssl_dir/$domain.csr
}
