#!/usr/bin/env bash
################################################################################
# Name        : WordPress - Debian 11 (Apache) installer
# Date        : 15/12/2021
# Version     : 1.0
# Author      : Caner KORKUT
################################################################################

db_user=#
db_pass=#

echo Veuillez entrer le FQDN du projet : 
read FQDN

FQDN_SANITIZED="$(echo "$FQDN" | sed 's/[^A-Za-z0-9]/_/g' | sed 's/__*/_/g')"

sudo mkdir /var/www/$FQDN_SANITIZED
sudo wget https://wordpress.org/latest.tar.gz -O /var/www/$FQDN_SANITIZED/latest.tar.gz
sudo tar xfz /var/www/$FQDN_SANITIZED/latest.tar.gz --directory /var/www/$FQDN_SANITIZED
sudo mv /var/www/$FQDN_SANITIZED/wordpress/* /var/www/$FQDN_SANITIZED/
sudo rm -rf /var/www/$FQDN_SANITIZED/wordpress
sudo chown -R www-data:www-data /var/www/$FQDN_SANITIZED
sudo chmod 644 -R /var/www/$FQDN_SANITIZED/
sudo chmod 755 -R /var/www/$FQDN_SANITIZED
sudo chmod 775 -R /var/www/$FQDN_SANITIZED/wp-content


sudo bash -c "cat >> /etc/apache2/sites-available/$FQDN_SANITIZED.conf <<'EOL'

<VirtualHost *:80>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.

	ServerName $FQDN
	ServerAlias www.$FQDN
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/$FQDN_SANITIZED/

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error_$FQDN_SANITIZED.log
	CustomLog \${APACHE_LOG_DIR}/access_$FQDN_SANITIZED.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with 'a2disconf'.
	#Include conf-available/serve-cgi-bin.conf
</VirtualHost>

EOL"

echo "CREATE DATABASE $FQDN_SANITIZED;" > database_conf.sql
mysql -u root --password="$db_pass" --connect-expired-password < database_conf.sql
rm -rf database_conf.sql

sudo sed -i "s/database_name_here/$FQDN_SANITIZED/g" /var/www/$FQDN_SANITIZED/wp-config-sample.php
sudo sed -i "s/username_here/$db_user/g" /var/www/$FQDN_SANITIZED/wp-config-sample.php
sudo sed -i "s/password_here/$db_pass/g" /var/www/$FQDN_SANITIZED/wp-config-sample.php

sudo cp /var/www/$FQDN_SANITIZED/wp-config-sample.php /var/www/$FQDN_SANITIZED/wp-config.php

sudo a2ensite $FQDN_SANITIZED.conf

sudo systemctl reload apache2

