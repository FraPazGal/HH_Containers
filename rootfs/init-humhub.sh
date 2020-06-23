#!bin/bash

installation_file="/var/www/humhub/protected/humhub/modules/installer/commands/InstallController.php"

if [[ -e "$installation_file" ]]; then

   printf "Starting Humhub configuration %s\n"
   rm /var/www/humhub/protected/humhub/modules/installer/commands/InstallController.php 
   cp InstallController.php /var/www/humhub/protected/humhub/commands
   cd /var/www/humhub/protected

   printf "Setting database connection %s\n"
   php yii install/write-db-config "$HH_MARIADB_HOST" "$HH_MARIADB_DBNAME" "$HH_MARIADB_USER" "$HH_MARIADB_USER_PASS" > /dev/null   
   php yii install/install-db > /dev/null

   printf "Setting site config %s\n"
   php yii install/set-base-url "$HH_SITE_BASEURL" > /dev/null
   php yii install/write-site-config "$HH_SITE_NAME" "$HH_SITE_EMAIL" "$HH_GUEST_ACCESS" "$HH_APPROVAL_AFTER_REGISTRATION" "$HH_ANON_REGISTRATION" "$HH_INVITE_BY_EMAIL" "$HH_FRIENSHIP_MODULE" > /dev/null

   if [[ "$HH_SAMPLE_DATA" =~ ^(YES|Yes|yes|Y|y)$ ]]; then
      printf "Creating admin account and sample data %s\n"
   else
      printf "Creating admin account %s\n"
   fi
   php yii install/create-admin-account "$HH_ADMIN_USERNAME" "$HH_ADMIN_EMAIL" "$HH_ADMIN_PASS" "$HH_ADMIN_FIRSTNAME" "$HH_ADMIN_LASTNAME" "$HH_SAMPLE_DATA" > /dev/null
   php yii install/set-base-url "$HH_SITE_BASEURL" > /dev/null

else

   printf "Humhub already configured %s\n"

fi

chown -R "$USER_UID":"$USER_GID" /var/www/humhub/
chmod -R 755 /var/www/humhub/
