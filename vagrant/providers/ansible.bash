#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install build-essential libssl-dev libffi-dev python-dev

# install pip
wget -q https://bootstrap.pypa.io/get-pip.py
python ./get-pip.py -q
rm ./get-pip.py
apt-get -q -y install python-pip

# update pip with pip
pip install --upgrade setuptools pip

# install latest Ansible stable version
pip install ansible --upgrade

# append to local /etc/hosts
if ! grep -q "^# Appended automatically from host-based local hosts file" /etc/hosts
then
    echo -e "\n# Appended automatically from host-based local hosts file" >> /etc/hosts
    cat $HOSTS >> /etc/hosts
fi

# setup "known_hosts" file for ansible user
grep -v '^#' $HOSTS | cut -d' ' -f2 | xargs \
    ssh-keyscan -t ssh-rsa > /home/ansible/.ssh/known_hosts 2> /dev/null

chown ansible. /home/ansible/.ssh/known_hosts

cp $LOCAL_DIR/ansible.id_rsa /home/ansible/.ssh/id_rsa
chmod 600 /home/ansible/.ssh/id_rsa
