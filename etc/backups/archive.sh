#!/bin/sh

# MAILTO=...
# 15 3 * * * { $HOME/backups/rsync.sh; $HOME/backups/archive.sh; } 2>&1 | mail -s 'Daily Backup' $MAILTO

_rsyncs="$HOME/backups/rsyncs"
_archives="$HOME/backups/archives"

mkdir -p $_archives

#-----------------------------------------------------------------------------

cd $_rsyncs/www
echo 'archive: www root'
sudo tar -cf - etc root | gzip > $_archives/www.etc-root.tar.gz

echo 'archive: www home'
sudo tar -cf - home | gzip > $_archives/www.home.tar.gz

cd $_rsyncs/www/var/spool/cron
echo 'archive: www crontabs'
sudo tar -cf - crontabs | gzip > $_archives/www.crontabs.tar.gz

cd $_rsyncs/www/var
echo 'archive: www trac'
sudo tar -cf - trac | gzip > $_archives/www.trac.tar.gz

echo 'archive: www www'
sudo rm -f $_archives/www.www.gz.*
sudo tar -cf - www | gzip | sudo split -d -b 1G - $_archives/www.www.gz.

cd $_rsyncs/www/opt/docker
echo 'archive: www docker-mysql'
sudo tar -cf - mysql | gzip > $_archives/www.mysql.tar.gz

#-----------------------------------------------------------------------------

cd $_rsyncs/mail
echo 'archive: mail root'
sudo tar -cf - etc root | gzip > $_archives/mail.etc-root.tar.gz

echo 'archive: mail home'
sudo tar -cf - home | gzip > $_archives/mail.home.tar.gz

cd $_rsyncs/mail/var/spool/cron
echo 'archive: mail crontabs'
sudo tar -cf - crontabs | gzip > $_archives/mail.crontabs.tar.gz

cd $_rsyncs/mail/var
echo 'archive: mail vmail'
sudo tar -cf - vmail | gzip > $_archives/mail.vmail.tar.gz

cd $_rsyncs/mail/var/lib
echo 'archive: mail mailman'
sudo tar -cf - mailman | gzip > $_archives/mail.mailman.tar.gz

cd $_rsyncs/mail/var/lib/amavis
echo 'archive: mail spamassassin'
sudo tar -cf - .spamassassin | gzip > $_archives/mail.spamassassin.tar.gz

#-----------------------------------------------------------------------------

cd $_rsyncs/git/opt
echo 'archive: git gitlab'
sudo tar -cf - gitlab | gzip > $_archives/git.gitlab.tar.gz
