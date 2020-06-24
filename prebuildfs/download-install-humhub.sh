#!/bin/bash

cd /tmp
wget -nv https://www.humhub.com/de/download/package/humhub-1.4.3.tar.gz
tar xfz humhub-1.4.3.tar.gz
mkdir /var/www/humhub

chown "$UID":"$GID" -R /tmp/humhub-1.4.3 /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2
chmod -R 755 /tmp/humhub-1.4.3 /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2


