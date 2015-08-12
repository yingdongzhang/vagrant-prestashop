#!/usr/bin/env bash

## Change the following settings you'd like to use
PS_VERSION=prestashop_1.6.0.8.zip
TIMEZONE=Europe/London
## For complete supported Timezones list, visit: http://php.net/manual/en/timezones.php

## Setup and basic tools
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y unzip

# Install Apache & PHP
# --------------------
apt-get install git
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysqlnd php5-curl php5-xdebug php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-soap

php5enmod mcrypt

# Install zip
# --------------------
sudo apt-get install zip

# remove this package as it causes lots of php warning when using php on the cli
# sudo apt-get remove php5-snmp

# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
rm -rf /var/www/html
mkdir /var/www/html

mkdir -p /vagrant/httpdocs/prestashop-with-sample-data
ln -fs /vagrant/httpdocs/prestashop-with-sample-data /var/www/html/prestashop-with-sample-data

mkdir -p /vagrant/httpdocs/prestashop-without-sample-data
ln -fs /vagrant/httpdocs/prestashop-without-sample-data /var/www/html/prestashop-without-sample-data

# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
NameVirtualHost *:8080
Listen 8080
<VirtualHost *:80>
  DocumentRoot "/var/www/html/prestashop-with-sample-data"
  ServerName localhost
  <Directory "/var/www/html/prestashop-with-sample-data">
    AllowOverride All
  </Directory>
</VirtualHost>
<VirtualHost *:8080>
  DocumentRoot "/var/www/html/prestashop-with-sample-data"
  ServerName localhost
  <Directory "/var/www/html/prestashop-with-sample-data">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "$VHOST" > /etc/apache2/sites-enabled/000-default.conf


VHOST2=$(cat <<EOF
NameVirtualHost *:8081
Listen 8081
<VirtualHost *:8081>
  DocumentRoot "/var/www/html/prestashop-without-sample-data"
  ServerName localhost
  <Directory "/var/www/html/prestashop-without-sample-data">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "$VHOST2" > /etc/apache2/sites-available/001-default.conf
ln -s /etc/apache2/sites-available/001-default.conf /etc/apache2/sites-enabled/001-default.conf

a2enmod rewrite

## Turn on php error displaying
sudo sed -i s/'display_errors = Off'/'display_errors = On'/g /etc/php5/apache2/php.ini
sudo sed -i s/'display_startup_errors = Off'/'display_startup_errors = On'/g /etc/php5/apache2/php.ini

## Restart Apache to get config changes
service apache2 restart

# Mysql
# --------------------
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
apt-get -q -y install mysql-server-5.5

## Create a database
mysql -u root -e 'CREATE DATABASE IF NOT EXISTS prestashop_with_data'
mysql -u root -e 'CREATE DATABASE IF NOT EXISTS prestashop_without_data'

## phpMyAdmin
sudo apt-get install -y phpmyadmin
sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo service apache2 reload

## Download Prestashop
cd /vagrant/httpdocs
wget http://www.prestashop.com/download/old/$PS_VERSION
unzip -o $PS_VERSION
sudo rm ./$PS_VERSION

## PrestaShop with sample data
cp -r /vagrant/httpdocs/prestashop/* /vagrant/httpdocs/prestashop-with-sample-data/
## If you don't do this, PrestaShop will rename the admin folder with a suffix of 4 random  digit numbers
mv /vagrant/httpdocs/prestashop-with-sample-data/admin /vagrant/httpdocs/prestashop-with-sample-data/admin1234

## Install Prestashop
php /vagrant/httpdocs/prestashop-with-sample-data/install/index_cli.php --timezone=$TIMEZONE --domain=localhost:8080 --db_name=prestashop_with_data --db_user=root --password=password --email=admin@myshop.com --newsletter=0
## Remove installation folder
rm -rf /vagrant/httpdocs/prestashop-with-sample-data/install

## Turn off cache and turn on Template Force Compilation
mysql -uroot prestashop_with_data < /vagrant/provisioning-data/prestashop-config-changes.sql

## Turn on dev mode in PrestaShop
sudo sed -i s/'define('"'"'_PS_MODE_DEV_'"'"', false);'/'define('"'"'_PS_MODE_DEV_'"'"', true);'/g /vagrant/httpdocs/prestashop-with-sample-data/config/defines.inc.php

## PrestaShop without sample data
cp -r /vagrant/httpdocs/prestashop/* /vagrant/httpdocs/prestashop-without-sample-data/
## If you don't do this, PrestaShop will rename the admin folder with a suffix of 4 random  digit numbers
mv /vagrant/httpdocs/prestashop-without-sample-data/admin /vagrant/httpdocs/prestashop-without-sample-data/admin1234

## Install Prestashop
php /vagrant/httpdocs/prestashop-without-sample-data/install/index_cli.php --timezone=$TIMEZONE --domain=localhost:8081 --db_name=prestashop_without_data --db_user=root --password=password --email=admin@myshop.com --newsletter=0
## Remove installation folder
rm -rf /vagrant/httpdocs/prestashop-without-sample-data/install

## Turn off cache and turn on Template Force Compilation
mysql -uroot prestashop_without_data < /vagrant/provisioning-data/prestashop-config-changes.sql

## Turn on dev mode in PrestaShop
sudo sed -i s/'define('"'"'_PS_MODE_DEV_'"'"', false);'/'define('"'"'_PS_MODE_DEV_'"'"', true);'/g /vagrant/httpdocs/prestashop-without-sample-data/config/defines.inc.php

## Delete sample data
mysql -uroot prestashop_without_data < /vagrant/provisioning-data/delete-sample-data.sql

rm -rf /vagrant/httpdocs/prestashop-without-sample-data/img/c/*
rm -rf /vagrant/httpdocs/prestashop-without-sample-data/img/p/*
rm -rf /vagrant/httpdocs/prestashop-without-sample-data/img/m/*
rm -rf /vagrant/httpdocs/prestashop-without-sample-data/img/su/*

rm -rf /vagrant/httpdocs/prestashop