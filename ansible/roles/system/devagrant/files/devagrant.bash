rm /etc/sudoers.d/99_vagrant
rm -rf \
    /var/log/vboxadd-install.log \
    /var/log/vboxadd-install-x11.log \
    /var/log/VBoxGuestAdditions.log \
    /var/log/VBoxGuestAdditions-uninstall.log
sed -i '/vagrant/d' /etc/aliases
newaliases
deluser --remove-home --remove-all-files vagrant
sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /etc/ssh/sshd_config
sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /etc/network/interfaces
invoke-rc.d networking stop
invoke-rc.d networking start
rmdir /vagrant

/opt/VBoxGuestAdditions-*/uninstall.sh

rm /root/devagrant.bash
