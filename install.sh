#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/includes/function.inc.sh"

cd ${STACK_ROOT}

### PHP base version check
PHP_BASE_INSTALL=PHP$PHP_BASE
if [ ${!PHP_BASE_INSTALL} = "0" ]; then
  abort "PHP_BASE=${PHP_BASE} 설정을 위해서는 PHP 7.0 을 설치해야 합니다.  (PHP70=1)";
fi

### Welcome
welcome

### Main
outputComment "Install options:\n"
options
echo
if [ "$INTERACTIVE" = "1" ]; then
  outputQuestion "Do you want to install? (위 패키지들을 설치하시겠습니까?) [n/Y]"
  read -p " " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
     abort
  fi
fi

### Init
cmd_once "scripts/init.sh"

### Disable SELinux
cmd_once "scripts/selinux-disable.sh"

### Time zone
cmd_once "scripts/timezone.sh ${TIMEZONE}"

### Nginx
if [ $NGINX = "1" ]; then
  cmd_once "scripts/nginx-install.sh"
fi

### Let's Encrypt 자동화툴
if [ $LETSENCRYPT = "1" ]; then
  cmd_once "scripts/letsencrypt-install.sh"
fi

### PHP
PHP_INSTALLED=
if [ "$OS" != "rocky8" ]; then
  if [ $PHP53 = "1" ]; then
    if [ $OS = "centos7" ]; then
      #cmd_once "scripts/mariadb-repo-install.sh"
      cmd_once "scripts/centos7-php53-install.sh"
    else
      cmd_once "scripts/centos6-php53-install.sh"
    fi
    PHP_INSTALLED=53
  fi

  if [ $PHP54 = "1" ]; then
    cmd_once "scripts/remi-repo-install.sh"
    cmd_once "scripts/php5-remi-install.sh 54"
    PHP_INSTALLED=54
  fi

  if [ $PHP55 = "1" ]; then
    cmd_once "scripts/remi-repo-install.sh"
    cmd_once "scripts/php5-remi-install.sh 55"
    PHP_INSTALLED=55
  fi
fi

if [ $PHP56 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php5-remi-install.sh 56"
  PHP_INSTALLED=56
fi

if [ $PHP70 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php7-remi-install.sh 70"
  PHP_INSTALLED=70
fi

if [ $PHP71 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php7-remi-install.sh 71"
  PHP_INSTALLED=71
fi

if [ $PHP72 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php7-remi-install.sh 72"
  PHP_INSTALLED=72
fi

if [ $PHP73 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php7-remi-install.sh 73"
  PHP_INSTALLED=73
fi

if [ $PHP74 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php7-remi-install.sh 74"
  PHP_INSTALLED=74
fi

if [ $PHP80 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php8-remi-install.sh 80"
  PHP_INSTALLED=80
fi

if [ $PHP81 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php8-remi-install.sh 81"
  PHP_INSTALLED=81
fi

if [ $PHP82 = "1" ]; then
  cmd_once "scripts/remi-repo-install.sh"
  cmd_once "scripts/php8-remi-install.sh 82"
  PHP_INSTALLED=82
fi

### /usr/bin/php link
if [ ! $PHP_INSTALLED = "" ]; then
  if [ $OS = "centos7" ]; then
    cmd "scripts/php-cli-version-set.sh ${PHP_BASE}"
  else
    if [ ! ${PHP_BASE} = "53" ]; then
      cmd "scripts/php-cli-version-set.sh ${PHP_BASE}"
    fi
  fi
fi

### PHP composer
if [ ! $PHP_INSTALLED = "" ]; then
  cmd_once "scripts/php-composer-install.sh"
fi

### Physical Server
if [ $SMARTD = "1" ]; then
  cmd_once "scripts/smartd-install.sh"
fi

if [ $SENSORS = "1" ]; then
  cmd_once "scripts/lm-sensors-install.sh"
fi

### Development Tools
if [ $DEV_TOOLS = "1" ]; then
  cmd_once "scripts/dev-tools-install.sh"
fi


### MariaDB
if [ $MARIADB = "1" ]; then
  cmd_once "scripts/mariadb-repo-install.sh"
  cmd_once "scripts/mariadb-install.sh ${MARIADB_RAM}"

  # MariaDB root password
  if [ ! -f "locks/mariadb_set_root_password" ]; then
    title "MariaDB root 비밀번호를 자동 생성합니다."
    #if [ "$INTERACTIVE" = "1" ]; then
    #  mariadb_set_root_password
    #else
      MARIADB_ROOT_PASSWORD=$(scripts/password-generate.sh)
      /usr/bin/mysqladmin password "${MARIADB_ROOT_PASSWORD}"

      if [ "${?}" != "0" ]; then
        echo
        outputError "MariaDB root 비밀번호 설정이 실패하였습니다."
        echo
      fi

      echo "[client]
password=${MARIADB_ROOT_PASSWORD}" > /root/.my.cnf
      chmod -v o-rwx /root/.my.cnf

      notice "Your MariaDB root password saved \"/root/.my.cnf\"\n  (자동 생성된 MariaDB root 비밀번호는 \"/root/.my.cnf\" 파일에도 저장되었습니다.)"
      echo "  Password : ${MARIADB_ROOT_PASSWORD}"
      echo "  Change Password) mysqladmin -p'${MARIADB_ROOT_PASSWORD}' password"
      echo

    #fi
    touch "locks/mariadb_set_root_password"
  fi
fi

### End
echo
outputInfo "Thanks for php79 stack installing.  (설치가 완료되었습니다.)"
echo
outputInfo "Visit http://127.0.0.1 or http://ServerIP"
echo


### Result
if [ "$INTERACTIVE" = "1" ]; then
  echo
  outputQuestion "Check the installation status? (설치 상태를 확인하시겠습니까?) [Y/n]"
  read -p " " -r
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    cmd "${STACK_ROOT}/status.sh"
  fi
fi
