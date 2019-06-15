#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "MariaDB 10.3 을 설치합니다."


yum_install MariaDB-server MariaDB-client MariaDB-common MariaDB-compat MariaDB-shared

# 메모리 선택 -> MariaDB 10.3 부터 미지원
#if [ ${1} = "4G" ]; then
#  if [ ! -f /etc/my.cnf.d/my-innodb-heavy-4G.cnf ]; then
#    notice "MariaDB 메모리 사용량이 4GB 로 최적화되었습니다.\n설정 파일 경로) /usr/share/mysql/my-innodb-heavy-4G.cnf"
#    cp -av /usr/share/mysql/my-innodb-heavy-4G.cnf /etc/my.cnf.d/
#  fi
#fi
#if [ ${1} = "2G" ]; then
#  if [ ! -f /etc/my.cnf.d/my-huge.cnf ]; then
#    notice "MariaDB 메모리 사용량이 2GB 로 최적화되었습니다.\n설정 파일 경로) /usr/share/mysql/my-huge.cnf"
#    cp -av /usr/share/mysql/my-huge.cnf /etc/my.cnf.d/
#  fi
#fi
#if [ ${1} = "512M" ]; then
#  if [ ! -f /etc/my.cnf.d/my-large.cnf ]; then
#    notice "MariaDB 메모리 사용량이 512MB 로 최적화되었습니다.\n설정 파일 경로) /usr/share/mysql/my-large.cnf"
#    cp -av /usr/share/mysql/my-large.cnf /etc/my.cnf.d/
#  fi
#fi

if [ ! -f /etc/my.cnf.d/z-php79.cnf ]; then
  notice "MariaDB 기본 캐릭터셋이 utf8mb4 로 지정되었습니다.\n설정 파일 경로) /etc/my.cnf.d/z-php79.cnf"
  cp -av "${STACK_ROOT}/mariadb/z-php79.cnf" /etc/my.cnf.d/
fi

if [ $OS = "centos7" ]; then
  systemctl enable mariadb
  systemctl start mariadb
else
  chkconfig mysql on
  service mysql start
fi

# secure installation
echo -e "\nn\n\n\n\n\n" | /usr/bin/mysql_secure_installation
