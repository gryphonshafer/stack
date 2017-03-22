#!/usr/bin/env bash

domain="example.com"
dev="user_username"

# for additional information about Nagios web portal installation, see:
# http://johan.cc/2012/02/06/nagios-nginx/
# http://blog.martinfjordvald.com/2011/01/no-input-file-specified-with-php-and-nginx/

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/} # 80/
i

    rewrite ^/nagios$      https://$host/nagios    redirect;
    rewrite ^/nagios/(.*)$ https://$host/nagios/$1 redirect;
.
wq
CONF_FILE

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/} # 443/
i

    location /nagios {
        alias /opt/nagios/share;
        index index.php index.html;

        include fastcgi_php;

        auth_basic "Nagios Restricted Access";
        auth_basic_user_file /etc/nagios/htpasswd.users;
    }
    location /nagios/cgi-bin {
        alias /opt/nagios/sbin;

        include fastcgi_perl_set;
        fastcgi_param AUTH_USER $remote_user;
        fastcgi_param REMOTE_USER $remote_user;

        auth_basic "Nagios Restricted Access";
        auth_basic_user_file /etc/nagios/htpasswd.users;
    }
.
wq
CONF_FILE

service nginx restart

#-----------------------------------------------------------------------------

perl -pi -e "s/(authorized_for_[^=]+=nagiosadmin)/\$1,$user_username/" /etc/nagios/cgi.cfg
service nagios restart
