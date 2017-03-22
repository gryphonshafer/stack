#!/usr/bin/env bash

if [ -f /vagrant/vagrant/mail_conf/hosts ]
then
    echo '' >> /etc/hosts
    cat /vagrant/vagrant/mail_conf/hosts >> /etc/hosts
fi

echo "$mailhost" > /etc/mailname

#-----------------------------------------------------------------------------

$aptget remove --purge exim4 exim4-base exim4-config
$aptget install postfix postfix-doc bsd-mailx

if [ -f /vagrant/vagrant/mail_conf/mynetworks ]
then
    cp /vagrant/vagrant/mail_conf/mynetworks /etc/postfix/mynetworks
else
    echo '127.0.0.1 OK # localhost' > /etc/postfix/mynetworks
fi

postmap /etc/postfix/mynetworks

cat <<\EOF_MAIN_CF > /etc/postfix/main.cf
myorigin            = /etc/mailname
smtpd_banner        = $myhostname ESMTP $mail_name (Debian/GNU)
biff                = no
append_dot_mydomain = no
delay_warning_time  = 4h

readme_directory = /usr/share/doc/postfix
html_directory   = /usr/share/doc/postfix/html

alias_maps     = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination  = /etc/hostname, /etc/mailname, localhost, localhost.localdomain
mynetworks     = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128,
    /etc/hostname, /etc/mailname,
    hash:/etc/postfix/mynetworks

mailbox_command     = procmail -a "$EXTENSION"
mailbox_size_limit  = 0
recipient_delimiter = +
inet_interfaces     = all
EOF_MAIN_CF

postfix reload

#-----------------------------------------------------------------------------

ssl_file_prefix='/etc/postfix/smtpd'

# generate a key
echo "Generating SSL key request..."
openssl genrsa -des3 -passout pass:$ssl_password \
    -out $ssl_file_prefix.key 2048 -noout

# remove passphrase from the key
echo "Removing passphrase from key..."
openssl rsa -in $ssl_file_prefix.key \
    -passin pass:$ssl_password -out $ssl_file_prefix.key

# create the request
echo "Creating CSR..."
openssl req -new -key $ssl_file_prefix.key \
    -out $ssl_file_prefix.csr -passin pass:$ssl_password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

openssl x509 -req -days 9000 -in $ssl_file_prefix.csr \
    -signkey $ssl_file_prefix.key -out $ssl_file_prefix.crt

rm $ssl_file_prefix.csr

#-----------------------------------------------------------------------------

cat <<\EOF_MAIN_CF >> /etc/postfix/main.cf

smtpd_tls_cert_file       = /etc/postfix/smtpd.crt
smtpd_tls_key_file        = /etc/postfix/smtpd.key
smtpd_use_tls             = yes
smtpd_tls_auth_only       = yes
smtpd_tls_security_level  = may
smtpd_tls_received_header = yes
EOF_MAIN_CF

postfix reload

#-----------------------------------------------------------------------------

$aptget install sasl2-bin libsasl2-2

sed -i -e 's/START=no/START=yes/' /etc/default/saslauthd
sed -i \
    -e 's/OPTIONS="-c -m \/var\/run\/saslauthd"/OPTIONS="-c -m \/var\/spool\/postfix\/var\/run\/saslauthd"/' \
    /etc/default/saslauthd

mkdir -p /var/spool/postfix/var/run/saslauthd
chown -R root.sasl /var/spool/postfix/var/run/saslauthd
adduser postfix sasl
service saslauthd restart

#-----------------------------------------------------------------------------

cat <<\SASL_CF >> /etc/postfix/sasl/smtpd.conf
pwcheck_method: saslauthd
mech_list: PLAIN
SASL_CF

cat <<\EOF_MAIN_CF >> /etc/postfix/main.cf

smtpd_sasl_auth_enable          = yes
smtpd_sasl_security_options     = noanonymous
smtpd_sasl_local_domain         = $myhostname
broken_sasl_auth_clients        = yes
smtpd_sasl_authenticated_header = yes
smtpd_helo_restrictions         = permit_sasl_authenticated, permit_mynetworks, reject_unknown_helo_hostname
smtpd_data_restrictions         = reject_unauth_pipelining
smtpd_sender_restrictions       = permit_mynetworks, reject_non_fqdn_sender, reject_unknown_sender_domain
smtpd_recipient_restrictions    =
    permit_mynetworks,
    permit_sasl_authenticated,
    reject_unauth_destination,
    reject_invalid_hostname,
    reject_rbl_client zen.spamhaus.org,
    reject_rhsbl_reverse_client dbl.spamhaus.org,
    reject_rhsbl_helo dbl.spamhaus.org,
    reject_rhsbl_sender dbl.spamhaus.org
EOF_MAIN_CF

perl -e '
    open( $f, "<", $ARGV[0] );
    $f = join( "", <$f> );
    $f =~ s/^(#submission.*?\n)(?=#\S)/ $f = $1; $f =~ s|^#||msg; $f /mse;
    print $f;
' /etc/postfix/master.cf > /tmp/master.cf

perl -e '
    open( $f, "<", $ARGV[0] );
    $f = join( "", <$f> );
    $f =~ s/^(#smtps.*?\n)(?=#\S)/ $f = $1; $f =~ s|^#||msg; $f /mse;
    print $f;
' /tmp/master.cf > /etc/postfix/master.cf

rm /tmp/master.cf

postfix reload

#-----------------------------------------------------------------------------

$aptget install gamin libgamin0 python-central python-gamin
$aptget install courier-authdaemon courier-pop courier-pop-ssl courier-imap courier-imap-ssl

sed -i -e 's/IMAP_MAILBOX_SANITY_CHECK=1/IMAP_MAILBOX_SANITY_CHECK=0/' /etc/courier/imapd

service courier-imap     restart
service courier-imap-ssl restart

#-----------------------------------------------------------------------------

if [ -f /etc/shorewall/rules ]
then

cat <<\RULES_FILE >> /etc/shorewall/rules

# mail
ACCEPT net $FW tcp 25  # smtp
ACCEPT net $FW tcp 993 # imap-ssl
ACCEPT net $FW tcp 995 # pop-ssl
ACCEPT net $FW tcp 465 # smtps
ACCEPT net $FW tcp 587 # submission
RULES_FILE

service shorewall restart

fi

#-----------------------------------------------------------------------------

if [ -f /etc/fail2ban/jail.local ]
then

cat <<JAIL_FILE >> /etc/fail2ban/jail.local

[postfix]
enabled = true
logpath = /var/log/mail.warn

[couriersmtp]
enabled = true
logpath = /var/log/mail.warn

[courierauth]
enabled = true
logpath = /var/log/mail.warn

[sasl]
enabled = true
logpath = /var/log/mail.warn
JAIL_FILE

service fail2ban restart

fi
