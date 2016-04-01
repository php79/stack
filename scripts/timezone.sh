#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "Time Zone 을 [${1}]로 설정합니다."

if [ -z ${1} ]; then
  abort "변경할 타임존을 입력하세요."
fi

if [ -f "/usr/share/zoneinfo/${1}" ]; then
  if [ $OS = "centos7" ]; then
    timedatectl set-timezone "${1}"
  else
    ln -sf /usr/share/zoneinfo/${1} /etc/localtime
  fi
else
    abort "Error) Time zone not found - ${1}"
fi




