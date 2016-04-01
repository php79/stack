#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short

title "php79 stack 업데이트를 시작합니다."

git pull origin master

if [ "${?}" != "0" ]; then
  abort "php79 stack 업데이트가 실패하였습니다."
fi

NEW_STACK_VERSION=$(cat "${STACK_ROOT}/.app_version")
if [ ${STACK_VERSION} != ${NEW_STACK_VERSION} ]; then
  outputInfo "php79 stack ${NEW_STACK_VERSION} 버전으로 업데이트되었습니다."
  echo
else
  outputInfo "php79 stack 업데이트가 없습니다."
  echo
fi
