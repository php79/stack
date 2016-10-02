#!/usr/bin/env bash
# 그누보드5 - http://sir.kr/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~ \
&& mkdir master \
&& cd master \
&& git clone --depth=1 --branch=master https://github.com/gnuboard/gnuboard5.git public \
&& cd public \
&& chmod -v u+x perms.sh \
&& ./perms.sh \
&& mkdir data \
&& chmod -v uo+rwx data

echo "그누보드5 설치 준비가 완료되었습니다."
echo "웹브라우저로 접속하여 설치를 계속 진행하여 주세요."
