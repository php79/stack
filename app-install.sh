#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

USR_BIN_PHP_VERSION=`/usr/bin/php -r 'echo PHP_MAJOR_VERSION . PHP_MINOR_VERSION;'`

function show_usage
{
  welcome_short

  title "앱 설치 순서는 다음과 같습니다."
  outputComment "  1. 시스템/디비 계정 자동 생성.  user-add.sh 사용"
  echo
  outputComment "  2. 웹서버(Nginx) 자동 설정.   apps/앱이름/template-server.conf 으로 /etc/nginx/conf.d/사용자.conf 설정 생성"
  echo
  outputComment "  3. (선택) 앱 자동 설치.  apps/앱이름/install.sh 를 사용자 디렉토리에 복사하여 실행."
  echo
  outputComment "  4. (선택) SSL 인증서 발급.  ssl-install.sh 사용"
  echo

  echo
  echo "Example:"

  echo "  # 홈페이지) domain=php79.net 사용시, php79.net 과 www.php79.net 2개 주소 지원"
  outputComment "    ${0} --user=php79 --domain=php79.net"
  echo

  echo "  # Laravel) Laravel nginx rewrite 적용, PHP 버전 지정, SSL 인증서 발급"
  outputComment "   ${0} --user=laravel --domains=laravel.php79.net --app=laravel --php=82 --ssl"
  echo

  echo "  # 멀티 도메인) domains 는 www. 없이 2개 이상 도메인 입력 가능"
  outputComment "   ${0} --user=mail --domains='mail.php79.net mail.php79.kr'"
  echo

  echo
  echo "Usage:"

  echo -n "  "
  outputInfo  "--user"
  echo "      시스템 계정.  ./user-add.sh 로 추가한 아이디를 입력하세요."
  echo

  echo -n "  "
  outputInfo  "--password"
  echo "  (기본 : 랜덤생성) 비밀번호.  미입력시 자동생성됩니다. 특수문자 사용시엔 반드시 작은 따옴표(')로 감싸주어야 합니다."
  echo

  echo -n "  "
  outputInfo  "--domain"
  echo "    도메인.  nginx 설정의 server_name 에 사용됩니다.  www. 없이 입력하세요."
  echo "                Tip) 도메인이 없거나 연결되지 않았습니까?  PC 에서만 테스트하는 방법을 참고하세요. http://www.php79.com/176"
  echo "                주의) mail.php79.net 형태의 www. 이 불필요한 경우는 --domains 를 사용해주세요."
  echo

  echo -n "  "
  outputInfo  "--domains"
  echo "    도메인들.  nginx 설정의 server_name 에 사용됩니다.  2개 이상은 공백으로 구분하여 입력할 수 있습니다."
  echo "                Tip) mail.php79.net 처럼 1개 서브 도메인만 추가 가능하며, 'mail.php79.net smtp.php79.net' 처럼 멀티 호스트 도메인도 가능합니다."
  echo "                Tip) 'mail.php79.net mail.php79.co.kr' 처럼 서로 다른 2개 이상의 멀티 도메인도 가능합니다."
  echo "                주의) *.php79.net 형태의 와일드 카드 도메인은 SSL 인증서 발급을 지원하지 않습니다."
  echo

  echo -n "  "
  outputInfo  "--app"
  echo "       (기본 : default) 설치할 프로그램명은 ${STACK_ROOT}/apps 디렉토리안의 하위 디렉토리명과 일치해야 합니다."
  echo "         default      - Nginx 앱별 rewrite 설정이 없는 기본"
  echo "         laravel      - Laravel"
  echo "         codeigniter4 - CodeIgniter 4"
  echo "         wordpress    - WordPress (앱 자동 설치 install.sh 있음)"
  echo "         phpmyadmin   - phpMyAdmin (앱 자동 설치 install.sh 있음)"
  echo "         gnuboard5    - 그누보드 5 (앱 자동 설치 install.sh 있음)"
  echo

  echo -n "  "
  outputInfo  "--php"
  echo "       (기본 : ${USR_BIN_PHP_VERSION}) PHP 버전을 [ 53 54 55 56 56 70 71 72 73 74 80 81 82 83 84 ] 형식으로 하나만 입력하세요."
  echo "                Tip) Laravel 은 82, 그누보드4 는 53 등 프로그램에 따라 적절히 선택하세요."
  echo "                     ./status.sh 명령을 통해 현재 서버에 설치된 PHP 버전을 확인할 수 있습니다."
  echo

  echo -n "  "
  outputInfo  "--skip-install"
  echo "       (선택) 계정 추가 및 nginx 설정까지만 진행하고, 앱 자동 설치(install.sh)는 생략합니다."
  echo "                Tip) 이미 제작된 소스로 설치하거나, 직접 소스를 설치하실 경우에 사용하세요."
  echo

  echo -n "  "
  outputInfo  "--ssl"
  echo "       (선택) Let's Encrypt 자동화툴을 사용해서, SSL 인증서 발급을 함께 진행합니다."
  echo "                주의) 인증서를 발급 받은 도메인의 IP가 현재 서버로 지정되어 있어야 인증서 발급이 가능합니다."
  echo "                      앱 설치가 완료된 마지막 단계에서 발급을 시도하므로, 발급 실패시에도 앱 사용에는 문제없습니다."
  echo "                      앱 설치후에도 ssl-install.sh 명령을 통해 별도 발급 가능합니다."
  echo
}

function input_abort
{
  outputError "${1}"
  echo
  exit 1
}

# Options
if [ -z ${1} ]; then
  show_usage
  exit
else
  INPUT_SKIP_INSTALL=0
  INPUT_SSL=0
  for i in "${@}"
  do
    case $i in
    --user=*)
      shift
      INPUT_USER="${i#*=}"
      ;;
    --password=*)
      shift
      INPUT_PASSWORD="${i#*=}"
      ;;
    --domain=*)
      shift
      INPUT_DOMAIN="${i#*=}"
      ;;
    --domains=*)
      shift
      INPUT_DOMAINS="${i#*=}"
      INPUT_DOMAINS_ARRAY=($INPUT_DOMAINS)
      # domains 가 입력된 경우,  INPUT_DOMAIN 에 첫번째 도메인 입력하기?
      INPUT_DOMAIN=${INPUT_DOMAINS_ARRAY[0]}
      ;;
    --app=*)
      shift
      INPUT_APP="${i#*=}"
      ;;
    --php=*)
      shift
      INPUT_PHP_VERSION="${i#*=}"
      ;;
    --skip-install)
      shift
      INPUT_SKIP_INSTALL=1
      ;;
    --ssl)
      shift
      INPUT_SSL=1
      ;;
    -h | --help )
      show_usage
      exit
      ;;
  esac
  done
fi

# 입력값 검사
if [ -z ${INPUT_USER} ]; then
  input_abort "user 항목을 입력하세요."
fi

PASSWORD_GENERATED=0
if [ -z ${INPUT_PASSWORD} ]; then
  #input_abort "password 항목을 입력하세요."
  INPUT_PASSWORD=$(scripts/password-generate.sh)
  PASSWORD_GENERATED=1
fi

if [ -z ${INPUT_DOMAIN} ] && [ -z ${INPUT_DOMAINS} ]; then
  input_abort "domain, domains 항목중 하나를 입력하세요."
fi

if [ -z ${INPUT_DOMAIN} ]; then
  input_abort "domain 항목을 입력하세요."
fi

if [ -z ${INPUT_APP} ]; then
#  input_abort "app 항목을 입력하세요."
  INPUT_APP="default"
fi

if [ ! -f "${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf" ]; then
  input_abort "아직 지원하지 않는 app 입니다.  (${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf 파일이 존재하지 않습니다.)"
fi

if [ -z ${INPUT_PHP_VERSION} ]; then
#  input_abort "php_version 항목을 입력하세요."
  INPUT_PHP_VERSION="${USR_BIN_PHP_VERSION}"
fi

if [ ! -f "/usr/bin/php${INPUT_PHP_VERSION}" ]; then
  input_abort "PHP ${INPUT_PHP_VERSION} 버전은 아직 설치되지 않았습니다.  입력 형식) 53 54 55 56 70 71 72 73 74 80 81 82 83 84"
fi

# nginx 중복 체크
if [ -f "/etc/nginx/conf.d/${INPUT_USER}.conf" ]; then
  abort "/etc/nginx/conf.d/${INPUT_USER}.conf 설정 파일이 이미 존재합니다."
fi

# 사용자 계정 폴더에 자동 설치가 이미 진행되었는지 중복 체크
if [ -d "/home/${INPUT_USER}/master" ]; then
  abort "자동 설치에 사용되는 [ /home/${INPUT_USER}/master ] 디렉토리가 이미 존재합니다."
fi

if [ -f "/home/${INPUT_USER}/install.sh" ]; then
  abort "자동 설치에 사용되는 [ /home/${INPUT_USER}/install.sh ] 파일이 이미 존재합니다."
fi


# TODO: PHP 와 nginx 서버가 분리된 경우 대응 고려
# 추가전 nginx 설정 체크
outputComment "# nginx 설정 추가전, nginx 설정을 테스트합니다."
echo
/usr/sbin/nginx -t

if [ "${?}" != "0" ]; then
  abort "nginx 설정에 문제가 있습니다."
fi

# 비밀번호도 입력받아야 하므로, 계정 추가 작업도 일괄 처리
./user-add.sh --user=${INPUT_USER} --password=${INPUT_PASSWORD} --skip-guide-app-install
if [ "${?}" != "0" ]; then
  abort "시스템 계정 추가 작업이 실패하였습니다."
fi
echo

# TODO: /home 대신 실제 사용자의 HOME_DIR 을 읽어오도록 개선 필요
if [ ! -d "/home/${INPUT_USER}" ]; then
  input_abort "/home/${INPUT_USER} 디렉토리가 존재하지 않습니다.   실제 존재하는 시스템 계정인지 확인해주세요."
fi

# nginx 설정 추가
notice "nginx 에 새로운 사이트 설정을 추가합니다."

# domains 입력 처리
if [ -z "${INPUT_DOMAINS}" ]; then
  CERTBOT_DOMAINS="-d ${INPUT_DOMAIN} -d www.${INPUT_DOMAIN}"
  PRINT_DOMAINS="${INPUT_DOMAIN} www.${INPUT_DOMAIN}"
else
  CERTBOT_DOMAINS=""
  for i in "${INPUT_DOMAINS_ARRAY[@]}"
  do
    CERTBOT_DOMAINS="${CERTBOT_DOMAINS} -d ${i}"
  done
  PRINT_DOMAINS="${INPUT_DOMAINS}"
fi
outputInfo "  - 추가할 도메인            : ${PRINT_DOMAINS}\n\n"

cp -av "${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf" "/etc/nginx/conf.d/${INPUT_USER}.conf"

if [ -z "${INPUT_DOMAINS}" ]; then
  sed -i "s/_INPUT_DOMAIN_/${INPUT_DOMAIN}/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
else
  sed -i "s/_INPUT_DOMAIN_ www._INPUT_DOMAIN_/${INPUT_DOMAINS}/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
fi

sed -i "s/_INPUT_USER_/${INPUT_USER}/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
sed -i "s/_INPUT_BACKEND_/php${INPUT_PHP_VERSION}_backend/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
echo
#cat "/etc/nginx/conf.d/${INPUT_USER}.conf"
#echo

# 추가후 nginx 설정 체크.  장애시 롤백하고 다시 테스트
outputComment "# nginx 설정 추가후, nginx 설정을 다시 테스트합니다."
echo
/usr/sbin/nginx -t

if [ "${?}" != "0" ]; then
  outputError "nginx 설정에 문제가 있어, 추가된 설정 파일을 삭제합니다."
  echo
  rm -f "/etc/nginx/conf.d/${INPUT_USER}.conf"
  abort
fi


# 앱 설치 스크립트 추가
if [ "$INPUT_SKIP_INSTALL" = "0" ]; then
  if [ -f "${STACK_ROOT}/apps/${INPUT_APP}/install.sh" ]; then
    notice "앱 설치를 시작합니다."
    cp -av "${STACK_ROOT}/apps/${INPUT_APP}/install.sh" "/home/${INPUT_USER}/" \
    && chmod -v 700 "/home/${INPUT_USER}/install.sh" \
    && chown -v "${INPUT_USER}.${INPUT_USER}" "/home/${INPUT_USER}/install.sh" \
    && su - ${INPUT_USER} -c "./install.sh ${INPUT_USER} ${INPUT_PASSWORD}"
  else
    su - ${INPUT_USER} -c "mkdir -p ~/master/public"
  fi

  if [ -f "${STACK_ROOT}/apps/${INPUT_APP}/update.sh" ]; then
    cp -av "${STACK_ROOT}/apps/${INPUT_APP}/update.sh" "/home/${INPUT_USER}/" \
    && chmod -v 700 "/home/${INPUT_USER}/update.sh" \
    && chown -v "${INPUT_USER}.${INPUT_USER}" "/home/${INPUT_USER}/update.sh"
  fi
else
  notice "앱 자동 설치는 생략(--skip-install)하고, 웹문서 디렉토리만 만듭니다."
  su - ${INPUT_USER} -c "mkdir -p ~/master/public"
fi

# nginx 재시작
outputComment "# nginx 를 재시작합니다.\n"
echo
if [ "$SYSTEMCTL" = "1" ]; then
  systemctl reload nginx
else
  service nginx reload
fi

# 비밀번호 자동 생성시, ~/.my.cnf 생성
if [ ${PASSWORD_GENERATED} = "1" ]; then
  su - ${INPUT_USER} -c "printf \"[client]\\npassword=${INPUT_PASSWORD}\\n\" > ~/.my.cnf && chmod go-rwx ~/.my.cnf"
fi

# SSL 인증서 발급 및 nginx SSL 설정 추가 - 실패시에도 설치 완료 화면 표시
if [ ${INPUT_SSL} = "1" ]; then
   if [ -f "/usr/bin/certbot-auto" ]; then
     if [ -z "${INPUT_DOMAINS}" ]; then
       ${STACK_ROOT}/ssl-install.sh --user=${INPUT_USER} --domain=${INPUT_DOMAIN}
     else
       ${STACK_ROOT}/ssl-install.sh --user=${INPUT_USER} --domains="${INPUT_DOMAINS}"
     fi
   else
     outputError "Let's Encrypt 자동화툴이 설치되지 않았습니다. SSL 인증서 발급을 생략합니다."
   fi
fi

echo
outputComment "### 앱 설치가 완료되었습니다. ###\n\n"

outputInfo "  - Nginx config      : /etc/nginx/conf.d/${INPUT_USER}.conf\n\n"

outputInfo "  - Document root     : /home/${INPUT_USER}/master/public\n\n"

outputInfo "  - SSH & DB User     : ${INPUT_USER}\n\n"

if [ ${PASSWORD_GENERATED} = "1" ]; then
  outputInfo "  - SSH & DB Password : ${INPUT_PASSWORD}\n"
  echo "      (자동 생성된 비밀번호이며 \"/home/${INPUT_USER}/.my.cnf\" 파일에도 저장되었습니다.)"
  echo
fi

if [ -z "${INPUT_DOMAINS}" ]; then
 outputInfo "  - URL               : http://${INPUT_DOMAIN}\n"
else
  for i in "${INPUT_DOMAINS_ARRAY[@]}"
  do
   outputInfo "  - URL               : http://${i}\n"
  done
fi

echo "      (도메인이 없거나 연결 오류시, PC 에서 hosts 수정하여 테스트하는 방법 - http://www.php79.com/176)"
echo

echo
