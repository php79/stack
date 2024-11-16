#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

PHP_VERSION=${1}

title "PHP [${PHP_VERSION}] 버전을 설치합니다."

if [ -z ${PHP_VERSION} ]; then
  if [ "$OS" = "rocky8" ]; then
    abort "설치할 PHP 버전을 입력하세요.  56"
  else
    abort "설치할 PHP 버전을 입력하세요.  54, 55, 56"
  fi
fi

# stack.conf 에서 선언한 PHP 모듈 배열
PHP_MODULES=(${PHP_MODULES_54})

# PHP 버전별 모듈명 완성  ex) php-pdo -> php80-php-pdo
MERGE_PHP_MODULES=""
for i in "${PHP_MODULES[@]}"
do
  MERGE_PHP_MODULES="${MERGE_PHP_MODULES} php${PHP_VERSION}-${i}"
done

yum_install php$1-php-cli \
php$1-php-fpm \
php$1-php-common \
${MERGE_PHP_MODULES}

if [ "$OS" = "rocky8" ]; then
  if [ ! -f "/etc/opt/remi/php${PHP_VERSION}/php.d/z-php79.ini" ]; then
    notice "PHP 권장 설정이 추가되었습니다.\n설정 파일 경로) /etc/opt/remi/php${PHP_VERSION}/php.d/z-php79.ini"
    cp -av "${STACK_ROOT}/php/70/z-php79.ini" "/etc/opt/remi/php${PHP_VERSION}/php.d/"
    string_quote ${TIMEZONE}
    sed -i "s/^date.timezone =.*/date.timezone = ${STRING_QUOTE}/g" "/etc/opt/remi/php${PHP_VERSION}/php.d/z-php79.ini"
  fi

  PHP_FPM_CONF=/etc/opt/remi/php$1/php-fpm.d/www.conf
  sed -i 's/^;security.limit_extensions = .php .php3 .php4 .php5/security.limit_extensions = .php .html .htm .inc/g' $PHP_FPM_CONF
  sed -i 's/^user = apache/user = nobody/g' $PHP_FPM_CONF
  sed -i 's/^group = apache/group = nobody/g' $PHP_FPM_CONF
#  sed -i 's/^listen = 127.0.0.1:9000/listen = 127.0.0.1:90'$1'/g' $PHP_FPM_CONF
  sed -i 's/^listen = \/var\/opt\/remi\/php'$1'\/run\/php-fpm\/www.sock/listen = 127.0.0.1:90'$1'/g' $PHP_FPM_CONF

  chgrp -c nobody /var/opt/remi/php$1/lib/php/*
  chown -c nobody /var/opt/remi/php$1/log/php-fpm
else
  if [ ! -f "/opt/remi/php${PHP_VERSION}/root/etc/php.d/z-php79.ini" ]; then
    notice "PHP 권장 설정이 추가되었습니다.\n설정 파일 경로) /opt/remi/php${PHP_VERSION}/root/etc/php.d/z-php79.ini"
    cp -av "${STACK_ROOT}/php/70/z-php79.ini" "/opt/remi/php${PHP_VERSION}/root/etc/php.d/"
    string_quote ${TIMEZONE}
    sed -i "s/^date.timezone =.*/date.timezone = ${STRING_QUOTE}/g" "/opt/remi/php${PHP_VERSION}/root/etc/php.d/z-php79.ini"
  fi

  PHP_FPM_CONF=/opt/remi/php$1/root/etc/php-fpm.d/www.conf
  sed -i 's/^;security.limit_extensions = .php .php3 .php4 .php5/security.limit_extensions = .php .html .htm .inc/g' $PHP_FPM_CONF
  sed -i 's/^user = apache/user = nobody/g' $PHP_FPM_CONF
  sed -i 's/^group = apache/group = nobody/g' $PHP_FPM_CONF
  sed -i 's/^listen = 127.0.0.1:9000/listen = 127.0.0.1:90'$1'/g' $PHP_FPM_CONF

  chgrp -c nobody /opt/remi/php$1/root/var/lib/php/*
  chown -c nobody /opt/remi/php$1/root/var/log/php-fpm
fi

if [ "$SYSTEMCTL" = "1" ]; then
  systemctl enable php$1-php-fpm
  systemctl start php$1-php-fpm
else
  chkconfig php$1-php-fpm on
  service php$1-php-fpm start
fi

# nginx 설치된 경우만 복사
if [ -f /etc/nginx/conf.d/0-php79.conf ]; then
  if [ ! -f "/etc/nginx/conf.d/1-fastcgi-php${PHP_VERSION}.conf" ]; then
    cp -av "${STACK_ROOT}/nginx/1-fastcgi-php${PHP_VERSION}.conf" /etc/nginx/conf.d/
  fi
fi
