#!/usr/bin/env bash

groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/vmail -m

touch /var/vmail/aliases
touch /var/vmail/users

for _conf_file in \
    mailbox_domains \
    alias_domains \
    aliases
do
    _file="/vagrant/vagrant/mail_conf/$_conf_file"
    [ -f /vagrant/vagrant/backups/mail_conf/$_conf_file ] && _file="/vagrant/vagrant/backups/mail_conf/$_conf_file"
    cp $_file /var/vmail/$_conf_file 2> /dev/null

    if [ -f /var/vmail/$_conf_file ]
    then
        chmod 644   /var/vmail/$_conf_file
        chown root. /var/vmail/$_conf_file
    fi
done

postmap /var/vmail/aliases
postmap /var/vmail/users

cat <<\EOF_MAIN_CF >> /etc/postfix/main.cf

virtual_mailbox_base    = /var/vmail
virtual_mailbox_domains = /var/vmail/mailbox_domains
virtual_mailbox_maps    = hash:/var/vmail/users
virtual_alias_maps      = hash:/var/vmail/aliases
virtual_alias_domains   = /var/vmail/alias_domains
virtual_minimum_uid     = 100
virtual_uid_maps        = static:5000
virtual_gid_maps        = static:5000
EOF_MAIN_CF

postfix reload

#-----------------------------------------------------------------------------

sed -i -e 's/authmodulelist="authpam"/authmodulelist="authuserdb"/' /etc/courier/authdaemonrc
invoke-rc.d courier-authdaemon restart

#-----------------------------------------------------------------------------

sed -i -e 's/MECHANISMS="pam"/MECHANISMS="rimap"/' /etc/default/saslauthd
sed -i -e 's/MECH_OPTIONS=""/MECH_OPTIONS="localhost"/' /etc/default/saslauthd
perl -i -pe 's|^OPTIONS="([^"]+)"|OPTIONS="$1 -r"|' /etc/default/saslauthd
service saslauthd restart

#-----------------------------------------------------------------------------

cp /vagrant/vagrant/mail_utils/create-mail-user /root/. 2> /dev/null
cp /vagrant/vagrant/mail_utils/delete-mail-user /root/. 2> /dev/null
cp /vagrant/vagrant/mail_utils/chpwd-mail-user  /root/. 2> /dev/null

if [[ -f /root/create-mail-user && -f /vagrant/vagrant/mail_conf/create_users ]]
then
    while read _user _domain _passwd
    do
        echo "create-mail-user $_user $_domain $_passwd"
        /root/create-mail-user $_user $_domain $_passwd
    done < /vagrant/vagrant/mail_conf/create_users
fi
