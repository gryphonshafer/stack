#!/usr/bin/env bash

domain="example.com"
user_username="dev"

apt-get install trac trac-xmlrpc python-flup

mkdir -p /var/trac/$domain
trac-admin /var/trac/$domain initenv "$domain Trac" 'sqlite:db/trac.db'
trac-admin /var/trac/$domain permission add $user_username TRAC_ADMIN

#-----------------------------------------------------------------------------

cat <<\INIT_FILE > /etc/init.d/tracd-fcgi
#!/bin/bash
### BEGIN INIT INFO
# Provides:          trac
# Required-Start:    nginx
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Trac
# Description:       Trac web services
### END INIT INFO

PORT=3050
PID_FILE=/var/run/tracd.pid
ROOT_DIR=/var/trac
BASE_PATH=/trac

start() {
    echo -n "Starting tracd: "

    _auth=""
    for i in $( /bin/ls -d /var/trac/* )
    do
        if [ -d $i ]
        then
            _instance=$( /usr/bin/basename $i )

            _access=""
            if [ -f $i/conf/htaccess ]
            then
                _access="$i/conf/htaccess"
            elif [ -f /etc/nginx/htauth/$_instance ]
            then
                _access="/etc/nginx/htauth/$_instance"
            fi

            if [ ${#_access} -gt 0 ]
            then
                _auth="$_auth --basic-auth=$_instance,$_access,'$_instance Trac'"
            fi
        fi
    done

    /usr/bin/tracd -d \
        -p $PORT --pidfile=$PID_FILE --protocol=http -e $ROOT_DIR \
        --base-path=$BASE_PATH --hostname=127.0.0.1 \
        $_auth

    RETVAL=$?
}
stop() {
    echo -n "Stopping tracd: "
    PID="$(cat "$PID_FILE")"
    /bin/kill $PID
    RETVAL=$?
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
      echo "Usage: tracd {start|stop|restart}"
      exit 1
  ;;
esac
echo 'Done'
exit $RETVAL
INIT_FILE

echo "$user_username:`/bin/echo $user_password | /usr/bin/perl -lne 'print crypt( $_, rand() * 100 )'`" \
    > /var/trac/$domain/conf/htaccess

chmod a+x /etc/init.d/tracd-fcgi
update-rc.d -f tracd-fcgi defaults
service tracd-fcgi start

#-----------------------------------------------------------------------------

if [ -d /etc/nginx/conf.d ]
then

echo 'Configuring Nginx for TracD...'

cat <<CONF_FILE >> /etc/nginx/conf.d/upstream.conf
upstream trac {
    server 127.0.0.1:3050;
}
CONF_FILE

ex /etc/nginx/sites-available/$domain << CONF_FILE
/} # 80/
i

    rewrite ^/trac$  /trac/$domain redirect;
    rewrite ^/trac/$ /trac/$domain redirect;
    location /trac {
        proxy_pass http://trac;
        auth_basic "$domain Trac";
        auth_basic_user_file "/var/trac/$domain/conf/htaccess";
        proxy_pass_header Authorization;
    }
.
wq
CONF_FILE

service nginx restart

fi

#-----------------------------------------------------------------------------

cd /tmp
wget https://pypi.python.org/packages/source/T/TracPermRedirect/TracPermRedirect-3.0.tar.gz
tar xvfpz TracPermRedirect-3.0.tar.gz
cd TracPermRedirect-3.0
python setup.py bdist_egg
mv dist/TracPermRedirect-3.0-py2.7.egg /var/trac/$domain/plugins/.
cd /tmp
rm -rf TracPermRedirect-3.0 TracPermRedirect-3.0.tar.gz

cat <<CONF_FILE >> /var/trac/$domain/conf/trac.ini

[components]
permredirect.* = enabled
CONF_FILE

service tracd-fcgi restart
