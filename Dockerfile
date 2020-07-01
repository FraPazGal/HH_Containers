FROM docker.io/bitnami/minideb:latest

LABEL author="FraPazGal"
LABEL version="1.4.3-r1"

ARG HUMHUB_VERSION=1.4.3

COPY prebuildfs /

# Install required system packages and dependencies
RUN install_packages ca-certificates tar cron wget apache2 php php-cli php-imagick php-curl php-bz2 php-gd php-intl php-mysql php-zip php-apcu-bc php-apcu php-xml php-ldap
RUN useradd -g root -u 1001 1001
RUN /download-humhub.sh 

COPY rootfs /

ENV USER_UID="$UID" \
    USER_GID="$GID" \
    APACHE_HTTP_PORT_NUMBER="8080" \
    APACHE_MAX_EXEC_TIME="300" \
    APACHE_POST_MAX_FILESIZE="64M" \
    APACHE_UPLOAD_MAX_FILESIZE="64M" \
    HH_MARIADB_HOST="mariadb" \
    HH_MARIADB_DBNAME="humhub_db" \
    HH_MARIADB_USER="nami" \
    HH_MARIADB_USER_PASS="janna" \
    HH_SITE_NAME="HumHub Site Name" \
    HH_SITE_EMAIL="humhub@example.com" \
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

USER 1001
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2ctl", "-f", "/etc/apache2/apache2.conf", "-DFOREGROUND" ]
