# Integrated Software Engineering Stack

The following is the common integrated software engineering stack I use for my
own projects. The following are some of its components:

- Virtual Machine Automation ([Vagrant](http://vagrantup.com/))
- Configuration Management ([Ansible](https://www.ansible.com/))
- Security Components and Settings
- Containerization ([Docker](https://www.docker.com/))
- [PerlBrew](https://metacpan.org/pod/distribution/App-perlbrew/bin/perlbrew)
- local::lib and cpanfile
- Deployment State Management ([dest](https://metacpan.org/pod/App::Dest))

## Starting and Using

Install [Vagrant](http://vagrantup.com/) and
[VirtualBox](https://www.virtualbox.org). Then clone or copy this repository.
From the root of this repository, do the following:

    cd vagrant/configs/tauntaun # or select a different configuration from the "configs" directory
    vagrant up

This will run through the virtual machine build, installing
[Ansible](https://www.ansible.com/), and executing the appropriate
playbook/roles. As part of this, [Docker](https://www.docker.com/) will may be
installed, and then possibly some number of containers will be built.

### Auto-Generated Vagrantfiles

The `Vagrantfile`s located within the configuration directories
`~/vagrant/configs` are automatically generated via:

    ~/vagrant/build/build.pl

To make permanent changes to these `Vagrantfile`s, edit either:

- `~/vagrant/build/settings.yml`
- `~/vagrant/build/Vagrantfile.tt`

### Calling Ansible Directly

Assuming you've selected the "tauntaun" configuration, once the virtual machine
is built, you can rerun Ansible with the following:

    sudo su -l ansible
    cd /host/ansible
    PYTHONUNBUFFERED=1 ANSIBLE_CONFIG=ansible.cfg LOCAL_DIR=/host/local SRC_DIR=/host \
        ansible-playbook -l tauntaun -i inventories/all.ini playbooks/all.yml'

### Calling Docker Directly

Assuming you've selected the "tauntaun" configuration, you can manually build
Docker images with the following:

    sudo su -
    cd /host/docker/perl
    docker build -t perl:1.0 .

To run an image manually:

    docker run -it --name cperl perl:1.0 bash

To restart the container:

    docker start -ai cperl
