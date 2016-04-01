#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "서버 필수 유틸과 점검툴들을 설치합니다."

PACKAGES="rsync wget openssh-clients bind-utils git \
telnet nc vim-enhanced man ntsysv \
htop glances iotop iftop sysstat strace lsof \
mc lrzsz zip unzip bzip2"
if [ $OS = "centos7" ]; then
    PACKAGES="$PACKAGES net-tools"
fi
yum_install $PACKAGES
