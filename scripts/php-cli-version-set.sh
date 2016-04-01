#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "PHP CLI (/usr/bin/php) 를 PHP ${1} 버전으로 설정합니다."

if [ -z ${1} ]; then
  abort "설정할 PHP 버전을 입력하세요.  53 54 55 56 70"
fi

if [ ! -f "/usr/bin/php${1}" ]; then
  abort "설정할 PHP 버전이 설치되지 않았습니다.  /usr/bin/php${1}"
fi

if [ -f /usr/bin/php ]; then
    USR_BIN_PHP_VERSION=`/usr/bin/php -r 'echo PHP_VERSION;'`
    if [ $USR_BIN_PHP_VERSION = "5.3.3" ]; then
        mv -f /usr/bin/php /usr/bin/php53
    else
        mv -f /usr/bin/php /usr/bin/php.$USR_BIN_PHP_VERSION
    fi
fi
ln -sv "/usr/bin/php${1}" /usr/bin/php
