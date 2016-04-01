#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "SELinux 를 비활성화합니다."

sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
/usr/sbin/setenforce 0
