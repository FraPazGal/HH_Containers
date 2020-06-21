#!/bin/bash

if [ "$1" = 'humhub' ]; then

	. /init-apache.sh
	. /init-humhub.sh
fi

exec "/bin/bash"
