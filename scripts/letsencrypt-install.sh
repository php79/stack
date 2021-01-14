#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "Let's Encrypt 자동화툴을 설치합니다."

notice "[1/5] 인증툴인 certbot-auto 를 설치합니다. - https://certbot.eff.org/"
notice "      certbot 최신 버전의 CentOS 지원 중단에 따라, 지원가능한 1.10.1 버전을 설치합니다. - https://github.com/php79/stack/issues/83"
if [ ! -f "/usr/bin/certbot-auto" ]; then
  cd /usr/bin \
  && wget https://raw.githubusercontent.com/certbot/certbot/1.10.x/certbot-auto \
  && chmod ug+x certbot-auto \
  && certbot-auto --install-only --no-self-upgrade -n
else
  outputComment "  (생략) /usr/bin/certbot-auto 파일이 이미 존재합니다.\n"
fi

notice "[2/5] nginx 에서 사용할 설정 파일들을 /etc/letsencrypt/php79 에 복사합니다."
if [ ! -f "/etc/letsencrypt/php79/ssl-stable.conf" ]; then
  if [ ! -d /etc/letsencrypt ]; then
    mkdir /etc/letsencrypt
  fi
  if [ ! -d /etc/letsencrypt/php79 ]; then
    cp -av "${STACK_ROOT}/letsencrypt/php79" /etc/letsencrypt/
  fi
else
  outputComment "  (생략) /etc/letsencrypt/php79/ssl-stable.conf 파일이 이미 존재합니다.\n"
fi

notice "[3/5] 인증용 웹문서 디렉토리를 생성합니다."
if [ ! -d /var/www/letsencrypt/.well-known ]; then
  mkdir -p /var/www/letsencrypt/.well-known
else
  outputComment "  (생략) /var/www/letsencrypt/.well-known 디렉토리가 이미 존재합니다.\n"
fi

notice "[4/5] 암호화 강화를 위한 Diffie-Hellman parameters 를 생성합니다."
if [ ! -f "/etc/letsencrypt/php79/ssl-dhparams.pem" ]; then
  openssl dhparam -out /etc/letsencrypt/php79/ssl-dhparams.pem 2048
else
  outputComment "  (생략) /etc/letsencrypt/php79/ssl-dhparams.pem 파일이 이미 존재합니다.\n"
fi

notice "[5/5] 인증서 갱신 스크립트를 매일 새벽 자동 실행되도록 크론에 추가합니다."
if [ ! -f "/etc/cron.daily/php79-certbot-auto-renew" ]; then
  cp -av "${STACK_ROOT}/letsencrypt/php79-certbot-auto-renew" /etc/cron.daily/
  chmod 700 /etc/cron.daily/php79-certbot-auto-renew
else
  outputComment "  (생략) /etc/cron.daily/php79-certbot-auto-renew 파일이 이미 존재합니다.\n"
fi
