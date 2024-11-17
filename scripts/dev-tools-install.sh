#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "서버 필수 유틸과 점검툴들을 설치합니다."

# stack.conf 에서 선언한 패키지 설치
if [ "$OS" = "rocky8" ]; then
  PACKAGES=${DEV_PACKAGES_R8}
else
  PACKAGES=${DEV_PACKAGES}
fi

if [ ! -z "$PACKAGES" ]; then
  yum_install $PACKAGES
fi
