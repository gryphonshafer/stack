#!/usr/bin/env bash

# for more information, see: http://idevit.nl/node/93

apt-get install libperl-dev libpng12-dev libgd2-xpm-dev build-essential php5-gd

adduser --system --no-create-home --disabled-login --group nagios
groupadd nagcmd
usermod -G nagcmd nagios
usermod -a -G nagcmd www-data

cd /usr/local/src

echo 'Downloading Nagios source and plugins, which may take a bit...'
$wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.8.tar.gz
$wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz

tar xf nagios-4.0.8.tar.gz
tar xf nagios-plugins-2.0.3.tar.gz

rm nagios-4.0.8.tar.gz nagios-plugins-2.0.3.tar.gz
cd nagios-4.0.8

./configure \
    --prefix /opt/nagios \
    --sysconfdir=/etc/nagios \
    --with-nagios-user=nagios \
    --with-nagios-group=nagios \
    --with-command-user=nagios \
    --with-command-group=nagcmd

make all
make install
make install-init
make install-config
make install-commandmode

#-----------------------------------------------------------------------------

cd /usr/local/bin
$wget http://trac.edgewall.org/export/10791/trunk/contrib/htpasswd.py
chmod +x htpasswd.py
htpasswd.py -c -b /etc/nagios/htpasswd.users $user_username $user_password

sed -i -e "s/nagios@localhost/$email/" /etc/nagios/objects/contacts.cfg

touch /var/log/nagios.log
chown nagios:nagios /var/log/nagios.log

sed -i -e "s/nagios@localhost/$email/"          /etc/nagios/nagios.cfg
sed -i -e "s/#check_workers=3/check_workers=2/" /etc/nagios/nagios.cfg
sed -i -e \
    "s/log_file=\/opt\/nagios\/var\/nagios.log/log_file=\/var\/log\/nagios.log/" \
    /etc/nagios/nagios.cfg

#-----------------------------------------------------------------------------

cd /usr/local/src/nagios-plugins-2.0.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --exec-prefix=/opt/nagios
make
make install

#-----------------------------------------------------------------------------

ex /etc/init.d/nagios << INIT_FILE
/### END INIT INFO/
i
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
.
wq
INIT_FILE

chmod +x /etc/init.d/nagios
update-rc.d -f nagios defaults
service nagios start
