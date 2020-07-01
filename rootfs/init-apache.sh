#!bin/bash

config_file="/etc/apache2/sites-available/humhub.conf"

printf "Starting Apache configuration %s\n"

sed -i "s/max_execution_time =.*/max_execution_time = $APACHE_MAX_EXEC_TIME/g" /etc/php/7.3/apache2/php.ini
sed -i "s/post_max_size =.*/post_max_size = $APACHE_POST_MAX_SIZE/g" /etc/php/7.3/apache2/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = $APACHE_UPLOAD_MAX_FILESIZE/g" /etc/php/7.3/apache2/php.ini

if [[ ! -e "$config_file" ]]; then

   printf "Setting apache user %s\n"

   sed -i "s/APACHE_RUN_USER=.*/APACHE_RUN_USER=1001/g" /etc/apache2/envvars
   sed -i "s/APACHE_RUN_GROUP=.*/APACHE_RUN_GROUP=root/g" /etc/apache2/envvars

   printf "Setting humhub ports %s\n"

   sed -i "s/80/8081/" /etc/apache2/ports.conf
   sed -i "s/443/8443/" /etc/apache2/ports.conf

   echo "ServerName localhost" >> /etc/apache2/apache2.conf

fi

printf "Setting virtual hosts %s\n"
cp humhub.conf /etc/apache2/sites-available

if [ "$APACHE_HTTP_PORT_NUMBER" != "8080" ]; then

   sed -i "s/8080/$APACHE_HTTP_PORT_NUMBER/" /etc/apache2/sites-available/humhub.conf

fi

printf "Saving new configuration %s\n"
> /dev/null a2ensite humhub.conf
> /dev/null a2enmod rewrite

