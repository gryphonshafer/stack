#!/usr/bin/env bash

domain="example.com"

cd /var/www/$domain
rm -rf *

# https://github.com/roundcube/roundcubemail/releases/latest
wget http://files6.directadmin.com/services/all/roundcube/roundcubemail-1.1.0-complete.tar.gz

tar xfz roundcubemail-1.1.0-complete.tar.gz
rm roundcubemail-1.1.0-complete.tar.gz
mv roundcubemail-1.1.0 roundcubemail
chown -R root. roundcubemail

mkdir roundcubemail/db
touch roundcubemail/db/rcm.sqlite

chown -R www-data. roundcubemail/temp roundcubemail/logs roundcubemail/db

cat <<\RCM_CONFIG > roundcubemail/config/config.inc.php
<?php

$config = array();

// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql or sqlsrv
// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// NOTE: for SQLite use absolute path: 'sqlite:////full/path/to/sqlite.db?mode=0646'
$config['db_dsnw'] = 'sqlite:////var/www/goldenguru.com/roundcubemail/db/rcm.sqlite?mode=0646';

// The mail host chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
// WARNING: After hostname change update of mail_host column in users table is
//          required to match old user data records with the new host.
$config['default_host'] = 'localhost';

// provide an URL where a user can get support for this Roundcube installation
$config['support_url'] = '';

// Name your service. This is displayed on the login screen and in the window title
$config['product_name'] = '';

// replace Roundcube logo with this image
// specify an URL relative to the document root of this Roundcube installation
// an array can be used to specify different logos for specific template files, '*' for default logo
// for example array("*" => "/images/roundcube_logo.png", "messageprint" => "/images/roundcube_logo_print.png")
$config['skin_logo'] = '';

// this key is used to encrypt the users imap password which is stored
// in the session record (and the client cookie if remember password is enabled).
// please provide a string of exactly 24 chars.
$config['des_key'] = 'C&bdy53_&ra$r8E6wENje-Bp';

// List of active plugins (in plugins/ directory)
$config['plugins'] = array(
    'additional_message_headers',
    'archive',
    'attachment_reminder',
    'emoticons',
    'help',
    'jqueryui',
    'legacy_browser',
    'markasjunk',
    'new_user_dialog',
    'newmail_notifier',
    'userinfo',
    'vcard_attachments',
    'zipdownload'
);

// skin name: folder from skins/
$config['skin'] = 'larry';

$config['enable_installer'] = true;

?>
RCM_CONFIG

cd roundcubemail/db
php-cgi index.php _step=3 > /dev/null

cd ..
perl -i -pe "s/config\['enable_installer'\] = true/config\['enable_installer'\] = false/" config/config.inc.php
rm -rf installer

#-----------------------------------------------------------------------------

perl -i -pe 's/(server_name.*)\bwww\b/${1}mail/g' /etc/nginx/sites-available/$domain

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/        proxy_pass http:\/\/localhost;/
d
i
        root /var/www/goldenguru.com/roundcubemail;
        index index.html index.php;
        include fastcgi_php;
.
wq
CONF_FILE

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/    root \/var\/www\/goldenguru.com\/htdocs;/
d
d
d
.
wq
CONF_FILE

ex /etc/nginx/sites-available/$domain <<\CONF_FILE
/} # 80/
i

    rewrite ^/$     https://$host    redirect;
    rewrite ^/(.*)$ https://$host/$1 redirect;
.
wq
CONF_FILE

service nginx restart
