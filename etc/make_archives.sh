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

cd ~/rsyncs/mail
echo 'archive: mail root'
sudo tar -cf - etc root | gzip > $_outdir/mail.etc-root.tar.gz

echo 'archive: mail home'
sudo tar -cf - home | gzip > $_outdir/mail.home.tar.gz

cd ~/rsyncs/mail/var/spool/cron
echo 'archive: mail crontabs'
sudo tar -cf - crontabs | gzip > $_outdir/mail.crontabs.tar.gz

cd ~/rsyncs/mail/var
echo 'archive: mail vmail'
sudo tar -cf - vmail | gzip > $_outdir/mail.vmail.tar.gz

cd ~/rsyncs/mail/var/lib
echo 'archive: mail mailman'
sudo tar -cf - mailman | gzip > $_outdir/mail.mailman.tar.gz

cd ~/rsyncs/mail/var/lib/amavis
echo 'archive: mail spamassassin'
sudo tar -cf - .spamassassin | gzip > $_outdir/mail.spamassassin.tar.gz

#-----------------------------------------------------------------------------

cd ~/rsyncs/git/opt
echo 'archive: git gitlab'
sudo tar -cf - gitlab | gzip > $_outdir/git.gitlab.tar.gz
