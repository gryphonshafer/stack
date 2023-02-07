#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive apt-get -yq install python3 python3-pip python3-setuptools

pip3 install -q ansible passlib

# append to local /etc/hosts
if ! grep -q "^# Appended automatically from host-based local hosts file" /etc/hosts
then
    echo -e "\n# Appended automatically from host-based local hosts file" >> /etc/hosts
    cat $HOSTS >> /etc/hosts
fi

# setup "known_hosts" file for ansible user
grep -v '^#' $HOSTS | cut -d' ' -f2 | xargs \
    ssh-keyscan -t ssh-rsa > /home/ansible/.ssh/known_hosts 2> /dev/null

cp $LOCAL_DIR/ansible.id_rsa /home/ansible/.ssh/id_rsa
chmod 600 /home/ansible/.ssh/id_rsa
chown -R ansible. /home/ansible/.ssh
