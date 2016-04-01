#!/usr/bin/env bash
# 그누보드4 - http://sir.kr/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~ \
&& mkdir master \
&& cd master \
&& mkdir public

echo "그누보드4는 git 을 통한 자동 설치를 지원하지 않습니다."
echo "http://sir.kr/g4_pds 에서 최신 파일을 다운로드하여 public 디렉토리 아래에 설치하시면 됩니다."
