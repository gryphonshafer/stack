#!/usr/bin/env bash

# create "local" directory on host machine if it doesn't exist
if [ ! -d $LOCAL_DIR ]
then
    mkdir $LOCAL_DIR
fi

# create an RSA key in the "local" directory if the key doesn't exist already
if [ ! -f $LOCAL_DIR/ansible.id_rsa ]
then
    ssh-keygen -t rsa -f $LOCAL_DIR/ansible.id_rsa -P ''
fi

# quietly create an "ansible" user and add it to the "sudo" group
useradd -m ansible -s /bin/bash > /dev/null 2>&1
usermod -a -G sudo ansible

# set the ansible user's password to something random
echo ansible:`/usr/bin/openssl rand -base64 15` | chpasswd

# add the ansible user to the sudoers list
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/98_ansible

# setup the ansible user's ~/.ssh directory
mkdir /home/ansible/.ssh > /dev/null 2>&1

cp $LOCAL_DIR/ansible.id_rsa     /home/ansible/.ssh/id_rsa
cp $LOCAL_DIR/ansible.id_rsa.pub /home/ansible/.ssh/authorized_keys

chown -R ansible. /home/ansible/.ssh

chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/id_rsa
chmod 644 /home/ansible/.ssh/authorized_keys
