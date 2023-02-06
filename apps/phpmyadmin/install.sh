#!/usr/bin/env bash
# phpMyAdmin - https://www.phpmyadmin.net/
# updated: 2023-02-06 composer 설치로 개선. phpMyAdmin 5.2.0 설치 확인.  "php": "^7.2.5 || ^8.0"
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

# master 디렉토리 생성 및 composer 로 public 디렉토리에 phpMyAdmin 설치
cd ~

if [ ! -d master ]; then
  mkdir -v  master
  echo
fi

cd master

if [ ! -d public ]; then
  composer create-project phpmyadmin/phpmyadmin public
fi

# 설정 파일 복사
cd public

if [ ! -f config.inc.php ]; then
  echo "config.inc.php 파일을 복사합니다."
  cp -av config.sample.inc.php config.inc.php
  echo
fi

# 설정 - 쿠키 암호화에 사용되는 비밀키 생성
echo "config.ini.php 파일에서 쿠키 암호화용 비밀키를 생성합니다."
BLOWFISH_SECRET=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#' | head -c 32)
sed -i "s/\$cfg\['blowfish_secret'\] = '[^']*'/\$cfg\['blowfish_secret'\] = '${BLOWFISH_SECRET}'/g" config.inc.php
echo

# 임시 디렉토리 생성
if [ ! -d tmp ]; then
  echo "임시 디렉토리를 만듭니다."
  mkdir -v  tmp && chmod -v 777 tmp
  echo
fi

# 세션 디렉토리 생성 및 설정 변경
cd ~/master
if [ ! -d session ]; then
  echo "세션 디렉토리를 만듭니다."
  mkdir -v  session && chmod -v 777 session
  echo

  echo "config.inc.php 파일에 세션 디렉토리 변수를 추가합니다."
  CFG_SESSION_SAVE_PATH="$(pwd)/session"
  CFG_ADD="\$cfg['SessionSavePath'] = '${CFG_SESSION_SAVE_PATH}';"
  printf "\n${CFG_ADD}\n" >> public/config.inc.php
  echo
fi

echo "phpMyAdmin 설치가 완료되었습니다."
echo
echo "주의) phpMyAdmin 은 보안을 고려하여, 내부 IP (127.0.0.1)에서만 접근이 가능하도록 설정되었습니다."
echo "        접근 불가 IP 에서는 '403 Forbidden' 에러가 보여지게 됩니다."
echo
echo "작업 필요) 외부에서 접근하려면 미리 /etc/nginx/conf.d/아이디.conf 파일을 열어, IP를 추가해주어야 합니다."
