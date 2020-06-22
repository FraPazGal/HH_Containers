#!/bin/bash

cd /tmp
wget https://www.humhub.com/de/download/package/humhub-1.4.3.tar.gz
tar xvfz humhub-1.4.3.tar.gz
mv /tmp/humhub-1.4.3 /var/www/humhub

chown "$UID":"$GID" -R /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2
chmod -R 755 /var/www/humhub /etc/apache2 /etc/php/7.3/apache2 /var/lib/apache2 /usr/sbin/a2enmod /var/log/apache2 /var/run/apache2

crontab -u "$UID" -l | { cat; echo "0 * * * * /usr/bin/php /var/www/humhub/protected/yii queue/run >/dev/null 2>&1"; } | crontab -u "$UID" -
crontab -u "$UID" -l | { cat; echo "0 * * * * /usr/bin/php /var/www/humhub/protected/yii cron/run >/dev/null 2>&1"; } | crontab -u "$UID" -
