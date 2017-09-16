#!/usr/bin/env bash
# Laravel 5.4 - https://laravel.com/docs/5.4
# updated: 2017-09-16

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

composer -v create-project laravel/laravel master "5.4.*"

chmod -v -R a+rw master/storage/ master/bootstrap/cache/

echo "Laravel 5.4 설치가 완료되었습니다."
echo "  - 디비 정보 등 주요 설정 파일: master/.env"
echo "  - img, css, js 등의 외부로 노출되는 리소스 디렉토리: master/public/"
