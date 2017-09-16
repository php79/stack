#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short


title "업데이트전 nginx 설정을 먼저 테스트합니다."

/usr/sbin/nginx -t

if [ ${?} != "0" ]; then
  error "nginx 설정 테스트가 실패하였습니다.  nginx 설정 오류를 해결하고 업데이트해주세요."
  exit 1
fi


title "php79 stack 업데이트를 시작합니다."

git pull origin master

if [ "${?}" != "0" ]; then
  abort "php79 stack 업데이트가 실패하였습니다."
fi

NEW_STACK_VERSION=$(cat "${STACK_ROOT}/.app_version")
if [ ${STACK_VERSION} != ${NEW_STACK_VERSION} ]; then
  title "업데이트후 nginx 설정을 테스트합니다."

  /usr/sbin/nginx -t

  if [ ${?} != "0" ]; then
    error "nginx 설정 테스트가 실패하였습니다.  nginx 설정 오류를 해결해주세요."
    exit 1
  else
    outputInfo "nginx 설정 테스트가 완료되었습니다."
  fi

  outputInfo "php79 stack ${NEW_STACK_VERSION} 버전으로 업데이트되었습니다."
  echo
else
  outputInfo "php79 stack 업데이트가 없습니다."
  echo
fi
