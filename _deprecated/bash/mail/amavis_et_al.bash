#!/usr/bin/env bash

apt-get install \
    amavisd-new spamassassin zoo unzip bzip2 \
    libnet-ph-perl libnet-snpp-perl libnet-telnet-perl nomarch lzop pax

perl -e '
    open( $f, "<", $ARGV[0] );
    $f = join( "", <$f> );
    $f =~ s/^(#\@bypass_spam.*?;)/ $f = $1; $f =~ s|^#||msg; $f /msge;
    print $f;
' /etc/amavis/conf.d/15-content_filter_mode > /tmp/15-content_filter_mode
mv /tmp/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode

sed -i '/use strict;/a $pax = q(pax);' /etc/amavis/conf.d/50-user
sed -i "/#\$myhostname/a \$myhostname = '$mailhost';" /etc/amavis/conf.d/05-node_id

cat <<\EOF_MAIN_CF >> /etc/postfix/main.cf

content_filter           = amavis:[127.0.0.1]:10024
receive_override_options = no_address_mappings
EOF_MAIN_CF

cat <<\EOF_MASTER_CF >> /etc/postfix/master.cf
amavis unix - - - - 2 smtp
  -o smtp_data_done_timeout=1200
  -o smtp_send_xforward_command=yes

127.0.0.1:10025 inet n - - - - smtpd
  -o content_filter=
  -o local_recipient_maps=
  -o relay_recipient_maps=
  -o smtpd_restriction_classes=
  -o smtpd_client_restrictions=
  -o smtpd_helo_restrictions=
  -o smtpd_sender_restrictions=
  -o smtpd_recipient_restrictions=permit_mynetworks,reject
  -o mynetworks=127.0.0.0/8
  -o strict_rfc821_envelopes=yes
  -o receive_override_options=no_unknown_recipient_checks,no_header_body_checks
EOF_MASTER_CF

#-----------------------------------------------------------------------------

apt-get install razor pyzor

cd /root
$wget http://launchpadlibrarian.net/11565554/dcc-server_1.3.42-5_amd64.deb
$wget http://launchpadlibrarian.net/11565552/dcc-common_1.3.42-5_amd64.deb
dpkg -i dcc-common_1.3.42-5_amd64.deb
dpkg -i dcc-server_1.3.42-5_amd64.deb
rm dcc-common_1.3.42-5_amd64.deb dcc-server_1.3.42-5_amd64.deb

cat <<\EOF_CF >> /etc/spamassassin/local.cf

#dcc
use_dcc 1
dcc_path /usr/bin/dccproc

#pyzor
use_pyzor 1
pyzor_path /usr/bin/pyzor

#razor
use_razor2 1
razor_config /etc/razor/razor-agent.conf

#bayes
use_bayes 1
use_bayes_rules 1
bayes_auto_learn 1
EOF_CF

sed -i \
    's/#loadplugin Mail::SpamAssassin::Plugin::DCC/loadplugin Mail::SpamAssassin::Plugin::DCC/' \
    /etc/spamassassin/v310.pre

#-----------------------------------------------------------------------------

sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/spamassassin

sa-update --no-gpg --refreshmirrors -v

service rsyslog restart
service spamassassin restart
service amavis restart

#-----------------------------------------------------------------------------

cp /vagrant/vagrant/mail_utils/clear-queue      /root/. 2> /dev/null
cp /vagrant/vagrant/mail_utils/spam-learn-clean /root/. 2> /dev/null
cp /vagrant/vagrant/mail_utils/mail-action      /root/. 2> /dev/null
