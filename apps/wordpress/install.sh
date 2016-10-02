#!/usr/bin/env bash
# WordPress - https://wordpress.org/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~ \
&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod -v 700 wp-cli.phar \
&& mv wp-cli.phar wp \
&& mkdir -p master/public \
&& cd master/public \
&& ~/wp core download --locale=ko_KR \
&& chmod -v -R a+rw wp-content/

# 디비 정보 입력
~/wp core config --dbname=${1} --dbuser=${1} --dbpass=${2} --dbcharset=utf8mb4 --extra-php <<PHP
define( 'FS_METHOD', 'direct' );
PHP

# WP Super Cache 처럼 플러그인에서 설정 파일을 수정할 수 있도록 대응
chmod -v a+rw wp-config.php

echo "워드프레스 설치 준비가 완료되었습니다."
echo "웹브라우저로 접속하여 설치를 계속 진행하여 주세요."
