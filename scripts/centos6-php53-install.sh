#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "PHP 5.3 버전을 설치합니다."

if [ $OS = "centos7" ]; then
  abort "CentOS 7 에서는 PHP 5.3 설치를 지원하지 않습니다."
fi

yum_install php-cli php-fpm \
php-common php-pdo php-mysql php-mbstring php-mcrypt \
php-opcache php-xml php-pecl-imagick php-gd php-fileinfo

if [ ! -f "/etc/php.d/z-php79.ini" ]; then
  notice "PHP 권장 설정이 추가되었습니다.\n설정 파일 경로) /etc/php.d/z-php79.ini"
  cp -av "${STACK_ROOT}/php/53/z-php79.ini" /etc/php.d/
  string_quote ${TIMEZONE}
  sed -i "s/^date.timezone =.*/date.timezone = ${STRING_QUOTE}/g" /etc/php.d/z-php79.ini
fi

PHP_FPM_CONF=/etc/php-fpm.d/www.conf
sed -i 's/^;security.limit_extensions = .php .php3 .php4 .php5/security.limit_extensions = .php .html .htm .inc/g' $PHP_FPM_CONF
sed -i 's/^user = apache/user = nobody/g' $PHP_FPM_CONF
sed -i 's/^group = apache/group = nobody/g' $PHP_FPM_CONF
sed -i 's/^listen = 127.0.0.1:9000/listen = 127.0.0.1:9053/g' $PHP_FPM_CONF

if [ ! -d /var/lib/php/session ]; then
    mkdir /var/lib/php/session
fi
chown nobody.nobody /var/lib/php /var/lib/php/session

chkconfig php-fpm on
service php-fpm start


# nginx 설치된 경우만 복사
if [ -f /etc/nginx/conf.d/0-php79.conf ]; then
  if [ ! -f "/etc/nginx/conf.d/1-fastcgi-php53.conf" ]; then
    cp -av "${STACK_ROOT}/nginx/1-fastcgi-php53.conf" /etc/nginx/conf.d/
  fi
fi

# #9 ioncube 설치를 위해 php53 경로가 필요하고, /usr/bin/php 는 php-cli-version-set.sh 에 의해 링크로만 존재하도록 함
mv -f /usr/bin/php /usr/bin/php53 \
&& ln -s /usr/bin/php53 /usr/bin/php
