#!/usr/bin/env bash

apt-get install mailman listadmin

_vam=$( postconf virtual_alias_maps | sed -e 's/virtual_alias_maps = //' )
if [ ${#_vam} -gt 0 ]
then
    _vam="hash:/etc/mailman/aliases, $_vam"
else
    _vam="hash:/etc/mailman/aliases"
fi

postconf -e "virtual_alias_maps = $_vam"
postfix reload

cp /vagrant/vagrant/mail_utils/create-mailman-list /root/. 2> /dev/null

/root/create-mailman-list mailman $domain $email $user_password

while read _name _domain _email _passwd
do
    /root/create-mailman-list $_name $_domain $_email $_passwd
done < /vagrant/vagrant/mail_conf/mailman_lists

#-----------------------------------------------------------------------------

if [ ! -f /etc/default/fcgiwrap ]
then

$aptget install fcgiwrap

/bin/cat <<\DEFAULT_SETTINGS > /etc/default/fcgiwrap
FCGI_CHILDREN="3"
DEFAULT_SETTINGS

service fcgiwrap restart

fi

#-----------------------------------------------------------------------------

if [ -d /etc/nginx/conf.d ]
then

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/} # 80/
i

    rewrite ^/mailman$      https://$host/cgi-bin/mailman/listinfo redirect;
    rewrite ^/mailman/(.*)$ https://$host/cgi-bin/mailman/$1       redirect;

    rewrite ^/pipermail$      https://$host/pipermail    redirect;
    rewrite ^/pipermail/(.*)$ https://$host/pipermail/$1 redirect;

    rewrite ^/cgi-bin/mailman$      https://$host/cgi-bin/mailman    redirect;
    rewrite ^/cgi-bin/mailman/(.*)$ https://$host/cgi-bin/mailman/$1 redirect;
.
wq
CONF_FILE

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/} # 443/
i

    rewrite ^/mailman$      /cgi-bin/mailman/listinfo redirect;
    rewrite ^/mailman/(.*)$ /cgi-bin/mailman/$1       redirect;

    location /cgi-bin/mailman {
        root /usr/lib/;
        fastcgi_split_path_info (^/cgi-bin/mailman/[^/]*)(.*)$;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        include /etc/nginx/fastcgi_params;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/var/run/fcgiwrap.socket;
    }

    location /images/mailman {
        alias /usr/share/images/mailman;
    }

    location /pipermail {
        alias /var/lib/mailman/archives/public;
        autoindex on;
    }
.
wq
CONF_FILE

service nginx restart

fi

#-----------------------------------------------------------------------------

cp /vagrant/vagrant/mail_utils/export-mm-data /root/. 2> /dev/null
