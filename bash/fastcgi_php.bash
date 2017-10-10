#!/usr/bin/env bash

apt-get install php5-common php5-cgi php5 php5-sqlite php5-curl

echo 'Configuring PHP FastCGI...'
echo 'cgi.fix_pathinfo = 0;' >> /etc/php5/cgi/php.ini

cat <<\DEFAULT_SETTINGS > /etc/default/php-fcgi
BIND=127.0.0.1:9000
USER=www-data
PHP_FCGI_CHILDREN=3
PHP_FCGI_MAX_REQUESTS=1000
DEFAULT_SETTINGS

cat <<\CONF_FILE > /etc/init.d/php-fcgi
#!/bin/bash
### BEGIN INIT INFO
# Provides:          php-fcgi
# Required-Start:    nginx
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: PHP FastCGI
# Description:       PHP FastCGI
### END INIT INFO

# Include defaults if available
if [ -f /etc/default/php-fcgi ] ; then
    . /etc/default/php-fcgi
fi

PHP_CGI=/usr/bin/php-cgi
PHP_CGI_NAME=`basename $PHP_CGI`
PHP_CGI_ARGS="- USER=$USER PATH=/usr/bin PHP_FCGI_CHILDREN=$PHP_FCGI_CHILDREN PHP_FCGI_MAX_REQUESTS=$PHP_FCGI_MAX_REQUESTS $PHP_CGI -b $BIND"
RETVAL=0

start() {
    echo -n "Starting PHP FastCGI: "
    start-stop-daemon --quiet --start --background --chuid "$USER" --exec /usr/bin/env -- $PHP_CGI_ARGS
    RETVAL=$?
    echo "$PHP_CGI_NAME."
}
stop() {
    echo -n "Stopping PHP FastCGI: "
    killall -q -w -u $USER $PHP_CGI
    RETVAL=$?
    echo "$PHP_CGI_NAME."
}

case "$1" in
    start)
      start
  ;;
    stop)
      stop
  ;;
    restart)
      stop
      start
  ;;
    *)
      echo "Usage: php-fastcgi {start|stop|restart}"
      exit 1
  ;;
esac
exit $RETVAL
CONF_FILE

chmod a+x /etc/init.d/php-fcgi
update-rc.d -f php-fcgi defaults
service php-fcgi start

#-----------------------------------------------------------------------------

if [ -d /etc/nginx/conf.d ]
then

echo 'Configuring FastCGI PHP Nginx...'

cat <<CONF_FILE >> /etc/nginx/conf.d/upstream.conf
upstream php {
    server 127.0.0.1:9000;
}
CONF_FILE

cat <<CONF_FILE >> /etc/nginx/fastcgi_php
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_intercept_errors on;
    fastcgi_pass php;
}
CONF_FILE

perl -i -pe 's/(index .*);/$1 index.php;/' /etc/nginx/sites-available/$domain
service nginx restart

fi
