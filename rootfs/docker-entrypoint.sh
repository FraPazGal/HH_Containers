#!/bin/bash

if [ "$1" = 'apache2ctl' ]; then
	sleep 5
	. /init-apache.sh
	. /init-humhub.sh
fi

exec "$@"
