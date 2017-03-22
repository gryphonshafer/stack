#!/usr/bin/env bash

user_username="dev"
user_password="password"
root_password="password"

apt-get install mysql-server mysql-client

echo "GRANT ALL ON *.* TO '$user_username'@'%' WITH GRANT OPTION" | mysql -u root
echo "UPDATE user SET password = PASSWORD('$user_password') WHERE User = '$user_username'" | mysql -u root -D mysql
echo "UPDATE user SET password = PASSWORD('$root_password') WHERE User = 'root'" | mysql -u root -D mysql
echo "FLUSH PRIVILEGES" | mysql -u root

cat <<MYCNF > /home/$user_username/.my.cnf
[client]
user=$user_username
password="$user_password"
MYCNF

chown $user_username.$user_username /home/$user_username/.my.cnf
chmod 600 /home/$user_username/.my.cnf
