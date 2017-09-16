#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)
#
# 랜덤 비밀번호 생성. 식별하기 어려운 o, O, 0, I, l, 1 문자열은 제외

if [ -z ${1} ]; then
  LENGTH=32
else
  LENGTH=${1}
fi

< /dev/urandom tr -dc A-HJ-NP-Za-km-np-z1-9 | head -c ${LENGTH}
