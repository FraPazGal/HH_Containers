FROM docker.io/bitnami/minideb:latest

LABEL author="Fran"
LABEL version="1.0"

ARG UID=1001
ARG GID=1001

COPY prebuildfs /

# Install required system packages and dependencies
RUN install_packages ca-certificates gzip libaudit1 libbsd0 libbz2-1.0 libc6 libcap-ng0 libcom-err2 libcurl4 libexpat1 libffi6 libfftw3-double3 libfontconfig1 libfreetype6 libgcc1 libgcrypt20 libglib2.0-0 libgmp10 libgnutls30 libgomp1 libgpg-error0 libgssapi-krb5-2 libhogweed4 libicu63 libidn2-0 libjemalloc2 libjpeg62-turbo libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 liblcms2-2 libldap-2.4-2 liblqr-1-0 libltdl7 liblzma5 libmagickcore-6.q16-6 libmagickwand-6.q16-6 libmcrypt4 libmemcached11 libmemcachedutil2 libncurses6 libnettle6 libnghttp2-14 libonig5 libp11-kit0 libpam0g libpcre3 libpng16-16 libpq5 libpsl5 libreadline7 librtmp1 libsasl2-2 libsqlite3-0 libssh2-1 libssl1.1 libstdc++6 libsybdb5 libtasn1-6 libtidy5deb1 libtinfo6 libunistring2 libuuid1 libx11-6 libxau6 libxcb1 libxdmcp6 libxext6 libxml2 libxslt1.1 libzip4 procps sudo tar unzip zlib1g
RUN install_packages cron nano wget apache2 php php-cli php-imagick php-curl php-bz2 php-gd php-intl php-mysql php-zip php-apcu-bc php-apcu php-xml php-ldap -y
RUN groupadd -g $GID $GID \
    && useradd -s /bin/bash -g $GID -u $UID $UID
RUN /download-install-humhub.sh 

COPY rootfs /

ENV USER_UID="$UID" \
    USER_GID="$GID" \
    APACHE_HTTP_PORT_NUMBER="8080" \
    APACHE_MAX_EXEC_TIME="300" \
    APACHE_POST_MAX_FILESIZE="64M" \
    APACHE_UPLOAD_MAX_FILESIZE="64M" \
    HH_MARIADB_HOST="172.18.0.10" \
    HH_MARIADB_DBNAME="humhub_db" \
    HH_MARIADB_USER="nami" \
    HH_MARIADB_USER_PASS="janna" \
    HH_SITE_NAME="HumHub Site Name" \
    HH_SITE_EMAIL="gumhub@example.com" \
    HH_SITE_BASEURL="http://www.example.net" \
    HH_ADMIN_USERNAME="morgana" \
    HH_ADMIN_EMAIL="morgana@example.com" \
    HH_ADMIN_PASS="leona" \
    HH_ADMIN_FIRSTNAME="Morgana" \
    HH_ADMIN_LASTNAME="The Fallen" \
    HH_GUEST_ACCESS="YES" \
    HH_APPROVAL_AFTER_REGISTRATION="NO" \
    HH_ANON_REGISTRATION="YES" \
    HH_INVITE_BY_EMAIL="NO" \
    HH_FRIENSHIP_MODULE="YES" \
    HH_SAMPLE_DATA="YES"

EXPOSE 8080

USER $UID
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2ctl", "-f", "/etc/apache2/apache2.conf", "-DFOREGROUND" ]
