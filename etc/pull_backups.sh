#!/bin/sh

_home="/home/gryphon"

_e="ssh -p 22 -l gryphon -i $_home/.ssh/id_rsa"
_settings="-chazvP -e \"$_e\" --rsync-path=\"sudo rsync\" --delete"

#-----------------------------------------------------------------------------

_this_home="$_home/rsyncs/www"

for _dir in \
    /etc \
    /root \
    /home \
    /var/spool/cron/crontabs \
    /var/trac \
    /var/www \
    /opt/docker/mysql/data
do
    mkdir -p $_this_home$_dir
    eval sudo rsync $_settings www:$_dir/ $_this_home$_dir
done

#-----------------------------------------------------------------------------

_this_home="$_home/rsyncs/mail"

for _dir in \
    /etc \
    /root \
    /home \
    /var/spool/cron/crontabs \
    /var/vmail \
    /var/lib/mailman \
    /var/lib/amavis/.spamassassin
do
    mkdir -p $_this_home$_dir
    eval sudo rsync $_settings mail:$_dir/ $_this_home$_dir
done

#-----------------------------------------------------------------------------

_this_home="$_home/rsyncs/git"

for _dir in \
    /opt/gitlab
do
    mkdir -p $_this_home$_dir
    eval sudo rsync $_settings git:$_dir/ $_this_home$_dir
done
