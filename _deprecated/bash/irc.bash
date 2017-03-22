#!/usr/bin/env bash

encrypted_passwd=$( /usr/bin/mkpasswd $irc_passwd )

#-----------------------------------------------------------------------------

# for additional information about IRC server installation, see:
# http://eosrei.net/articles/2013/03/irc-server-ircd-hybrid-and-hybserv-ubuntu-1204lts
# http://marvelserv.com/setting-up-ircd-hybrid-and-hybserv-services-with-ssl-on-ubuntu/

apt-get install debhelper dpatch docbook-to-man flex bison libpcre3-dev libgeoip-dev dh-autoreconf

mkdir /tmp/hybrid
cd /tmp/hybrid

$aptget source ircd-hybrid

ex ./ircd-hybrid-*/debian/rules <<CONF_FILE
/MAXCLIENTS = /
i
USE_OPENSSL = 1
.
wq
CONF_FILE

cd ircd-hybrid-*
dpkg-buildpackage -rfakeroot -uc -b

cd ../
dpkg -i ircd-hybrid_*.deb

cd /tmp
rm -rf /tmp/hybrid

for i in \
    "s/hybrid7.debian.local/$irc_domain/g" \
    "s/description = \"ircd-hybrid 7.2-debian\"/description = \"$irc_domain IRC Server\"/" \
    "s/network_name = \"debian\"/network_name = \"$irc_domain\"/" \
    "s/network_desc = \"i am a network short and stout\"/network_desc = \"$irc_domain IRC Network\"/" \
    "s/name = \"S. Ysadmin\"/name = \"Gryphon Shafer\"/" \
    "s/email = \"<root@localhost>\"/email = \"<gryphon@$irc_domain>\"/" \
    "s/host = \"127.0.0.1\"/#host = \"127.0.0.1\"/" \
    "s/password = \"ToJx.IEPqjiVg\"/password = \"$encrypted_passwd\"/" \
    "s/name = \"root\";/name = \"gryphon\";/" \
    "s/user = \"root@127.0.0.1\";/user = \"*@*\";/" \
    "s/password = \"mk0f0t\/gi7zYA\"/password = \"$encrypted_passwd\"/"
do
    sed -i -e "$i" /etc/ircd-hybrid/ircd.conf
done

ex /etc/ircd-hybrid/ircd.conf <<CONF_FILE
/\/* shared {}:/
i
connect {
    name = "irc.$irc_domain";
    host = "127.0.0.1";

    send_password = "$encrypted_passwd";
    accept_password = "$encrypted_passwd";

    compressed = no;
    hub_mask = "*";
    class = "server";
};

.
wq
CONF_FILE

echo -e "Welcome to the private $irc_domain IRC Server\n(EVERYTHING IS LOGGED FOREVER, kthxbye)" \
    > /etc/ircd-hybrid/ircd.motd

invoke-rc.d ircd-hybrid restart

#-----------------------------------------------------------------------------

chsh -s /bin/sh irc

#-----------------------------------------------------------------------------

# for additional information about IRC services installation, see:
# https://github.com/dkorunic/hybserv2/blob/master/INSTALL
# http://eosrei.net/articles/2013/03/irc-server-ircd-hybrid-and-hybserv-ubuntu-1204lts

cd /tmp
git clone https://github.com/dkorunic/hybserv2.git
cd hybserv2
git checkout tags/$( /usr/bin/git tag -l | /bin/grep '^REL' | /usr/bin/sort | /usr/bin/tail -1 )
./configure
make install

cd /usr/local/hybserv
rm -rf /tmp/hybserv2
touch /usr/local/hybserv/hybserv.pid
chown -R irc:irc .

for i in \
    "s/A:SideWnder <wnder@underworld.net>/A:Gryphon Shafer <gryphon@$irc_domain>/" \
    "s/N:services.hybnet.com:Hybrid services/N:irc.$irc_domain:Hybrid IRC Services/" \
    "s/S:/#:/g" \
    "s/#:Services:irc.anotherhub.net:/S:$encrypted_passwd:127.0.0.1:6667/" \
    "s/O:/#:/g" \
    "s/#:oper@oper.com:Oper:OperGuy:ogj/O:*@*:$encrypted_passwd:gryphon:afseogj/"
do
    sed -i -e "$i" /usr/local/hybserv/hybserv.conf
done

for i in \
    "s/NickNameExpire     \"4w\"/NickNameExpire     \"52w\"/" \
    "s/ChannelExpire      \"4w\"/ChannelExpire      \"52w\"/" \
    "s/BanExpire         \"3h\"/BanExpire         \"52w\"/" \
    "s/MinChanUsers       10/MinChanUsers       1/"
do
    sed -i -e "$i" /usr/local/hybserv/settings.conf
done

cat <<\SCRIPT_FILE > /etc/init.d/hybserv
#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          hybserv
# Required-Start:    ircd-hybrid
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: IRC Services
# Description:       IRC services for the local IRC server
### END INIT INFO

case "$1" in
    start)
        /bin/su irc -c /usr/local/hybserv/hybserv
        ;;
    stop|force-stop)
        /bin/kill `/bin/cat /usr/local/hybserv/hybserv.pid`
        ;;
    restart|reload|force-reload)
        /bin/kill `/bin/cat /usr/local/hybserv/hybserv.pid`
        /bin/su irc -c /usr/local/hybserv/hybserv
        ;;
esac
SCRIPT_FILE

chmod u+x /etc/init.d/hybserv
update-rc.d -f hybserv defaults
service hybserv start
service hybserv restart

#-----------------------------------------------------------------------------

if [ -f /etc/shorewall/rules ]
then

cat <<\RULES_FILE >> /etc/shorewall/rules

# irc
ACCEPT net $FW tcp 6665,6666,6667,6668,6669,6670
RULES_FILE

service shorewall restart

fi
