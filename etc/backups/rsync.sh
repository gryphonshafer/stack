#!/bin/sh

_rsyncs="$HOME/backups/rsyncs"
_ssh_env="ssh -p 22 -l $USER -i $HOME/.ssh/id_rsa"
_settings="-chazvP -e \"$_ssh_env\" --rsync-path=\"sudo rsync\" --delete"

_pull_backup()
{
    mkdir -p $_rsyncs/$_server$_component_dir
    eval sudo rsync $_settings $_server:$_component_dir/ $_rsyncs/$_server$_component_dir
}

#-----------------------------------------------------------------------------

_server="www"

for _component_dir in \
    /etc \
    /root \
    /home \
    /var/spool/cron/crontabs \
    /var/trac \
    /var/www \
    /opt/docker/mysql/data
do
    _pull_backup
done

#-----------------------------------------------------------------------------

_server="mail"

for _component_dir in \
    /etc \
    /root \
    /home \
    /var/spool/cron/crontabs \
    /var/vmail \
    /var/lib/mailman \
    /var/lib/amavis/.spamassassin
do
    _pull_backup
done

#-----------------------------------------------------------------------------

_server="git"

for _component_dir in \
    /opt/gitlab
do
    _pull_backup
done
