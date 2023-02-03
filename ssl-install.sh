#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

function show_usage
{
  welcome_short

  title "Let's Encrypt SSL 인증서 발급 순서는 다음과 같습니다."
  outputComment "  1. nginx 사이트 설정에 Let's Encrypt 인증용 디렉토리 접근 추가"
  echo
  outputComment "  2. certbot-auto 로 SSL 인증서 발급 테스트후, 실제 인증서 발급"
  outputComment "      주의) 인증서를 발급 받은 도메인의 IP가 현재 서버로 지정되어 있어야 인증서 발급이 가능합니다."
  echo
  outputComment "  3. nginx 사이트 설정 마지막에 SSL 설정 추가"
  echo

  echo
  echo "Example:"
  outputComment "  ${0} --user=php79 --domain=php79.net"
  echo
  outputComment "  ${0} --user=phpmyadmin --domains=phpmyadmin.php79.net"
  echo
  outputComment "  ${0} --user=wordpress --domains=wordpress.php79.net"
  echo
  outputComment "  ${0} --user=nmail2 --domains='mail.php79.net mail.php79.co.kr'"
  echo

  echo
  echo "Usage:"

  echo -n "  "
  outputInfo  "--user"
  echo "      아이디(/etc/nginx/conf.d/아이디.conf).  ./user-add.sh 로 추가한 아이디를 입력하세요."
  echo "                Tip) 실제 시스템 계정과는 무관합니다.  아이디는 위 nginx 경로의 파일명과 일치하면 됩니다."
  echo

  echo -n "  "
  outputInfo  "--domain"
  echo "    도메인.  SSL 인증서 발급시 사용할 도메인으로 www. 없이 입력하세요."
  echo "                Tip) 발급시 www. 를 자동 추가하여 php79.net, www.php79.net 형태의 2개 도메인을 지원합니다."
  echo "                주의) mail.php79.net 형태의 www. 이 불필요한 경우는 --domains 를 사용해주세요."
  echo

  echo -n "  "
  outputInfo  "--domains"
  echo "    도메인들.  SSL 인증서 발급시 사용할 도메인으로 2개 이상은 공백으로 구분하여 입력할 수 있습니다."
  echo "                Tip) mail.php79.net 처럼 1개 서브 도메인만 추가 가능하며, 'mail.php79.net smtp.php79.net' 처럼 멀티 호스트 도메인도 가능합니다."
  echo "                Tip) 'mail.php79.net mail.php79.co.kr' 처럼 서로 다른 2개 이상의 멀티 도메인도 가능합니다."
  echo "                주의) 1개 인증서에는 최대 100개의 호스트명만 지원됩니다.  (https://letsencrypt.org/docs/rate-limits/)"
  echo "                주의) *.php79.net 형태의 와일드 카드 도메인은 지원하지 않습니다. (별도 DNS 인증 필요 - https://letsencrypt.org/docs/faq/)"
  echo

  echo -n "  "
  outputInfo  "--skip-nginx"
  echo "       (선택) nginx 설정을 생략하고, certbot-auto 로 SSL 인증서 발급만 진행합니다."
  echo "                Tip) 이미 nginx 설정이 완료된 상태이거나, 직접 수동 설정하실 경우에 사용하세요."
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
  INPUT_SKIP_NGINX=0
  for i in "${@}"
  do
    case $i in
    --user=*)
      shift
      INPUT_USER="${i#*=}"
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
    --skip-nginx)
      shift
      INPUT_SKIP_NGINX=1
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

if [ -z ${INPUT_DOMAIN} ] && [ -z ${INPUT_DOMAINS} ]; then
  input_abort "domain, domains 항목중 하나를 입력하세요."
fi

if [ -z ${INPUT_DOMAIN} ]; then
  input_abort "domain 항목을 입력하세요."
fi


outputComment "## Let's Encrypt SSL 인증서 발급을 시작합니다.\n\n"

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


NGINX_USER_CONF="/etc/nginx/conf.d/${INPUT_USER}.conf"
if [ ${INPUT_SKIP_NGINX} != "1" ]; then
  outputInfo "  - 수정할 Nginx config      : ${NGINX_USER_CONF}\n\n"

  if [ ! -f ${NGINX_USER_CONF} ]; then
    input_abort "${NGINX_USER_CONF} 설정 파일이 존재하지 않습니다."
  fi

  # 추가전 nginx server_name 체크
  #    domains -> server_name 이 다를 경우 직접 추가하도록 안내. (이미 별도 설정되어 있거나, 인지하지 못한 상황에서 의도치않게 바인딩될 수 있으므로 안됨.)
  outputInfo "     $(grep server_name ${NGINX_USER_CONF})\n\n"
  outputInfo "     * 추가할 도메인과 Nginx config 파일의 server_name 은 일치하거나, 와일드 카드(*)로 구성되어야 인증서 발급이 가능합니다.\n\n"
fi


# 추가전 nginx 설정 체크
if [ ${INPUT_SKIP_NGINX} != "1" ]; then
  outputComment "# nginx 설정 변경전, nginx 설정을 테스트합니다."
  echo
  /usr/sbin/nginx -t
  echo
  if [ "${?}" != "0" ]; then
    abort "nginx 설정에 문제가 있습니다."
  fi
fi

# nginx 설정 백업  (문자열 치환이 들어가므로 유실 가능성 고려해 백업)
NGINX_BACKUP_DIR="/etc/nginx/conf.d/backups"
if [ ! -d ${NGINX_BACKUP_DIR} ]; then
  mkdir ${NGINX_BACKUP_DIR}
fi
outputComment "# nginx 설정 변경전, 하위 backups 디렉토리로 설정을 백업합니다.\n"
cp -av ${NGINX_USER_CONF} "${NGINX_BACKUP_DIR}/${INPUT_USER}_$(date +%Y%m%d"_"%H%M%S)"
echo

outputComment "## [1/3] nginx - Let's Encrypt 인증용 디렉토리 접근 추가\n\n"
if [ ${INPUT_SKIP_NGINX} != "1" ]; then
  WELL_KNOWN_CONF="/etc/letsencrypt/php79/well-known.conf"
  grep ${WELL_KNOWN_CONF} ${NGINX_USER_CONF}
  if [ "${?}" != "1" ]; then
    outputComment "# nginx 에 다음 설정이 이미 추가되었으므로 생략합니다.\n    include ${WELL_KNOWN_CONF}\n\n"
  else
      outputComment "# nginx 설정의 첫번째 'root /home/...' 이전 라인에 다음 설정을 추가합니다.\n    include ${WELL_KNOWN_CONF}\n\n"
      sed -i "0,/[^[ \t]*root[ \t]*/ s/root/include \/etc\/letsencrypt\/php79\/well-known\.conf;\n    root/" ${NGINX_USER_CONF}
      outputComment "# nginx 설정 변경후, nginx 설정을 다시 테스트합니다.\n"
      /usr/sbin/nginx -t
      if [ "${?}" != "0" ]; then
        abort "nginx 설정에 문제가 있어 중단합니다.  에러를 확인하여 수정된 내용을 복구해주세요."
      fi

      # nginx 재시작
      outputComment "# nginx 를 재시작합니다.\n"
      echo
      if [ "$SYSTEMCTL" = "1" ]; then
        systemctl reload nginx
      else
        service nginx reload
      fi
  fi
else
  outputComment "# nginx 설정을 생략합니다. (--skip-nginx)\n"
fi
echo


outputComment "## [2/3] certbot-auto 로 SSL 인증서 발급 테스트후, 실제 인증서 발급\n\n"
if [ -z ${LETSENCRYPT_EMAIL} ]; then
  abort "stack.conf 에서 'LETSENCRYPT_EMAIL=이메일' 설정에 관리용 이메일 주소를 입력해주세요."
fi

LETSENCRYPT_PEM="/etc/letsencrypt/live/${INPUT_DOMAIN}/fullchain.pem"
if [ ! -f ${LETSENCRYPT_PEM} ]; then
  # 주의) 발급 테스트 과정을 생략하지 마세요.   실제 발급시 에러가 일정 횟수 이상 발생하면, 일정 기간 인증 시도가 차단됩니다.
  outputComment "# 인증서 발급 테스트를 시작합니다. (--dry-run)\n"
  cmd "certbot-auto certonly --webroot -w /var/www/letsencrypt/${CERTBOT_DOMAINS} -m ${LETSENCRYPT_EMAIL} --agree-tos -n --dry-run"

  outputComment "# 실제 인증서 발급을 시작합니다.\n"
  cmd "certbot-auto certonly --webroot -w /var/www/letsencrypt/${CERTBOT_DOMAINS} -m ${LETSENCRYPT_EMAIL} --agree-tos -n"
else
  outputComment "# 인증서가 존재하므로 발급을 생략합니다.\n"
  ls -l ${LETSENCRYPT_PEM}
fi
echo


outputComment "## [3/3] nginx 사이트 단위 설정 마지막에 SSL 설정 추가\n\n"
if [ ${INPUT_SKIP_NGINX} != "1" ]; then
  if [ ! -f ${LETSENCRYPT_PEM} ]; then
    abort "발급된 인증서가 없어서 nginx 설정을 중단합니다. -> ${LETSENCRYPT_PEM}"
  fi

  grep -P 'listen(.)*ssl' ${NGINX_USER_CONF}
  if [ "${?}" != "1" ]; then
    outputComment "# nginx 에 'listen ... ssl' 설정이 이미 추가되었으므로 생략합니다.\n"
  else
    outputComment "# nginx 설정의 마지막에 다음 설정을 추가합니다.\n\n"
    sed -e "s/_INPUT_DOMAIN_/${INPUT_DOMAIN}/g" "${STACK_ROOT}/letsencrypt/template-server.conf"
    echo

    # 마지막 } 문자를 #} 로 주석 처리
    tac ${NGINX_USER_CONF} | sed -e "0,/\}/s/\}/\n/" | tac > /tmp/php79-ssl-install-nginx
    cat /tmp/php79-ssl-install-nginx > ${NGINX_USER_CONF}
    rm -f /tmp/php79-ssl-install-nginx

    # 마지막에 SSL 설정 추가
    sed -e "s/_INPUT_DOMAIN_/${INPUT_DOMAIN}/g" "${STACK_ROOT}/letsencrypt/template-server.conf" >> ${NGINX_USER_CONF}
    echo "}" >> ${NGINX_USER_CONF}

    outputComment "# nginx 설정 변경후, nginx 설정을 다시 테스트합니다.\n"
    /usr/sbin/nginx -t
    if [ "${?}" != "0" ]; then
      abort "nginx 설정에 문제가 있어 중단합니다.  에러를 확인하여 수정된 내용을 복구해주세요."
    fi

    # nginx 재시작
    outputComment "# nginx 를 재시작합니다.\n"
    echo
    if [ "$SYSTEMCTL" = "1" ]; then
      systemctl reload nginx
    else
      service nginx reload
    fi
  fi
else
  outputComment "# nginx 설정을 생략합니다. (--skip-nginx)\n"
fi
echo


outputComment "### Let's Encrypt SSL 인증서 발급이 완료되었습니다. ###\n\n"

if [ ${INPUT_SKIP_NGINX} != "1" ]; then
  outputInfo "  - 수정된 Nginx config      : ${NGINX_USER_CONF}\n\n"
fi

if [ -z "${INPUT_DOMAINS}" ]; then
  outputInfo "  - SSL 인증서 확인      : curl -Iv https://${INPUT_DOMAIN}\n"
  sleep 1
#  curl -Iv "https://${INPUT_DOMAIN}"
  curl -Iv "https://${INPUT_DOMAIN}" 2>&1 | grep -E 'Connected|subject|start date|expire date|common name|issuer|^HTTP'
  echo
else
  sleep 1;
  for i in "${INPUT_DOMAINS_ARRAY[@]}"
  do
    outputInfo "  - SSL 인증서 확인      : curl -Iv https://${i}\n"
#    curl -Iv "https://${i}"
    curl -Iv "https://${i}" 2>&1 | grep -E 'Connected|subject|start date|expire date|common name|issuer|^HTTP'
    echo
  done
fi
