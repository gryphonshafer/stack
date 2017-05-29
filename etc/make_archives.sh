#!/bin/sh

_flags="cfpz"
_basedir="/y"
_outdir="$_basedir/tgzs"

if [ ! -d $_basedir ]
then
    echo "Cannot access $_basedir"
    exit 1
fi

mkdir -p $_basedir/tgzs

#-----------------------------------------------------------------------------

cd ~/rsyncs/ufda
echo 'archive: ufda root'
sudo tar $_flags $_outdir/ufda.etc-root.tgz etc root

echo 'archive: ufda home'
sudo tar $_flags $_outdir/ufda.home.tgz home

cd ~/rsyncs/ufda/var/spool/cron
echo 'archive: ufda crontabs'
sudo tar $_flags $_outdir/ufda.crontabs.tgz crontabs

cd ~/rsyncs/ufda/var
echo 'archive: ufda trac'
sudo tar $_flags $_outdir/ufda.trac.tgz trac
echo 'archive: ufda www'
sudo tar $_flags - www | sudo split -d -b 1G - $_outdir/ufda.www.tgz.

cd ~/rsyncs/ufda/usr/local
echo 'archive: ufda hybserv'
sudo tar $_flags $_outdir/ufda.hybserv.tgz hybserv

cd ~/rsyncs/ufda/opt
echo 'archive: ufda gitlab'
sudo tar $_flags $_outdir/ufda.gitlab.tgz gitlab

#-----------------------------------------------------------------------------

cd ~/rsyncs/uber
echo 'archive: uber root'
sudo tar $_flags $_outdir/uber.etc-root.tgz etc root
echo 'archive: uber home'
sudo tar $_flags $_outdir/uber.home.tgz home

cd ~/rsyncs/uber/var/spool/cron
echo 'archive: uber crontabs'
sudo tar $_flags $_outdir/uber.crontabs.tgz crontabs

cd ~/rsyncs/uber/var
echo 'archive: uber www'
sudo tar $_flags $_outdir/uber.www.tgz www
echo 'archive: uber vmail'
sudo tar $_flags $_outdir/uber.vmail.tgz vmail

cd ~/rsyncs/uber/var/lib
echo 'archive: uber mailman'
sudo tar $_flags $_outdir/uber.mailman.tgz mailman

cd ~/rsyncs/uber/var/lib/amavis
echo 'archive: uber spamassassin'
sudo tar $_flags $_outdir/uber._spamassassin.tgz .spamassassin
