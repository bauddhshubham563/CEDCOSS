# !bin/sh

# Author : Shubham_2221
# Copyright (c) Cedcoss Solution Pvt Ltd
# This Script will install LAMP(Apache) Stack and Wordpress

sudo su
	apt-get update && apt-get upgrade
	apt-get install apache2
	systemctl start apache2
	apt-get install mysql-server
	systemctl start mysql
	apt-get install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
	systemctl restart apache2
	apt install phpmyadmin
cd /tmp/
read DOMAIN
mkdir /var/www/html/${DOMAIN}/
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
mv wordpress/* /var/www/html/${DOMAIN}
chown -R www-data:www-data /var/www/html/${DOMAIN}
chmod -R 755 /var/www/html/${DOMAIN}
if [ -f /root/.my.cnf ]; then
	echo "Enter database name for wordpress : "
	read DB
	mysql -e "CREATE DATABASE ${db};"
	echo "Enter Username for wordpress : "
	read UN
	echo "Enter Password for wordpress database : "
	read PWD
	mysql -e "CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY '${PWD}';"
	mysql -e "GRANT ALL PRIVILEGES ON ${DB}.* TO ‘${UN}'@'%';"
	mysql -e "FLUSH PRIVILEGES;"
else
	echo "Enter your root password : "
	read -sp RPWD
	echo " Enter database name for wordpress : "
	read DB
	mysql -uroot -p${RPWD} -e "CREATE DATABASE ${db};"
	echo "Enter Username for wordpress : "
	read UN
	echo "Enter Password for wordpress database : "
	read PWD
	mysql -uroot -p${RPWD} -e "CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY '${PWD}';"
	mysql -uroot -p${RPWD} -e "GRANT ALL PRIVILEGES ON ${DB}.* TO '${UN}'@'%';"
	mysql -uroot -p${RPWD} -e "FLUSH PRIVILEGES;"
fi
cd /var/www/html/${DOMAIN}
mv wp-config-sample.php wp-config.php
xdg-open http://localhost/${DOMAIN}/

