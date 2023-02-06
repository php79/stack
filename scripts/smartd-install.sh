#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "S.M.A.R.T. 디스크 모니터링을 설치합니다."

yum_install smartmontools

if [ "$SYSTEMCTL" = "1" ]; then
  systemctl enable smartd
  systemctl start smartd
else
  chkconfig smartd on
  service smartd start
fi
