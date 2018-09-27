#!/bin/sh

_basedir="/y"
_outdir="$_basedir/Linode_Servers"

if [ ! -d $_basedir ]
then
    echo "Cannot access $_basedir"
    exit 1
fi

mkdir -p $_basedir/Linode_Servers

stty -echo
printf "Password: "
read _password
stty echo
printf "\n"

#-----------------------------------------------------------------------------

cd ~/rsyncs/ufda
echo 'archive: ufda root'
sudo tar -cf - etc root | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.etc-root.tar.aes.gz

echo 'archive: ufda home'
sudo tar -cf - home | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.home.tar.aes.gz

cd ~/rsyncs/ufda/var/spool/cron
echo 'archive: ufda crontabs'
sudo tar -cf - crontabs | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.crontabs.tar.aes.gz

cd ~/rsyncs/ufda/var
echo 'archive: ufda trac'
sudo tar -cf - trac | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.trac.tar.aes.gz

echo 'archive: ufda www'
sudo rm $_outdir/ufda.www.aes.gz.*
sudo tar -cf - www | openssl aes-256-cbc -a -k $_password | gzip | sudo split -d -b 1G - $_outdir/ufda.www.aes.gz.

cd ~/rsyncs/ufda/usr/local
echo 'archive: ufda hybserv'
sudo tar -cf - hybserv | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.hybserv.tar.aes.gz

cd ~/rsyncs/ufda/opt
echo 'archive: ufda gitlab'
sudo tar -cf - gitlab | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/ufda.gitlab.tar.aes.gz

#-----------------------------------------------------------------------------

cd ~/rsyncs/uber
echo 'archive: uber root'
sudo tar -cf - etc root | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.etc-root.tar.aes.gz

echo 'archive: uber home'
sudo tar -cf - home | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.home.tar.aes.gz

cd ~/rsyncs/uber/var/spool/cron
echo 'archive: uber crontabs'
sudo tar -cf - crontabs | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.crontabs.tar.aes.gz

cd ~/rsyncs/uber/var
echo 'archive: uber www'
sudo tar -cf - www | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.www.tar.aes.gz

echo 'archive: uber vmail'
sudo tar -cf - vmail | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.vmail.tar.aes.gz

cd ~/rsyncs/uber/var/lib
echo 'archive: uber mailman'
sudo tar -cf - mailman | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.mailman.tar.aes.gz

cd ~/rsyncs/uber/var/lib/amavis
echo 'archive: uber spamassassin'
sudo tar -cf - .spamassassin | openssl aes-256-cbc -a -k $_password | gzip > $_outdir/uber.spamassassin.tar.aes.gz
