#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short

title "Nginx 디렉토리의 소유자/그룹을 nginx 에서 nobody 로 변경합니다."

outputInfo "  - 약 2021년 8월 이후, nginx 를 신규 설치하였거나 업데이트된 경우, 이 스크립트를 실행해주시면 됩니다.\n"
outputInfo "    참고) https://github.com/php79/stack/issues/86\n"
echo

DIRS="/var/lib/nginx"
FILES=$( find ${DIRS} -user nginx -o -group nginx )

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

  find ${FILES} -user nginx -exec chown -v nobody {} \;
  find ${FILES} -group nginx -exec chgrp -v nobody {} \;

  echo
  outputInfo "소유자/그룹을 nobody 로 변경하였습니다."
  echo
fi
