#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_VERSION=$(cat "${STACK_ROOT}/.app_version")

source "${STACK_ROOT}/includes/message.inc.sh"


### Config
source "${STACK_ROOT}/stack.defaults.conf"


if [ ! -f "${STACK_ROOT}/stack.conf" ]; then
  notice "Check stack.conf (설치 옵션은 stack.conf 파일을 열어 수정하시면 됩니다.)"
  echo -n "  copy: "
  cp -av "${STACK_ROOT}/stack.defaults.conf" "${STACK_ROOT}/stack.conf"
  echo
fi

source "${STACK_ROOT}/stack.conf"



### OS detect
OS=
if [ -f /etc/centos-release ]; then
  RELEASE_VERSION=`grep -o 'release [0-9]\+' /etc/centos-release`
  if [ "$RELEASE_VERSION" = "release 7" ]; then
    OS=centos7
  elif [ "$RELEASE_VERSION" = "release 6" ]; then
    OS=centos6
  else
    echo "Only CentOS 6/7. (CentOS 6/7 버전만 지원됩니다.)"
    echo -n "Current version: " && cat /etc/centos-release
    abort
  fi
else
  echo "Only CentOS 6/7. (CentOS 6/7 버전만 지원됩니다.)"
  abort
fi


### Functions

FUNC_RESULT=


# 실행시 에러가 존재할 경우 중단
CMD_EXIT_CODE=
function cmd
{
  #printf "${GREEN}run# ${1}${NO_COLOR}\n"
  eval ${1}
  CMD_EXIT_CODE=${?}
  if [ ${CMD_EXIT_CODE} != "0" ]; then
    outputError "다음 명령이 실패하여, 설치가 중단되었습니다. (exit code: ${CMD_EXIT_CODE})"
    printf "\n"
    outputError "# ${1}"
    printf "\n"
    exit 1
  fi
}

# 명령을 파일로 남길 수 있도록 특수 문자 제거
function escape_path()
{
   printf '%s' "${1}" | sed -e 's/[ \\\/^*+$]/\_/g'
}

# 성공한 경우 1회만 실행하여, 중복 실행 방지
function cmd_once
{
  LOCK="locks/$(escape_path "${1}")"
  if [ ! -f "${LOCK}" ]; then
    cmd "${1}"

    if [ ${CMD_EXIT_CODE} = "0" ]; then
      touch "${LOCK}"
    fi
  fi
}

function welcome_short
{
  echo
  outputInfo "php79 stack"
  printf " version "
  outputComment "${STACK_VERSION}\n"
}


function welcome
{
  welcome_short
  echo "  * PHP 5.3-7.3 + Nginx + Let's Encrypt + MariaDB installer"
  echo
}

function options
{
  printf "  - Install ${GREEN}EPEL repo${NO_COLOR} / http://fedoraproject.org/wiki/EPEL\n"

  if [ $PHP73 = "1" ]; then
    printf "  - Install ${GREEN}PHP 7.3${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
  fi

  if [ $PHP72 = "1" ]; then
    printf "  - Install ${GREEN}PHP 7.2${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
  fi

  if [ $PHP71 = "1" ]; then
    printf "  - Install ${GREEN}PHP 7.1${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
  fi

  if [ $PHP70 = "1" ]; then
    printf "  - Install ${GREEN}PHP 7.0${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
  fi

  if [ $PHP56 = "1" ]; then
    printf "  - Install ${GREEN}PHP 5.6${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
  fi

  if [ $PHP55 = "1" ]; then
    printf "  - Install ${GREEN}PHP 5.5${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
    printf "      ${YELLOW}PHP 5.5 have reached its \"End of Life\".${NO_COLOR} http://php.net/supported-versions.php\n"
  fi

  if [ $PHP54 = "1" ]; then
    printf "  - Install ${GREEN}PHP 5.4${NO_COLOR} from Remi repo / http://rpms.famillecollet.com/\n"
    printf "      ${YELLOW}PHP 5.4 have reached its \"End of Life\".${NO_COLOR} http://php.net/supported-versions.php\n"
  fi

  if [ $PHP53 = "1" ]; then
    if [ ${OS} = "centos7" ]; then
      printf "  - Install ${GREEN}PHP 5.3${NO_COLOR} / Source compile\n"
    else
      printf "  - Install ${GREEN}PHP 5.3${NO_COLOR} from Base repo\n"
    fi
    printf "      ${YELLOW}PHP 5.3 have reached its \"End of Life\".${NO_COLOR} http://php.net/supported-versions.php\n"
  fi

  echo "  - Set PHP CLI version ( /usr/bin/php ) : $PHP_BASE"

  if [ $NGINX = "1" ]; then
    printf "  - Install ${GREEN}Nginx 1.10${NO_COLOR} from Nginx repo (stable) / http://nginx.org/en/linux_packages.html\n"
  fi

  if [ $LETSENCRYPT = "1" ]; then
    printf "  - Install ${GREEN}Let's Encrypt tools${NO_COLOR} (certbot-auto + configs) / https://certbot.eff.org/\n"
  fi

  if [ $MARIADB = "1" ]; then
    printf "  - Install ${GREEN}MariaDB 10.1${NO_COLOR} from MariaDB repo (stable) / https://mariadb.com/kb/en/mariadb/yum/\n"

    if [ ! -z $MARIADB_RAM ]; then
      printf "      Use memory config : ${YELLOW}${MARIADB_RAM}${NO_COLOR}\n"
    fi
  fi

  if [ $SMARTD = "1" ]; then
    echo "  - Install smartmontools (physical server only)"
  fi

  if [ $SENSORS = "1" ]; then
    echo "  - Install lm_sensors (physical server only)"
  fi

  if [ $DEV_TOOLS = "1" ]; then
    echo "  - Install developer tools (wget, rsync, nslookup, ...)"
  fi

  if [ ! -z $TIMEZONE ]; then
    printf "  - Change time zone ${YELLOW}${TIMEZONE}${NO_COLOR} for /etc/localtime, php.ini\n"
  fi

  if [ $INTERACTIVE = "1" ]; then
    echo "  - Interactive mode"
  fi
}

function usage
{
  welcome
  echo "Select options from stack.conf:"
  options
  echo
  echo "See http://www.php79.com for documents, updates."
}

function yum_install
{
  is_installed $@
  if [ $FUNC_RESULT = "1" ]; then
    #echo "Already installed. -> $@"
    echo -n
  else
    yum -y install $@
  fi
}

function is_installed
{
  for i in "$@"
  do
    RESULT=`yum -C --noplugins -q list installed $i 2> /dev/null`
    if [[ ! $RESULT == *"$i"* ]]; then
      FUNC_RESULT=0
      return
    fi
  done

  FUNC_RESULT=1
}

# 특수 문자(/)를 sed 사용을 위해 (//)로 치환.  단 echo 반환하면 안되므로 전역 변수로 고정
STRING_QUOTE=
function string_quote
{
  QUOTE=\\\\
  STRING_QUOTE=`echo ${@} | sed "s/\//"${QUOTE}"\//g"`
}

# mysql 비밀번호 입력을 일단 생략하고, 자동 설치후 변경 권장
MARIADB_SET_ROOT_PASSWORD=
function mariadb_set_root_password
{
  if [[ `/usr/bin/mysqladmin ping` = "mysqld is alive" ]]; then
    echo
    stty -echo
    status=1
    while [ $status -eq 1 ]; do
      outputQuestion "Set MariaDB root password! (MariaDB root 비밀번호를 지정하세요!) :"
      read -p " " -r
      if [ "${REPLY}" = "" ]; then
        echo
        echo
        outputError "Warning) You can't use an empty password here. (빈 비밀번호는 사용할 수 없습니다.)"
        echo
        echo
      elif [ ! ${#REPLY} -gt 8 ]; then
        echo
        echo
        outputError "Warning) BAD PASSWORD: it is WAY too short. (비밀번호는 8자리 이상으로 입력해주세요)"
        echo
        echo
      else
        /usr/bin/mysqladmin password '$REPLY'
        status=0
      fi
    done
    stty echo
  else
    abort "MariaDB 가 실행되지 않아, root 비밀번호를 지정할 수 없습니다."
  fi

  MARIADB_SET_ROOT_PASSWORD=1
}
