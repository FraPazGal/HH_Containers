sed -i 's/max_execution_time = 30/max_execution_time = ${APACHE_MAX_EXEC_TIME}/g' /etc/php/7.3/apache2/php.ini
sed -i 's/post_max_size = 8M/post_max_size = ${APACHE_POST_MAX_SIZE}/g' /etc/php/7.3/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = ${APACHE_UPLOAD_MAX_FILESIZE}/g' /etc/php/7.3/apache2/php.ini

service apache2 restart
