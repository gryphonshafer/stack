#!/bin/sh

_outdir="/d/Backups/Linode"

# stty -echo
# printf "Password: "
# read _password
# stty echo
# printf "\n"

# ... | openssl aes-256-cbc -a -k $_password | gzip ...

#-----------------------------------------------------------------------------

cd ~/rsyncs/www
echo 'archive: www root'
sudo tar -cf - etc root | gzip > $_outdir/www.etc-root.tar.gz

echo 'archive: www home'
sudo tar -cf - home | gzip > $_outdir/www.home.tar.gz

cd ~/rsyncs/www/var/spool/cron
echo 'archive: www crontabs'
sudo tar -cf - crontabs | gzip > $_outdir/www.crontabs.tar.gz

cd ~/rsyncs/www/var
echo 'archive: www trac'
sudo tar -cf - trac | gzip > $_outdir/www.trac.tar.gz

echo 'archive: www www'
sudo rm $_outdir/www.www.gz.*
sudo tar -cf - www | gzip | sudo split -d -b 1G - $_outdir/www.www.gz.

cd ~/rsyncs/www/opt/docker
echo 'archive: www docker-mysql'
sudo tar -cf - mysql | gzip > $_outdir/www.mysql.tar.gz

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

#-----------------------------------------------------------------------------

cd ~/rsyncs/git/opt
echo 'archive: git gitlab'
sudo tar -cf - gitlab | gzip > $_outdir/git.gitlab.tar.gz
