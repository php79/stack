#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "MariaDB 저장소를 설치합니다."


# 2023.11.23 CentOS 7 에서도 MariaDB 버전 선택 가능하도록 변경
if [ "$OS" = "rocky8" ]; then
  # https://mariadb.com/kb/en/mariadb-package-repository-setup-and-usage/
  curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | \
  sudo bash -s -- --mariadb-server-version="mariadb-${MARIADB_VERSION}"
elif [ "$OS" = "centos7" ]; then
  # 2024-11-16, CentOS 7 에서 MaxScale 저장소 오류가 있어 제외
  curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | \
  sudo bash -s -- --mariadb-server-version="mariadb-${MARIADB_VERSION}" --skip-maxscale
else
  # http://yum.mariadb.org/ 에서 공식 저장소 패키지가 없던 시기에 수동 설치 방법이지만, 하위 호환성 유지하여 기존 방법 유지
  if [ ! -f /etc/yum.repos.d/MariaDB.repo ]; then
#    if [ $OS = "centos7" ]; then
#      cp -av "${STACK_ROOT}/mariadb/centos7/MariaDB.repo" /etc/yum.repos.d/
#    else
      cp -av "${STACK_ROOT}/mariadb/centos6/MariaDB.repo" /etc/yum.repos.d/
#    fi
  fi

  # 2023-02-11, KEY 변경.  https://github.com/php79/stack/issues/96
  if [ ! -f /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ]; then
    rpmkeys --import https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY
    curl -LsS -o /etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY
  fi
fi
