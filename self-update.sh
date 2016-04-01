#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

welcome_short

git pull origin master

if [ "${?}" != "0" ]; then
  abort "php79 stack 업데이트가 실패하였습니다."
fi

outputInfo "php79 stack 업데이트가 완료되었습니다."
