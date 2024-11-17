#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "REMI 저장소를 설치합니다."

is_installed remi-release
if [ $FUNC_RESULT = "1" ]; then
    echo "Already installed. -> remi-release"
else
    if [ "$OS" = "rocky8" ]; then
        yum_install http://rpms.remirepo.net/enterprise/remi-release-8.rpm
    elif [ "$OS" = "centos7" ]; then
        yum_install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    else
        yum_install http://rpms.remirepo.net/enterprise/remi-release-6.rpm
    fi
fi

if [ ${YUM_INSTALL_QUIET} = "1" ]; then
  yum -y -q --enablerepo=remi update remi-release
else
  yum -y --enablerepo=remi update remi-release
fi

yum-config-manager --enable remi | grep -P '\[remi|enabled ='
yum-config-manager --save --setopt=remi.exclude="php-* mysql-*" | grep -P '\[remi\]|exclude = php'
yum makecache
