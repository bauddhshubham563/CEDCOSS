# !bin/sh/

# Author : Shubham_2221
# Copyright (c) : Cedcoss Technology Private Limited
# This script will install LAMP Stack (Apache 2.4, php 8.1, mysql 8.0, phpmyadmin) Magento2.4.5, Elastic Search 7.17 Composer 2.2.18

sudo
	echo 'Updating'
	sleep 2
	apt update -y
	echo 'Installing Apache2'
	sleep 2
	apt install apache2 -y
	mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
	touch apache2.conf
cat << EOF >> /etc/apache2/apache2.conf
DefaultRuntimeDir ${APACHE_RUN_DIR}
PidFile ${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}
HostnameLookups Off
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf
Include ports.conf
<Directory />
        Options FollowSymLinks
        AllowOverride None
        Require all denied
</Directory>
<Directory /usr/share>
        AllowOverride None
        Require all granted
</Directory>
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
</Directory>
AccessFileName .htaccess
<FilesMatch "^\.ht">
        Require all denied
</FilesMatch>
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" >
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combin>
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf
EOF
	sleep 2
	systemctl start apache2
	echo 'Enable apache Mods'
	sleep 2
	apt install libapache2-mod-security2
	a2enmod security2 deflate rewrite headers expires ssl
	systemctl restart apache2
	echo 'Open Browser and goto http://localhost/'
	echo 'Adding php repository'
	sleep 2
	apt-get install software-properties-common -y
	add-apt-repository ppa:ondrej/php
	apt-get update -y
	echo 'Installing PHP'
	sleep 2
	apt install php8.1 php8.1-{amqp,inotify,rrd,apcu,interbase,smbclient,ast,int,snmp,bcmath,ldap,soap,bz2,mailparse,solr,cgi,maxmindb,sqlite3,cli,mbstring,ssh2,commom,mcrypt,stomp,curl,memcache,swoole,dba,memcached,sybase,decimal,tideways,dev,msgpack,tidy,ds,mysql,uopz,enchant,oauth,uploadprogress,facedetect,odbc,uuid,opcache,vips,gd,pcov,xdebug,gearman,pgsql,xhprof,gmagick,phpdbg,xml,gmp,protobuf,xmlrpc,gnupg,ps,xsl,grpc,pspell,yac,http,psr,yaml,igbinary,raphf,zip,imagick,readline,zmq,imap,redis,zstd} -y
	echo 'check php'
	touch /var/www/html/info.php
cat << EOF  >> /var/www/html/info.php
<?php
	phpinfo();
?>
EOF
	echo 'goto url http://localhost/info.php'
	sleep 2
	echo 'Install MySQL Server'
	sleep 2
	apt install mysql-server -y
	systemctl start mysql.service
	echo 'Set MySQL root password : '
	sleep 2
	read root_password
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$root_password';"
	mysql -e "exit;"
	echo 'Installing phpMyAdmin'
	sleep 2
	apt install phpmyadmin -y
	cd /tmp/
	echo 'Downloading Elastic Search'
	sleep 2
	wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-amd64.deb
	chmod +x elasticsearch-7.17.0-amd64.deb
	dpkg -i elasticsearch-7.17.0-amd64.deb -y
	echo 'Downloading Composer'
	sleep 2
	wget https://getcomposer.org/download/2.2.18/composer.phar
	mv composer.php composer
	mv composer /usr/local/bin
	cd /usr/local/bin
	chmod -R 777 composer
	composer -v
	echo 'Downloading Magento2.4.5'
        sleep 2
	wget https://github.com/magento/magento2/archive/refs/tags/2.4.5.tar.gz
	tar -xvf 2.4.5.tar.gz
	mv magento2-2.4.5 magento2
	mv magento /var/www/html/
	cd /var/www/html/magento2
	Composer install
	echo 'Setting up Permissions'
	find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
	find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
	chown -R www-data:www-data .
	chmod u+x bin/magento
	echo 'Create Magento database user password admin_user admin_password admin_firstname admin_secondname'
	echo 'Enter Base Url - your_IP_or_Domain : '
	read baseurl
	echo 'Enter Magento DataBase Name : '
	read dbname
	echo 'Enter Magento User Name : '
	read dbuser
	echo 'Enter $dbuser Password : '
	read dbpasswd
	echo 'Enter Admin First Name : '
	read fadmin
	echo 'Enter Admin Last Name : '
	read ladmin
	echo 'Enter Admin Email : '
	read eadmin
	echo 'Enter Admin UserName : '
	read uadmin
	echo 'Enter Admin Password : '
	read padmin
	mysql -u root -p{$root_password} -e "create database $dbname;"
	mysql -u root -p{$root_password} -e "create user '$dbuser'@'localhost' identified with mysql_native_password by '$dbpassword';"
	mysql -u root -p{$root_password} -e "grant all privileges to $dbname.* on '$dbuser'@'localhost' with grant option;"
	mysql -u root -p{$root_password} -e "flush privileges;"
	echo 'Now Installing Magento2'
	bin/magento setup:install --base-url=http://$baseurl --db-host=localhost --db-name=$dbname --db-user=$dbuser --db-password=$dbpasswd --admin-firstname=$fadmin --admin-lastname=$ladmin --admin-email=$eadmin --admin-user=$uadmin --admin-password=$padmin --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1
	echo 'Copy above Admin url /admin_123xyz'
	sleep 5
	php bin/magento indexer:reindex
	php bin/magento setup:static-content:deploy -f
	php bin/magento cache:flush
exit
