#!/bin/bash

if [ "$1" = 'apache2ctl' ]; then

	printf "Waiting for db setup %s\n"
	sleep 6.5
	printf "Starting Humhub setup %s\n"
	. /init-apache.sh
	. /init-humhub.sh
	printf "Starting Humhub %s\n"
fi

exec "$@"
