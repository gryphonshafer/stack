rm /etc/sudoers.d/99_vagrant
rm -rf /var/log/vboxadd-*
deluser --remove-home --remove-all-files vagrant
sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /etc/ssh/sshd_config
sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /etc/network/interfaces
rmdir /vagrant

/opt/VBoxGuestAdditions-*/uninstall.sh

rm /root/de_vagrant.bash
