#!/usr/bin/env bash
# phpMyAdmin - https://www.phpmyadmin.net/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~/master/public \
&& git pull origin STABLE

echo "phpMyAdmin 업데이트가 완료되었습니다."
