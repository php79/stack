#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

PHP_VERSION=${1}

title "PHP ionCube loader 모듈을 설치합니다."

if [ -z ${PHP_VERSION} ]; then
  if [ "$OS" = "rocky8" ]; then
    abort "설치할 PHP 버전을 입력하세요.  56, 70, 71, 72, 73, 74, 80, 81, 82, 83, 84"
  else
    abort "설치할 PHP 버전을 입력하세요.  53, 54, 55, 56, 70, 71, 72, 73, 74, 80, 81, 82, 83"
  fi
fi

# 미지원 버전은 설치지 패키지가 없는 것으로 확인되도록, 소스단 제한은 주석 처리
#if [ ${PHP_VERSION} = "71" ]; then
#  abort "[2017-02-01] 기준, PHP 7.1 로더는 아직 출시되지 않았습니다."
#fi

PHP_CLI="/usr/bin/php${PHP_VERSION}"
if [ ! -f ${PHP_CLI} ]; then
  abort "해당 PHP 버전이 설치되지 않았습니다.  ${PHP_CLI}"
fi

# 로더 설치 여부
function extension_loaded
{
  echo $(${PHP_CLI} -r 'echo (int)extension_loaded("ionCube Loader");')
}

if [ $(extension_loaded) = "1" ]; then
  ${PHP_CLI} -v

  abort "PHP ionCube loader 모듈이 이미 설치되어 있습니다."
fi

if [ ${PHP_VERSION} = "53" ]; then
  # CentOS 6 RPM 설치, CentOS 7 컴파일 설치시엔 수동 설치
  EXTENSION_DIR=$(${PHP_CLI} -r 'echo ini_get("extension_dir");')
  notice "https://www.ioncube.com/loaders.php 에서 로더를 다운 받아, ${EXTENSION_DIR}/ioncube_loader.so 경로로 설치합니다."
  if [ $OS = "centos7" ]; then
    LOADER_INI=/usr/local/php53/etc/php.d/01-ioncube_loader.ini
    cd ${EXTENSION_DIR} \
    && curl -O http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar zxf ioncube_loaders_lin_x86-64.tar.gz ioncube/ioncube_loader_lin_5.3.so \
    && mv -f ioncube/ioncube_loader_lin_5.3.so ioncube_loader.so \
    && rmdir ioncube \
    && rm -f ioncube_loaders_lin_x86-64.tar.gz \
    && echo "; Enable ioncube_loader extension module
zend_extension = ${EXTENSION_DIR}/ioncube_loader.so
" > ${LOADER_INI} \
    && systemctl restart "php${PHP_VERSION}-php-fpm"
  else
    LOADER_INI=/etc/php.d/01-ioncube_loader.ini
    cd ${EXTENSION_DIR} \
    && curl -O http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar zxf ioncube_loaders_lin_x86-64.tar.gz ioncube/ioncube_loader_lin_5.3.so \
    && mv -f ioncube/ioncube_loader_lin_5.3.so ioncube_loader.so \
    && rmdir ioncube \
    && rm -f ioncube_loaders_lin_x86-64.tar.gz \
    && echo "; Enable ioncube_loader extension module
zend_extension = ${EXTENSION_DIR}/ioncube_loader.so
" > ${LOADER_INI} \
    && service php-fpm restart
  fi
  notice "${EXTENSION_DIR} 설정이 추가되었고, PHP FPM 서비스가 재시작되었습니다."
else
  # REMI 저장소 사용
  notice "REMI 저장소를 사용하여, php${PHP_VERSION}-php-ioncube-loader 모듈을 설치합니다."
  yum_install "php${PHP_VERSION}-php-ioncube-loader"
  if [ "$SYSTEMCTL" = "1" ]; then
    systemctl restart "php${PHP_VERSION}-php-fpm"
  else
    service "php${PHP_VERSION}-php-fpm" restart
  fi
  notice "PHP FPM 서비스가 재시작되었습니다."
fi

if [ $(extension_loaded) = "1" ]; then
  echo
  outputInfo "PHP ionCube loader 모듈이 설치되었습니다."
  echo
  ${PHP_CLI} -v
else
  ${PHP_CLI} -v

  abort "PHP ionCube loader 모듈이 정상적으로 설치되지 않았습니다."
fi
