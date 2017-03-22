#!/usr/bin/env bash

chsh -s /bin/bash www-data

if [ -d /opt/perl5 ]
then

su -l www-data <<EOF
. /opt/perl5/etc/bashrc
perlbrew switch `perlbrew list`
perlbrew lib create local
perlbrew switch @local
EOF

fi

#-----------------------------------------------------------------------------

$aptget install fcgiwrap spawn-fcgi

cp /etc/init.d/fcgiwrap /var/backups/fcgiwrap.original

cat <<\INIT_SCRIPT > /etc/init.d/fcgiwrap
#!/bin/sh

### BEGIN INIT INFO
# Provides:          fcgiwrap
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: FastCGI wrapper
# Description:       Simple server for running CGI applications over FastCGI
### END INIT INFO

NAME="fcgiwrap"
DESC="FastCGI wrapper"

PIDFILE="/var/run/$NAME.pid"
SPAWN_FCGI="/usr/bin/spawn-fcgi"
DAEMON="/usr/sbin/fcgiwrap"
DAEMON_OPTS="-f"

FCGI_CHILDREN="1"
FCGI_SOCKET="/var/run/$NAME.socket"
FCGI_USER="www-data"
FCGI_GROUP="www-data"

if [ -f /etc/default/$NAME ]
then
    . /etc/default/$NAME
fi

set_args() {
    ARGS="-P $PIDFILE"

    if [ -n "$FCGI_CHILDREN" ]
    then
       ARGS="$ARGS -F $FCGI_CHILDREN"
    fi

    if [ -n "$FCGI_SOCKET" ]
    then
        ARGS="$ARGS -s $FCGI_SOCKET"
    elif [ -n "$FCGI_PORT" ]
    then
        if [ -n "$FCGI_ADDR" ]
        then
            ARGS="$ARGS -a $FCGI_ADDR"
        fi
        ARGS="$ARGS -p $FCGI_PORT"
    fi

    if [ -n "$FCGI_USER" ]
    then
        ARGS="$ARGS -u $FCGI_USER"
        if [ -n "$FCGI_SOCKET" ]
        then
            if [ -n "$FCGI_SOCKET_OWNER" ]
            then
                ARGS="$ARGS -U $FCGI_SOCKET_OWNER"
            else
                ARGS="$ARGS -U $FCGI_USER"
            fi
        fi
    fi

    if [ -n "$FCGI_GROUP" ]
    then
        ARGS="$ARGS -g $FCGI_GROUP"
        if [ -n "$FCGI_SOCKET" ]
        then
            if [ -n "$FCGI_SOCKET_GROUP" ]
            then
                ARGS="$ARGS -G $FCGI_SOCKET_GROUP"
            else
                ARGS="$ARGS -G $FCGI_GROUP"
            fi
        fi
    fi
}

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
            echo "$PIDFILE exists, process is already running or crashed"
        else
            echo "Starting $DESC..."

            set_args
            COMMAND="$SPAWN_FCGI $ARGS -- $DAEMON $DAEMON_OPTS"
            eval $(echo $COMMAND) > /dev/null

            if [ $? -gt "0" ]
            then
                echo "$DESC failed to start using command:"
                echo $COMMAND
                exit 1
            fi

            echo "$DESC started"
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
            echo "$PIDFILE does not exist, process is not running"
        else
            PID=$(cat $PIDFILE)
            echo "Stopping $DESC..."

            kill $PID
            unlink $FCGI_SOCKET
            unlink $PIDFILE

            echo "$DESC stopped"
        fi
        ;;
    status)
        PID=0
        if [ -f $PIDFILE ]
        then
            PID=$(cat $PIDFILE)

            if ps -p $PID > /dev/null
            then
                echo "$DESC is running"
                exit 0
            fi
        fi

        echo "$DESC is not running"
        exit 1
        ;;
    restart)
        echo "Restarting $DESC..."
        $0 stop
        $0 start
        ;;
    *)
        INIT_FILE=$(basename $0)
        echo "Usage: $INIT_FILE {start|stop|restart|status}"
        ;;
esac

exit 0
INIT_SCRIPT

chmod a+x /etc/init.d/fcgiwrap
update-rc.d fcgiwrap defaults

cat <<\DEFAULT_SETTINGS > /etc/default/fcgiwrap
FCGI_CHILDREN="3"

export USER="www-data"
export HOME="/var/www"
export LOGNAME="www-data"
export MAIL="/var/mail/www-data"

if [ -d /opt/perl5 ]
then
    export PERLBREW_ROOT="/opt/perl5"
    export PERLBREW_HOME="${HOME}/.perlbrew"
    . ${PERLBREW_HOME}/init

    __perlbrew_code="$(${PERLBREW_ROOT}/bin/perlbrew env ${PERLBREW_PERL}@${PERLBREW_LIB})"
    eval "$__perlbrew_code"
    unset __perlbrew_code

    export PATH=${PERLBREW_PATH}:$PATH
    export MANPATH=${PERLBREW_MANPATH}:$MANPATH
fi
DEFAULT_SETTINGS

/etc/init.d/fcgiwrap restart

#-----------------------------------------------------------------------------

if [ -d /etc/nginx/conf.d ]
then

echo 'Configuring FastCGI Perl Nginx...'

cat <<CONF_FILE >> /etc/nginx/conf.d/upstream.conf
upstream perl {
    server unix:/var/run/fcgiwrap.socket;
}
CONF_FILE

cat <<CONF_FILE >> /etc/nginx/fastcgi_perl_set
include fastcgi_params;
fastcgi_intercept_errors on;
fastcgi_pass perl;
CONF_FILE

cat <<CONF_FILE >> /etc/nginx/fastcgi_perl
location ~ \.(pl|cgi)$ {
    include fastcgi_perl_set;
}
CONF_FILE

perl -i -pe 's/(index .*);/$1 index.pl index.cgi;/' /etc/nginx/sites-available/$domain
service nginx restart

fi
