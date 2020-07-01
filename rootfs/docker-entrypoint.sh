#!/bin/bash

if [ "$1" = 'apache2ctl' ]; then

	printf "Waiting for db setup %s\n"
	php -f /checkDB.php "$HH_MARIADB_HOST" "$HH_MARIADB_USER" "$HH_MARIADB_USER_PASS" "$HH_MARIADB_DBNAME"

	printf "Starting Humhub setup %s\n"
	. /init-apache.sh
	. /init-humhub.sh
	printf "HumHub has been deployed, have fun! %s\n"
fi

exec "$@"
