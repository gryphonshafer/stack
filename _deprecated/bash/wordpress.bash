#!/usr/bin/env bash

domain="example.com"

echo 'Downloading Wordpress source...'
cd /tmp
wget http://wordpress.org/latest.tar.gz

echo 'Installing Wordpress...'
tar -xzf latest.tar.gz
rm latest.tar.gz
chmod a+w wordpress/wp-content

echo 'Configuring Wordpress...'
mv wordpress/wp-config-sample.php wordpress/wp-config.php
echo "define('DB_DIR', '/var/www/$domain/blog/');" >> wordpress/wp-config.php
echo "define('DB_FILE', 'db_file_name');"          >> wordpress/wp-config.php

echo 'Deploying Wordpress...'
rm -rf /var/www/$domain/htdocs
chown www-data.www-data /var/www/$domain
mv wordpress /var/www/$domain/blog

rm -rf /var/www/$domain/blog/wp-content/plugins/akismet
rm -rf /var/www/$domain/blog/wp-content/plugins/hello.php

#-----------------------------------------------------------------------------

cat <<UPGRADE_FILE > /var/www/$domain/blog/wp-upgrade.bash
#!/usr/bin/env bash

/bin/echo 'Upgrading Wordpress...'

cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
rm latest.zip
chown -R nobody.nogroup wordpress

if [ -f /var/www/$domain/blog/wp-update.bash ]
then
    cp -p /var/www/$domain/blog/wp-update.bash wordpress/.
fi

if [ -f /var/www/$domain/blog/wp-upgrade.bash ]
then
    cp -p /var/www/$domain/blog/wp-upgrade.bash wordpress/.
fi

sed -i -e 's/<h1>/<h1 style="display: none">/' wordpress/wp-login.php
cp -rp /var/www/$domain/blog/wp-content wordpress/.
cp -p /var/www/$domain/blog/wp-config.php wordpress/.

rm -rf /var/www/$domain/blog
mv wordpress /var/www/$domain/blog

/etc/init.d/php-fcgi restart
UPGRADE_FILE

chown root.root /var/www/$domain/blog/wp-upgrade.bash
chmod 700       /var/www/$domain/blog/wp-upgrade.bash

#-----------------------------------------------------------------------------

sed -i -e 's/<h1>/<h1 style="display: none">/' wordpress/wp-login.php

#-----------------------------------------------------------------------------

cat <<\UPDATE_FILE > /var/www/$domain/blog/wp-update.bash
#!/usr/bin/env bash

/bin/echo 'Installing plugins...'
for i in \
    author-avatars.zip \
    custom-sidebars.zip \
    flickr-me.zip \
    foobox-image-lightbox.zip \
    social-media-feather.zip \
    wp-twitter-feeds.zip \
    captcha.4.1.1.zip \
    sqlite-integration.1.8.1.zip
do
    echo "  $i"
    /usr/bin/wget -N -q http://downloads.wordpress.org/plugin/$i
    builtin cd wp-content/plugins
    /usr/bin/unzip -o -q ../../$i
    if [ -f sqlite-integration/db.php ]
    then
        /bin/mv sqlite-integration/db.php ../
    fi
    builtin cd ../..
    /bin/rm $i
done

/bin/echo 'Installing themes...'
for i in \
    twentyfifteen.1.2.zip \
    twentyfourteen.1.4.zip
do
    echo "  $i"
    /usr/bin/wget -N -q http://wordpress.org/themes/download/$i
    builtin cd wp-content/themes
    /usr/bin/unzip -o -q ../../$i
    /bin/chown -R www-data.www-data *
    builtin cd ../..
    /bin/rm $i
done
UPDATE_FILE

chown root.root /var/www/$domain/blog/wp-update.bash
chmod 700       /var/www/$domain/blog/wp-update.bash

cd /var/www/$domain/blog
. wp-update.bash

#-----------------------------------------------------------------------------

if [ -d /etc/nginx/sites-available ]
then

echo 'Configuring Nginx for FastCGI PHP use of WordPress...'

perl -i -pe 's|root /var/www/([^/]+)/htdocs;|root /var/www/$1/blog;|' /etc/nginx/sites-available/$domain

ex /etc/nginx/sites-available/$domain << CONF_FILE
/} # 80/
i

    location / {
        include fastcgi_php;
        try_files $uri $uri/ /index.php?$args;
    }

    location /wp-content/database {
        deny all;
    }
.
wq
CONF_FILE

rm -rf /var/www/$domain/htdocs
service nginx restart

fi
