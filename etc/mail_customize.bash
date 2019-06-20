#!/usr/bin/env bash

SRC=/home/gryphon

cd $HOME
./mail-action stop
tar xfpz $SRC/uber.etc-root.tar.gz

# letsencrypt

cd /etc
rm -rf letsencrypt
cp -rp ~/etc/letsencrypt .

cp /etc/letsencrypt/live/mail.goldenguru.com/fullchain.pem /etc/postfix/smtpd.crt
cp /etc/letsencrypt/live/mail.goldenguru.com/privkey.pem   /etc/postfix/smtpd.key

cat \
    /etc/letsencrypt/live/mail.goldenguru.com/privkey.pem \
    /etc/letsencrypt/live/mail.goldenguru.com/fullchain.pem \
    > /etc/courier/imapd.pem

cat \
    /etc/letsencrypt/live/mail.goldenguru.com/privkey.pem \
    /etc/letsencrypt/live/mail.goldenguru.com/fullchain.pem \
    > /etc/courier/pop3d.pem

# shorewall

cd /etc/shorewall
cat ~/etc/shorewall/blacklist_manual > /etc/shorewall/rules.d/anti_spam
cat ~/etc/shorewall/blacklist_auto > /etc/shorewall/rules.d/blacklist_auto
service shorewall restart

# courier

cd /etc/courier
cp -p ~/etc/courier/userd* .

# nginx

rm /etc/nginx/sites-available/*
cp -p ~/etc/nginx/sites-available/* /etc/nginx/sites-available
rm /etc/nginx/sites-available/longview

for site in /etc/nginx/sites-available/*.*
do
    cat $site | grep -v ssl_params > ${site}_
    cat ${site}_ > $site
    rm ${site}_
done

cat <<\EOF > /etc/nginx/sites-available/80_base
include snippets/server.conf;
include snippets/mailman_80_rewrites.conf;

rewrite ^/$     https://$host    redirect;
rewrite ^/(.*)$ https://$host/$1 redirect;

include snippets/nagios_ui_80.conf;
EOF

cat <<\EOF > /etc/nginx/sites-available/443_base
include snippets/server.conf;
include snippets/ssl_params.conf;

location / {
    root /var/lib/roundcube;
    index index.html index.php;
    include snippets/fastcgi_php.conf;
}

include snippets/mailman_443_cgi.conf;
include snippets/nagios_ui_443.conf;
EOF

cd /etc/nginx/sites-enabled
rm *
for site in $(ls /etc/nginx/sites-available/*.*)
do
    base_site=$(basename $site)
    ln -s ../sites-available/$base_site $base_site
done

rm -rf /var/www
service nginx restart

# opendkim

export DKIMVER=$(cat /etc/opendkim/key.table | perl -pe 's/^.*?:|:.*?$//g')
cat ~/etc/opendkim/KeyTable | perl -ne '/^mail\._domainkey\.(\S+)/; printf "%-20s %s:%s:/etc/opendkim/keys/%s.%s.private\n", $1, $1, $ENV{DKIMVER}, $1, $ENV{DKIMVER}' > /etc/opendkim/key.table
cat ~/etc/opendkim/SigningTable | perl -pe 's/mail\._domainkey\.//g' > /etc/opendkim/signing.table
cat ~/etc/opendkim/TrustedHosts > /etc/opendkim/trusted.hosts

for site in $(cat ~/etc/opendkim/KeyTable | perl -ne '/^mail\._domainkey\.(\S+)/; print "$1\n"')
do
    cp ~/etc/opendkim/keys/$site/mail.private /etc/opendkim/keys/$site.$DKIMVER.private
    cp ~/etc/opendkim/keys/$site/mail.txt /etc/opendkim/keys/$site.$DKIMVER.txt
done

chown -R opendkim. /etc/opendkim
chmod a+r /etc/opendkim/keys/*.txt

# amavis

cd /var/lib/amavis
rm -rf .spamassassin
tar xfpz $SRC/uber.spamassassin.tar.gz
chown -R amavis. .spamassassin

# vmail

cd /var
rm -rf vmail
tar xfpz $SRC/uber.vmail.tar.gz

# misc

cd $HOME
tar xfpz $SRC/uber.home.tar.gz
cp -rp ~/home/gryphon/imap /home/gryphon
chown -R gryphon. /home/gryphon/imap

# cleanup

rm -rf ~/etc ~/root ~/home
cd $HOME
./mail-action start
