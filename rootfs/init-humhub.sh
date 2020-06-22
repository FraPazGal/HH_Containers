#!bin/bash

rm /var/www/humhub/protected/humhub/modules/installer/commands/InstallController.php 

cp InstallController.php /var/www/humhub/protected/humhub/commands

cd /var/www/humhub/protected
php yii install/write-db-config "$HH_MARIADB_HOST" "$HH_MARIADB_DBNAME" "$HH_MARIADB_USER" "$HH_MARIADB_USER_PASS"
php yii install/install-db

php yii install/set-base-url "$HH_SITE_BASEURL"

php yii install/write-site-config "$HH_SITE_NAME" "$HH_SITE_EMAIL" "$HH_GUEST_ACCESS" "$HH_APPROVAL_AFTER_REGISTRATION" "$HH_ANON_REGISTRATION" "$HH_INVITE_BY_EMAIL" "$HH_FRIENSHIP_MODULE"

php yii install/create-admin-account "$HH_ADMIN_USERNAME" "$HH_ADMIN_EMAIL" "$HH_ADMIN_PASS" "$HH_ADMIN_FIRSTNAME" "$HH_ADMIN_LASTNAME" "$HH_SAMPLE_DATA"

php yii install/set-base-url "$HH_SITE_BASEURL"

chown -R "$USER_UID":"$USER_GID" /var/www/humhub/
chmod -R 755 /var/www/humhub/
