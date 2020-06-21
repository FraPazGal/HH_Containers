#!/bin/bash

cp humhub.conf /etc/apache2/sites-available
a2ensite humhub.conf
a2enmod rewrite

cd /tmp
wget https://www.humhub.com/de/download/package/humhub-1.4.3.tar.gz
tar xvfz humhub-1.4.3.tar.gz
mv /tmp/humhub-1.4.3 /var/www/humhub

chown -R www-data:www-data /var/www/humhub/
chmod -R 755 /var/www/humhub/

crontab -u www-data -l | { cat; echo "0 * * * * /usr/bin/php /var/www/humhub/protected/yii queue/run >/dev/null 2>&1"; } | crontab -u www-data -
crontab -u www-data -l | { cat; echo "0 * * * * /usr/bin/php /var/www/humhub/protected/yii cron/run >/dev/null 2>&1"; } | crontab -u www-data -
