#!/usr/bin/env bash
# XE1 - http://www.xpressengine.com/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~ \
&& mkdir master \
&& cd master \
&& git clone --depth=1 --branch=master https://github.com/xpressengine/xe-core.git public \
&& cd public \

# files 디렉토리 생성
mkdir -m 0766 files

# 쉬운 설치 지원
chmod -R a+rw ./

echo "XE1 설치 준비가 완료되었습니다."
echo "웹브라우저로 접속하여 설치를 계속 진행하여 주세요."
