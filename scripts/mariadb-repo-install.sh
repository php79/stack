#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "MariaDB 저장소를 설치합니다."


# http://yum.mariadb.org/ 에서 공식 저장소 패키지가 없으므로, 수동 설치합니다.
# 공식 저장소에 미러 리스트가 없으므로 MariaDB.repo 에서 한국 미러 주소로 고정되어 있습니다.
if [ ! -f /etc/yum.repos.d/MariaDB.repo ]; then
  if [ $OS = "rocky8" ]; then
    # https://mariadb.com/kb/en/mariadb-package-repository-setup-and-usage/
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.6"
  elif [ $OS = "centos7" ]; then
    cp -av "${STACK_ROOT}/mariadb/centos7/MariaDB.repo" /etc/yum.repos.d/
  else
    cp -av "${STACK_ROOT}/mariadb/centos6/MariaDB.repo" /etc/yum.repos.d/
  fi
fi

if [ ! -f /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ]; then
  cp -av "${STACK_ROOT}/mariadb/RPM-GPG-KEY-MariaDB" /etc/pki/rpm-gpg/
fi
