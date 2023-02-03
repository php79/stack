#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short

# 설치 여부 확인
PHP_INSTALLED=$(ls -1 /usr/bin/php?? /usr/bin/php 2> /dev/null)
NGINX_INSTALLED=$(ls -1 /usr/sbin/nginx 2> /dev/null)
MARIADB_INSTALLED=$(ls -1 /usr/bin/mariadb /usr/bin/mysql 2> /dev/null)

# 주요 설정 파일
title "php79 stack 에서 추가된 주요 설정 파일들"

if [ ! -z "$PHP_INSTALLED" ]; then
  outputInfo "- php.ini\n"
  find /etc/php.d /etc/opt/remi/php*/php.d /opt/remi/php*/root/etc/php.d /usr/local/php53/etc/php.d -name '*php79.ini' 2> /dev/null|sort
fi

if [ ! -z "$NGINX_INSTALLED" ]; then
  outputInfo "- nginx\n"
  find /etc/nginx/conf.d/ -name '*php79.conf' 2> /dev/null
fi

if [ ! -z "$MARIADB_INSTALLED" ]; then
  outputInfo "- MariaDB\n"
  find /etc/my.cnf.d -name '*php79.cnf' 2> /dev/null
fi

echo

if [[ ! -z "$PHP_INSTALLED" || ! -z "$MARIADB_INSTALLED" ]]; then
  outputInfo "  * php.d/z-php79.ini, my.cnf.d/z-php79.cnf 파일들은 파일 이름순 정렬로 마지막에 로딩됩니다."
  echo
  outputInfo "  * php.ini 와 php.d/z-php79.ini 2개에 같은 설정이 있다면, 마지막에 로드된 php.d/z-php79.ini 설정이 적용됩니다."
  echo
  outputInfo "  * 따라서 설정 변경시엔 php.ini 대신, php.d/z-php79.ini 파일을 수정해야 합니다."
  echo
fi

if [ ! -z "$PHP_INSTALLED" ]; then
  # 설치된 php 정보 표시
  title "설치된 PHP 버전 정보"
  echo -ne "CLI path     \tVersion\t\tService name\n"
  LAST_SERVICE_NAME=
  for PHP_CLI in $(ls -1 /usr/bin/php?? /usr/bin/php)
  do
    echo -n "${PHP_CLI}"
    echo -ne "\t"
    PHP_VERSION=$(${PHP_CLI} -r "echo PHP_VERSION;")
    PHP_VERSION_SHORT=$(${PHP_CLI} -r "echo PHP_MAJOR_VERSION . PHP_MINOR_VERSION;")
    echo -ne "${PHP_VERSION}\t\t"
    if [ ${PHP_VERSION_SHORT} = '53' ]; then
      if [ ${OS} = 'centos7' ]; then
        LAST_SERVICE_NAME="php53-php-fpm"
      else
        LAST_SERVICE_NAME="php-fpm"
      fi
    else
      LAST_SERVICE_NAME="php${PHP_VERSION_SHORT}-php-fpm"
    fi
    echo ${LAST_SERVICE_NAME}
  done
  echo

  if [ ! -z ${LAST_SERVICE_NAME} ]; then
    if [ "$SYSTEMCTL" = "1" ]; then
      outputInfo "  * PHP FPM 재시작 명령: systemctl restart ${LAST_SERVICE_NAME}"
    else
      outputInfo "  * PHP FPM 재시작 명령: service ${LAST_SERVICE_NAME} restart"
    fi
    echo
  fi

  # FPM port
  title "실행중인 PHP FPM port"
  netstat -nlpt|grep -P "PID|php"|sort
fi

# nginx
if [ ! -z "$NGINX_INSTALLED" ]; then
  title "실행중인 Nginx port 및 응답 여부"
  netstat -nlpt|grep -P "PID|nginx"
  echo

  echo "curl http://127.0.0.1 -> "
  curl -sI http://127.0.0.1|grep "OK"
  curl -s http://127.0.0.1|grep -i "<title>"|head -n1
  echo

  if [ ! -z ${LAST_SERVICE_NAME} ]; then
    if [ "$SYSTEMCTL" = "1" ]; then
      outputInfo "  * Nginx 재시작 명령: systemctl restart nginx"
    else
      outputInfo "  * Nginx 재시작 명령: service nginx restart"
    fi
    echo
  fi
fi


# mariadb
if [ ! -z "$MARIADB_INSTALLED" ]; then
  title "실행중인 MariaDB port 및 응답 여부"
  netstat -nlpt|grep -P "PID|mysqld|mariadbd"
  echo

  echo -n "mysqladmin ping -> "
  mysqladmin ping
  echo

  if [ ! -z ${LAST_SERVICE_NAME} ]; then
    if [ "$SYSTEMCTL" = "1" ]; then
      outputInfo "  * MariaDB 재시작 명령: systemctl restart mariadb"
    else
      outputInfo "  * MariaDB 재시작 명령: service mysql restart"
    fi
    echo
  fi
fi
