# Post-Vagrant-Provisioning Tasks

## Install VirtualBox Guest Additions

- Select the appropriate virtual machine instance
- Click: "Show", "Devices", "Upgrade Guest Additions..."
- Close the window and when prompted select "Continue running in the background"

## Full Upgrade

- `sudo apt -y update`
- `sudo apt -y full-upgrade`
- `ls -r /boot/initrd.* | head -1 | sed 's/.*img/linux-headers/' | xargs apt -y install`
- `apt -y autoremove`
