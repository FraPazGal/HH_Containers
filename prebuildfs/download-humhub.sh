#!/bin/bash

cd /tmp || exit
wget -O humhub.tar.gz -nv https://www.humhub.com/de/download/package/humhub-"$HUMHUB_VERSION".tar.gz
tar xfz humhub.tar.gz && rm humhub.tar.gz
mv /tmp/humhub-"$HUMHUB_VERSION" /tmp/humhub
mkdir /var/www/humhub

chown 1001:root -R /tmp/humhub /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2
chmod -R 755 /tmp/humhub /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2


