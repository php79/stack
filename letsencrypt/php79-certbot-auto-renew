#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

# 1. crond 실행 지원
#    - PATH 오류 예방을 위해, 전체 경로 사용.
#    - function.inc.sh 미사용.
#    - non-interactively 모드로 화면 출력없이 실행
# 2. nginx 설정 테스트 성공시에만 nginx 재시작
#    - --post-hook https://certbot.eff.org/docs/using.html#renewing-certificates

if [ -f /usr/bin/systemctl ]; then
  /usr/bin/certbot-auto renew -n --quiet --post-hook '/usr/sbin/nginx -t 2> /dev/null && /usr/bin/systemctl reload nginx'
else
  /usr/bin/certbot-auto renew -n --quiet --post-hook '/usr/sbin/nginx -t 2> /dev/null && /sbin/service nginx reload'
fi

if [ ${?} != "0" ]; then
  /usr/bin/logger -t 'php79-stack' -p 'local0.err' "certbot-auto-renew-cron.sh returned error code ${?}"
else
  /usr/bin/logger -t 'php79-stack' "certbot-auto-renew-cron.sh succeeded."
fi
