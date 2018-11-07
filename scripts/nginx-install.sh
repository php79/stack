#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "Nginx 를 설치합니다."

is_installed nginx-release
if [ $FUNC_RESULT = "1" ]; then
    echo "Already installed. -> nginx-release"
else
    if [ $OS = "centos7" ]; then
        yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
    else
        yum -y install http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    fi
fi

yum_install nginx

# 실행 유저를 PHP-FPM과 동일하게 설정
sed -i 's/^user  nginx;/user  nobody;/g' /etc/nginx/nginx.conf

WORKER_PROCESSES=$(($(grep -c processor /proc/cpuinfo)/2))
if [ ${WORKER_PROCESSES} -gt 1 ]; then
  notice "nginx worker_processes 를 CPU 개수의 절반인 [ ${WORKER_PROCESSES} ] 개로 설정하였습니다.\n설정 파일 경로) /etc/nginx/nginx.conf"
  sed -i "s/^worker_processes.*/worker_processes  ${WORKER_PROCESSES};/g" /etc/nginx/nginx.conf
fi

if [ ! -f /etc/nginx/conf.d/0-php79.conf ]; then
  notice "nginx 설정에서 gzip 이 기본 활성화되었습니다.\n설정 파일 경로) /etc/nginx/conf.d/0-php79.conf"
  cp -av "${STACK_ROOT}/nginx/0-php79.conf" /etc/nginx/conf.d/
fi

if [ $OS = "centos7" ]; then
  systemctl enable nginx
  systemctl start nginx
else
  chkconfig nginx on
  service nginx start
fi
