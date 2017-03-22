# Integrated Software Engineering Stack

The following is a rough, generic version of an integrated software engineering stack I use for projects, mostly in the Perl web services space. The following are some of its components:

- Virtual Machine Automation ([Vagrant](http://vagrantup.com/))
- Configuration Management ([Ansible](https://www.ansible.com/))
- Security Components and Settings
- Containerization ([Docker](https://www.docker.com/))
- [PerlBrew](https://metacpan.org/pod/distribution/App-perlbrew/bin/perlbrew)
- local::lib and cpanfile
- Deployment State Management ([dest](https://metacpan.org/pod/App::Dest))

## Experimental State

Everything herein is experimental and not well tested. Use at your own risk.

## Starting and Using

Install [Vagrant](http://vagrantup.com/) and [VirtualBox](https://www.virtualbox.org). Then clone or copy this repository. From the root of this repository, do the following:

    cd vagrant/configs/taunton # or select a different configuration from the "configs" directory
    vagrant up

This will run through the virtual machine build, installing [Ansible](https://www.ansible.com/), and executing the appropriate playbook/roles. As part of this, [Docker](https://www.docker.com/) will get installed, and then some number of containers will be built.

### Calling Ansible Directly

Assuming you've selected the "taunton" configuration, once the virtual machine is built, you can rerun Ansible with the following:

    sudo su -l ansible
    cd /host/ansible
    LOCAL_DIR=/host/local ansible-playbook -i inventories/taunton.ini playbooks/all.yml

### Calling Docker Directly

Assuming you've selected the "taunton" configuration, you can manually build Docker images with the following:

    sudo su -
    cd /host/docker/perl
    docker build -t perl:1.0 .

To run an image manually:

    docker run -it --name cperl perl:1.0 bash

To restart the container:

    docker start -ai cperl
