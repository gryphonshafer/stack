#!/usr/bin/env bash

apt-get install build-essential tcl8.5

cd /tmp
wget http://download.redis.io/releases/redis-stable.tar.gz

tar xfpz redis-stable.tar.gz
rm redis-stable.tar.gz
cd redis-stable

make
make install

#-----------------------------------------------------------------------------

mkdir /var/lib/redis
mkdir /etc/redis
cp redis.conf /etc/redis/.

sed -i -e 's/^daemonize no/daemonize yes/' /etc/redis/redis.conf
sed -i -e 's/^# bind 127.0.0.1/bind 127.0.0.1/' /etc/redis/redis.conf
sed -i -e 's/^tcp-keepalive 0/tcp-keepalive 60/' /etc/redis/redis.conf
sed -i -e 's/^logfile ""/logfile "\/var\/log\/redis.log"/' /etc/redis/redis.conf
sed -i -e 's/^dir .\//dir \/var\/lib\/redis/' /etc/redis/redis.conf

#-----------------------------------------------------------------------------

cat <<\CONF_FILE > /etc/init.d/redis
#!/bin/sh

EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli
PIDFILE=/var/run/redis.pid
CONF=/etc/redis/redis.conf
REDISPORT="6379"

### BEGIN INIT INFO
# Provides: redis
# Required-Start: $network $local_fs $remote_fs
# Required-Stop: $network $local_fs $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Should-Start: $syslog $named
# Should-Stop: $syslog $named
# Short-Description: start and stop redis
# Description: Redis daemon
### END INIT INFO

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
            echo "$PIDFILE exists, process is already running or crashed"
        else
            echo "Starting Redis server..."
            $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
            echo "$PIDFILE does not exist, process is not running"
        else
            PID=$(cat $PIDFILE)
            echo "Stopping ..."
            $CLIEXEC -p $REDISPORT shutdown
            while [ -x /proc/${PID} ]
            do
                echo "Waiting for Redis to shutdown ..."
                sleep 1
            done
            echo "Redis stopped"
        fi
        ;;
    status)
        PID=$(cat $PIDFILE)
        if [ ! -x /proc/${PID} ]
        then
            echo 'Redis is not running'
        else
            echo "Redis is running ($PID)"
        fi
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Please use start, stop, restart or status as first argument"
        ;;
esac
CONF_FILE

chmod a+x /etc/init.d/redis
update-rc.d redis defaults
service redis start

#-----------------------------------------------------------------------------

cd /tmp
rm -rf redis-stable
