#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

# PHP 8 차이점 - php80-php-pecl-mysql 패키지 없음

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "PHP [${1}] 버전을 설치합니다."

if [ -z ${1} ]; then
  abort "설치할 PHP 버전을 입력하세요.  80, 81, 82, 83"
fi

yum_install php$1-php-cli php$1-php-fpm \
php$1-php-common php$1-php-pdo php$1-php-mysqlnd php$1-php-mbstring php$1-php-mcrypt \
php$1-php-opcache php$1-php-xml php$1-php-pecl-imagick php$1-php-gd php$1-php-fileinfo \
php$1-php-pecl-zip php$1-php-bcmath

if [ ! -f "/etc/opt/remi/php${1}/php.d/z-php79.ini" ]; then
  notice "PHP 권장 설정이 추가되었습니다.\n설정 파일 경로) /etc/opt/remi/php${1}/php.d/z-php79.ini"
  cp -av "${STACK_ROOT}/php/80/z-php79.ini" "/etc/opt/remi/php${1}/php.d/"
  string_quote ${TIMEZONE}
  sed -i "s/^date.timezone =.*/date.timezone = ${STRING_QUOTE}/g" "/etc/opt/remi/php${1}/php.d/z-php79.ini"
fi

PHP_FPM_CONF=/etc/opt/remi/php$1/php-fpm.d/www.conf
sed -i 's/^user = apache/user = nobody/g' $PHP_FPM_CONF
sed -i 's/^group = apache/group = nobody/g' $PHP_FPM_CONF

if [ "$OS" = "rocky8" ]; then
  sed -i 's/^;security.limit_extensions = .php .php3 .php4 .php5 .php7/security.limit_extensions = .php .html .htm .inc/g' $PHP_FPM_CONF
  sed -i 's/^listen = \/var\/opt\/remi\/php'$1'\/run\/php-fpm\/www.sock/listen = 127.0.0.1:90'$1'/g' $PHP_FPM_CONF
else
  sed -i 's/^;security.limit_extensions = .php .php3 .php4 .php5/security.limit_extensions = .php .html .htm .inc/g' $PHP_FPM_CONF
  sed -i 's/^listen = 127.0.0.1:9000/listen = 127.0.0.1:90'$1'/g' $PHP_FPM_CONF
fi

chgrp -v nobody /var/opt/remi/php$1/lib/php/*
chown -v nobody /var/opt/remi/php$1/log/php-fpm

if [ "$SYSTEMCTL" = "1" ]; then
  systemctl enable php$1-php-fpm
  systemctl start php$1-php-fpm
else
  chkconfig php$1-php-fpm on
  service php$1-php-fpm start
fi

# nginx 설치된 경우만 복사
if [ -f /etc/nginx/conf.d/0-php79.conf ]; then
  if [ ! -f "/etc/nginx/conf.d/1-fastcgi-php${1}.conf" ]; then
    cp -av "${STACK_ROOT}/nginx/1-fastcgi-php${1}.conf" /etc/nginx/conf.d/
  fi
fi
