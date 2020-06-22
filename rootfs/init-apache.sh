#!bin/bash

sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=$USER_UID/g" /etc/apache2/envvars
sed -i "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=$USER_GID/g" /etc/apache2/envvars

sed -i "s/max_execution_time = 30/max_execution_time = $APACHE_MAX_EXEC_TIME/g" /etc/php/7.3/apache2/php.ini
sed -i "s/post_max_size = 8M/post_max_size = $APACHE_POST_MAX_SIZE/g" /etc/php/7.3/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = $APACHE_UPLOAD_MAX_FILESIZE/g" /etc/php/7.3/apache2/php.ini

cp humhub.conf /etc/apache2/sites-available

sed -i "s/80/8081/" /etc/apache2/ports.conf
sed -i "s/443/8443/" /etc/apache2/ports.conf

echo "ServerName localhost" >> /etc/apache2/apache2.conf

if [ "$APACHE_HTTP_PORT_NUMBER" != "8080" ]; then

sed -i "s/8080/$APACHE_HTTP_PORT_NUMBER/" /etc/apache2/sites-available/humhub.conf

fi

a2ensite humhub.conf
a2enmod rewrite

service apache2 restart
