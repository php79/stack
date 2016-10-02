#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short

title "PHP FPM 로그/세션 디렉토리의 소유자/그룹을 apache 에서 nobody 로 변경합니다."

outputInfo "  - yum update 를 통해 php-fpm 이 업데이트된 후, 이 스크립트를 실행해주시면 됩니다.\n"
outputInfo "    참고) https://github.com/php79/stack/issues/12\n"
echo

DIRS="/var/log/php-fpm /var/lib/php /opt/remi /var/opt/remi"
FILES=$( find ${DIRS} -user apache -o -group apache )

if [ -z "${FILES}" ]; then
  outputInfo "변경 대상이 없으므로 중단합니다."
  echo
else
  outputComment "변경할 디렉토리/파일:\n"
  echo ${FILES}|xargs -n 1
  echo

  if [ "$INTERACTIVE" = "1" ]; then
    outputQuestion "위 디렉토리/파일의 소유자/그룹을 nobody 로 변경하시겠습니까? [n/Y]"
    read -p " " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
       outputInfo "변경을 중단합니다."
       echo
       exit 1
    fi
  fi

  find ${FILES} -user apache -exec chown -v nobody {} \;
  find ${FILES} -group apache -exec chgrp -v nobody {} \;

  echo
  outputInfo "소유자/그룹을 nobody 로 변경하였습니다."
  echo
fi
