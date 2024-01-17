# !bin/sh/

# Author : Shubham_2221
# Copyright (c) : Cedcoss Technology Private Limited
# This script will install LEMP Stack (Nginx) with Wordpress

sudo
	apt-get update -y
	apt-get install nginx -y
	ufw allow 'Nginx HTTP'
	ufw allow 'Nginx HTTPS'
	ufw allow 'Nginx Full'
	ufw enable
	ufw status
	sleep 2
	echo "Enter New Root Password"
	read root_password
	apt install mysql-server -y
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$root_password';"
	apt install php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
	echo "Enter a Domain"
	read $DOMAIN
	mkdir /var/www/html/$DOMAIN
	sudo chown -R $USER:$USER /var/www/html/$DOMAIN
	sudo nano /etc/nginx/sites-available/$DOMAIN
cat << EOF >> /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root /var/www/html/$DOMAIN;

    index index.html index.htm index.php;

    location / {
        #try_files $uri $uri/ =404;
	try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt { log_not_found off; access_log off; allow all; }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }

}
EOF
	ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
	apt install phpmyadmin
	echo "Enter Wordpress Database Name : "
	read wp_database
	echo "Enter Wordpress User Name : "
	read wp_user
	echo "Enter Wordpress $wp_user Password"
	read wp_password
	mysql -u root -p$root_password -e "CREATE DATABASE $wp_database DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
	mysql -u root -p$root_password -e "CREATE USER '$wp_user'@'localhost' IDENTIFIED BY '$wp_password';"
	mysql -u root -p$root_password -e "GRANT ALL ON $wp_database.* TO '$wp_user'@'localhost';"
	mysql -u root -p$root_password -e "FLUSH PRIVILEGES;"

	cd /tmp
	curl -LO https://wordpress.org/latest.tar.gz
	tar xzvf latest.tar.gz
	cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
	cp -a /tmp/wordpress/. /var/www/html/$DOMAIN
        sed -i 's/database_name_here/$wp_database/g' /var/www/html/$DOMAIN/wp-config.php>
        sed -i 's/username_here/$wp_user/g' /var/www/html/$DOMAIN/wp-config.php
        sed -i 's/password_here/$wp_password/g' /var/www/html/$DOMAIN/wp-config.php>


	systemctl reload nginx
	systemctl restart php7.4-fpm
	nginx -t
	xdg-open http://localhost/$DOMAIN
exit
