#!/bin/sh

_basedir="/y"
_outdir="$_basedir/Linode"

if [ ! -d $_basedir ]
then
    echo "Cannot access $_basedir"
    exit 1
fi

mkdir -p $_basedir/Linode

# stty -echo
# printf "Password: "
# read _password
# stty echo
# printf "\n"

# ... | openssl aes-256-cbc -a -k $_password | gzip ...

#-----------------------------------------------------------------------------

cd ~/rsyncs/ufda
echo 'archive: ufda root'
sudo tar -cf - etc root | gzip > $_outdir/ufda.etc-root.tar.gz

echo 'archive: ufda home'
sudo tar -cf - home | gzip > $_outdir/ufda.home.tar.gz

cd ~/rsyncs/ufda/var/spool/cron
echo 'archive: ufda crontabs'
sudo tar -cf - crontabs | gzip > $_outdir/ufda.crontabs.tar.gz

cd ~/rsyncs/ufda/var
echo 'archive: ufda trac'
sudo tar -cf - trac | gzip > $_outdir/ufda.trac.tar.gz

echo 'archive: ufda www'
sudo rm $_outdir/ufda.www.gz.*
sudo tar -cf - www | gzip | sudo split -d -b 1G - $_outdir/ufda.www.gz.

cd ~/rsyncs/ufda/usr/local
echo 'archive: ufda hybserv'
sudo tar -cf - hybserv | gzip > $_outdir/ufda.hybserv.tar.gz

cd ~/rsyncs/ufda/opt
echo 'archive: ufda gitlab'
sudo tar -cf - gitlab | gzip > $_outdir/ufda.gitlab.tar.gz

#-----------------------------------------------------------------------------

cd ~/rsyncs/uber
echo 'archive: uber root'
sudo tar -cf - etc root | gzip > $_outdir/uber.etc-root.tar.gz

echo 'archive: uber home'
sudo tar -cf - home | gzip > $_outdir/uber.home.tar.gz

cd ~/rsyncs/uber/var/spool/cron
echo 'archive: uber crontabs'
sudo tar -cf - crontabs | gzip > $_outdir/uber.crontabs.tar.gz

cd ~/rsyncs/uber/var
echo 'archive: uber www'
sudo tar -cf - www | gzip > $_outdir/uber.www.tar.gz

echo 'archive: uber vmail'
sudo tar -cf - vmail | gzip > $_outdir/uber.vmail.tar.gz

cd ~/rsyncs/uber/var/lib
echo 'archive: uber mailman'
sudo tar -cf - mailman | gzip > $_outdir/uber.mailman.tar.gz

cd ~/rsyncs/uber/var/lib/amavis
echo 'archive: uber spamassassin'
sudo tar -cf - .spamassassin | gzip > $_outdir/uber.spamassassin.tar.gz
