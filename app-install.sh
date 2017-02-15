#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

welcome_short

title "앱 설치 순서는 다음과 같습니다."
outputComment "  1. 시스템/디비 계정 자동 생성.  user-add.sh 사용"
echo
outputComment "  2. 웹서버 자동 설정.   apps/앱이름/template-server.conf 으로 /etc/nginx/conf.d/사용자.conf 설정 생성"
echo
outputComment "  3. 앱 자동 설치.  apps/앱이름/install.sh 를 사용자 디렉토리에 복사하여 실행."
echo

function show_usage
{
  echo
  echo "Example:"
  outputComment "  ${0} --user=php79 --password='php79!@' --domain=php79.com --app=laravel51 --php=70"
  echo
  outputComment "  ${0} --user=wordpress --password='php79!@' --domain=wordpress.php79.com --app=wordpress --php=70"
  echo
  outputComment "  ${0} --user=phpmyadmin --password='php79!@' --domain=phpmyadmin.php79.com --app=phpmyadmin --php=70"
  echo
  outputComment "  ${0} --user=octobercms --password='php79!@' --domain=octobercms.php79.com --app=laravel51 --php=70 --skip-install"
  echo

  echo
  echo "Usage:"

  echo -n "  "
  outputInfo  "--user"
  echo "      시스템 계정.  ./user-add.sh 로 추가한 아이디를 입력하세요."
  echo

  echo -n "  "
  outputInfo  "--password"
  echo "  비밀번호.  특수문자 사용시엔 반드시 작은 따옴표(')로 감싸주어야 합니다."
  echo

  echo -n "  "
  outputInfo  "--domain"
  echo "    도메인.  nginx 설정의 server_name 에 사용됩니다.  www. 없이 입력하세요."
  echo "                Tip) 도메인이 없거나 연결되지 않았습니까?  PC 에서만 테스트하는 방법을 참고하세요. http://www.php79.com/176"
  echo

  echo -n "  "
  outputInfo  "--app"
  echo "       설치할 프로그램명은 ${STACK_ROOT}/apps 디렉토리안의 하위 디렉토리명과 일치해야 합니다."
  echo "         laravel52  - Laravel 5.2"
  echo "         laravel51  - Laravel 5.1"
  echo "         wordpress  - WordPress"
  echo "         phpmyadmin - phpMyAdmin"
  echo "         gnuboard5  - 그누보드 5"
  echo "         gnuboard4  - 그누보드 4"
  echo "         xe1        - XE 1"
  echo

  echo -n "  "
  outputInfo  "--php"
  echo "       PHP 버전을 [ 53 54 55 56 56 70 71 ] 형식으로 하나만 입력하세요."
  echo "                Tip) Laravel 은 70, 그누보드4 는 53 등 프로그램에 따라 적절히 선택하세요."
  echo "                     ./status.sh 명령을 통해 현재 서버에 설치된 PHP 버전을 확인할 수 있습니다."
  echo

  echo -n "  "
  outputInfo  "--skip-install"
  echo "       계정 추가 및 nginx 설정까지만 진행하고, 앱 자동 설치(install.sh)는 생략합니다."
  echo "                Tip) 이미 제작된 소스로 설치하거나, 직접 소스를 설치하실 경우에 사용하세요."
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

if [ -z ${INPUT_PASSWORD} ]; then
  input_abort "password 항목을 입력하세요."
fi

# 비밀번호도 입력받아야 하므로, 계정 추가 작업도 일괄 처리
./user-add.sh --user=${INPUT_USER} --password=${INPUT_PASSWORD}
if [ "${?}" != "0" ]; then
  abort "시스템 계정 추가 작업이 실패하였습니다."
fi

#if [ -z $(id -u ${INPUT_USER}) ]; then
#  input_abort "존재하지 않는 user 입니다.  ./user-add.sh 로 먼저 추가하세요."
#fi

# TODO: /home 대신 실제 사용자의 HOME_DIR 을 읽어오도록 개선 필요
if [ ! -d "/home/${INPUT_USER}" ]; then
  input_abort "/home/${INPUT_USER} 디렉토리가 존재하지 않습니다.   실제 존재하는 시스템 계정인지 확인해주세요."
fi

if [ -z ${INPUT_DOMAIN} ]; then
  input_abort "domain 항목을 입력하세요."
fi

if [ -z ${INPUT_APP} ]; then
  input_abort "app 항목을 입력하세요."
fi

if [ ! -f "${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf" ]; then
  input_abort "아직 지원하지 않는 app 입니다.  (${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf 파일이 존재하지 않습니다.)"
fi

if [ -z ${INPUT_PHP_VERSION} ]; then
  input_abort "php_version 항목을 입력하세요."
fi

if [ ! -f "/usr/bin/php${INPUT_PHP_VERSION}" ]; then
  input_abort "PHP ${INPUT_PHP_VERSION} 버전은 아직 설치되지 않았습니다.  입력 형식) 53 54 55 56 70"
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
outputComment "# 먼저 nginx 설정을 테스트합니다."
echo
/usr/sbin/nginx -t

if [ "${?}" != "0" ]; then
  abort "nginx 설정에 문제가 있습니다."
fi


# nginx 설정 추가
notice "nginx 에 새로운 사이트 설정을 추가합니다."
cp -av "${STACK_ROOT}/apps/${INPUT_APP}/template-server.conf" "/etc/nginx/conf.d/${INPUT_USER}.conf"
sed -i "s/_INPUT_DOMAIN_/${INPUT_DOMAIN}/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
sed -i "s/_INPUT_USER_/${INPUT_USER}/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
sed -i "s/_INPUT_BACKEND_/php${INPUT_PHP_VERSION}_backend/g" "/etc/nginx/conf.d/${INPUT_USER}.conf"
echo
cat "/etc/nginx/conf.d/${INPUT_USER}.conf"
echo

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
  notice "앱 설치를 시작합니다."
  cp -av "${STACK_ROOT}/apps/${INPUT_APP}/install.sh" "/home/${INPUT_USER}/" \
  && chmod -v 700 "/home/${INPUT_USER}/install.sh" \
  && chown -v "${INPUT_USER}.${INPUT_USER}" "/home/${INPUT_USER}/install.sh" \
  && su - ${INPUT_USER} -c "./install.sh ${INPUT_USER} ${INPUT_PASSWORD}"

  if [ -f "${STACK_ROOT}/apps/${INPUT_APP}/update.sh" ]; then
    cp -av "${STACK_ROOT}/apps/${INPUT_APP}/update.sh" "/home/${INPUT_USER}/" \
    && chmod -v 700 "/home/${INPUT_USER}/update.sh" \
    && chown -v "${INPUT_USER}.${INPUT_USER}" "/home/${INPUT_USER}/update.sh"
  fi
else
  notice "앱 자동 설치는 생략합니다.(--skip-install)"
fi

# nginx 재시작
outputComment "nginx 를 재시작합니다."
echo
if [ $OS = "centos7" ]; then
  systemctl reload nginx
else
  service nginx reload
fi

echo
outputInfo "앱 설치가 완료되었습니다.  http://${INPUT_DOMAIN} 로 접속하여 확인해보세요."
echo
echo "        Tip) 도메인이 없거나 연결되지 않았습니까?  PC 에서만 테스트하는 방법을 참고하세요. http://www.php79.com/176"
echo
