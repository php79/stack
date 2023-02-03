#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "yum 업데이트, EPEL 저장소 설치, 시간 자동 동기화를 진행합니다."

yum makecache
yum -y --exclude=kernel* update

if [ "$OS" = "rocky8" ]; then
  # glibc-gconv-extra 미설치시 iconv 모듈에서 EUC-KR 등 한글 인코딩 미지원 오류 발생
  yum_install epel-release yum-utils chrony glibc-gconv-extra

  systemctl enable --now chronyd

  chronyc -a makestep
else
  yum_install epel-release yum-utils ntp

  if [ "$SYSTEMCTL" = "1" ]; then
    systemctl enable ntpd
    systemctl start ntpd
  else
    chkconfig ntpd on
    service ntpd start
  fi

  ntpdate -u kr.pool.ntp.org 0.centos.pool.ntp.org pool.ntp.org

  if [ ${?} != "0" ]; then
    outputError "Warning) 시간 자동 동기화가 실패하였습니다.\n  ntpdate -u kr.pool.ntp.org 0.centos.pool.ntp.org pool.ntp.org"
    exit 0  # 실패시에도 설치 계속 진행
  fi
fi
