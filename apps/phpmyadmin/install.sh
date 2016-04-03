#!/usr/bin/env bash
# phpMyAdmin - https://www.phpmyadmin.net/
# updated: 2016-04-01

if [ $(whoami) = "root" ]; then
  echo "root 계정으로 실행할 수 없습니다.  설치된 사용자 계정으로 실행해 주세요.  ex) su - new_user"
  exit 1
fi

cd ~ \
&& mkdir master \
&& cd master \
&& git clone --depth=1 --branch=STABLE git://github.com/phpmyadmin/phpmyadmin.git public \
&& cd public \
&& cp -av config.sample.inc.php config.inc.php

# 쿠키 암호화에 사용되는 키 생성
BLOWFISH_SECRET=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#' | head -c 32)
sed -i "s/\$cfg\['blowfish_secret'\] = '[^']*'/\$cfg\['blowfish_secret'\] = '${BLOWFISH_SECRET}'/g" config.inc.php

echo "phpMyAdmin 설치가 완료되었습니다."
echo "주의) phpMyAdmin 은 보안을 고려하여, 내부 IP (127.0.0.1)에서만 접근이 가능하도록 설정되었습니다."
echo "     따라서 외부에서 접근하려면 미리 /etc/nginx/conf.d/아이디.conf 파일을 열어, IP를 추가해주어야 합니다."
