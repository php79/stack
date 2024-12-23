# php79 stack 변경 내역

## v1.5.0 (2024-11-17)

### Added
- PHP 8.3 , 8.4 설치 추가 https://github.com/php79/stack/issues/109
  - PHP 8.4 는 Rocky Linux 8 에서만 지원
- stack.defaults.conf 설정 추가 
  - PHP_MODULES_72, PHP_MODULES_80 - PHP 버전별로 설치할 모듈 직접 정의 가능
  - YUM_INSTALL_QUIET=1 - YUM(DNF) 패키지 설치시 상세 출력 생략
- Rocky Linux 8, rsyslog 설치하여 /var/log/messages 로그 기록 지원
- app-install.sh default(앱 미선언시 기본값), laravel 앱 템플릿 추가
  - PHP 버전 미선언시 /usr/bin/php 버전 사용
- SSL 설정에 ssl-hosting.conf 추가
  - ssl-stable.conf 에서 HSTS 옵션만 끄기 (호스팅 서비스 등 고려)

### Fixed
- Nginx 1.25.1 이상 버전의 http2 on 설정 분기 지원 https://github.com/php79/stack/issues/110
- yum 패키지 설치 실패시 중단하여 오류 원인 쉽게 파악 가능하도록 함
- CentOS 7 에서 MariaDB MaxScale 저장소 오류가 있어 제외
- 설치 과정에서 화면 출력 최소화
    - 설치 프로그램에서 이미 설치된 프로그램은 안내 생략 (locks/ 파일 존재 여부로 확인)

## v1.4.0 (2023-11-23)

### Added
- MariaDB 설치 버전 선택 기능 추가.  10.6, 10.11  https://github.com/php79/stack/issues/99
  - MariaDB 기본 설치 버전을 10.6 (LTS) 에서 10.11 (LTS) 으로 변경
  - 단, 설치 버전 선택은 CentOS 7, Rocky Linux 8 에서만 지원.  CentOS 6 은 기존 10.6 유지
  - [기존 사용자들의 업그레이드 안내](https://github.com/php79/stack/issues/48#issuecomment-502039804)

## v1.3.2 (2023-02-22)

### Fixed
- ssl-install.sh 에서 --domain 옵션 사용시 에러 수정 (v1.3.0 --domains 옵션 추가시 발생)

## v1.3.1 (2023-02-11)

### Fixed
- MariaDB 의 RPM GPG KEY 갱신 https://github.com/php79/stack/issues/96

## v1.3.0 (2023-02-06)

### Added
- Rocky Linux 8 지원 (PHP 5.6 부터 지원. 5.3 ~ 5.5 미지원) https://github.com/php79/stack/issues/90
  - Rocky Linux 8 차이점 https://github.com/php79/stack/wiki/Rocky-Linux-8-%EC%B0%A8%EC%9D%B4%EC%A0%90
- SSL 인증서 발급시 --domains= 옵션 추가하여, 서브 도메인 1개 및 멀티 호스트 지원 https://github.com/php79/stack/issues/71
- phpMyAdmin 설치 오류 개선 및 보안 강화 https://github.com/php79/stack/issues/94

### Fixed
- PHP, Nginx, MariaDB 설치하지 않아도 에러 없도록 개선 (DB 서버, 타 서비스 용도)
  - PHP 미설치시 오류 개선 https://github.com/php79/stack/issues/61
  - PHP 미설치시 오류 개선 https://github.com/php79/stack/issues/60

## v1.2.4 (2022-12-06)

### Added
- PHP 8.2 설치 추가 https://github.com/php79/stack/issues/93

## v1.2.3 (2022-07-20)

### Added
- PHP 8.1 설치 추가 https://github.com/php79/stack/issues/89
- MariaDB 10.4 에서 10.6 (LTS) 으로 기본 설치 변경. https://github.com/php79/stack/issues/82 / [기존 사용자들의 업그레이드 안내](https://github.com/php79/stack/issues/48#issuecomment-502039804)

## v1.2.2 (2021-10-29)

### Fixed
- nginx 최신 버전에서 소유자가 nginx 에서 nobody 로 변경됨에 따라, 일괄 변환하는 nginx-to-nobody.sh 스크립트 추가.  https://github.com/php79/stack/issues/86

## v1.2.1 (2021-01-14)

### Fixed
- certbot 최신 버전의 CentOS 지원 중단에 따라, 지원가능한 1.10.1 버전을 설치하도록 변경.  https://github.com/php79/stack/issues/83

## v1.2.0 (2020-11-30)

### Added
- PHP 8.0 설치 추가 

## v1.1.0 (2019-11-30)

### Added
- PHP 7.4 설치 추가 
- PHP 기본 설치 버전을 7.1 에서 7.4 로 변경
- MariaDB 10.3 에서 10.4 으로 기본 설치 변경. [기존 사용자들의 업그레이드 안내](https://github.com/php79/stack/issues/48#issuecomment-502039804)
- Laravel 6 설치 추가
- Laravel nginx 설정에 PHP 에서 image.jpg 등 의 리소스 출력을 위한 try_files 추가 https://github.com/php79/stack/issues/68

### Fixed
- SSL 인증서 발급시, LETSENCRYPT_EMAIL 미입력시 오류가 보이지 않던 문제 개선

## v1.0.0 (2019-06-14)

### Added
- Let's Encrypt 설치, 인증서 발급, 인증서 자동 갱신 지원 (ssl-install.sh)
- PHP 7.3 설치 추가 
- PHP 기본 설치 버전을 7.0 에서 7.1 로 변경
- PHP 7.0 이상 기본 확장 모듈 설치시 bcmath, pecl-zip 기본 지원
- MariaDB 10.1 에서 10.3 으로 기본 설치 변경. [기존 사용자들의 업그레이드 안내](https://github.com/php79/stack/issues/48#issuecomment-502039804)
- Laravel 5.6 ~ 5.8 설치 추가

### Fixed
- app-install.sh 에서 domain, app, php 잘못 지정시에도 user-add.sh가 먼저 실행되던 현상 개선하여 오류 가능성 낮춤

## v0.9.12 (2017-09-16)

### Added
- app-install.sh 에서 --skip-install 옵션을 추가하여 앱 자동 설치만 제외할 수 있도록 개선함 https://github.com/php79/stack/issues/4
- app-install.sh 에서 비밀번호 자동생성 기능 추가
- 보안 강화를 위해, 비밀번호 자동생성 기본 길이를 12자에서 32자로 늘림
- app-install.sh 에서 Laravel 5.4, 5.5 설치 추가
- PHP 7.2 설치 추가

### Fixed
- status.sh 실행 속도 개선 및 서비스별 설정을 구분하여 표시하도록 개선 https://github.com/php79/stack/issues/22
- 시간 동기화 명령인 ntpdate 실패(대부분 방화벽 차단, DNS 이슈)시에도 경고만 보여지고 설치가 진행되도록 개선 https://github.com/php79/stack/issues/31
- cpu core 수가 2개 인 경우, nginx.conf 의 worker_processes 가 0 으로 잘못 설정되던 오류 수정
- self-update.sh 실행전과 후에 nginx 설정 테스트 추가 https://github.com/php79/stack/issues/5

## v0.9.11 (2017-02-01)

### Added
- PHP 7.1 설치 지원 https://github.com/php79/stack/issues/23
 - 기존 사용자들이 PHP 7.1 만 추가로 설치하는 방법 - https://github.com/php79/stack/wiki/php-71-install
- PHP 7.0 ionCube loader 설치 지원

### Fixed
- ionCube loader 설치후 php-fpm 재시작 지원 https://github.com/php79/stack/issues/17

## v0.9.10 (2016-10-02)

### Added
- Laravel 5.3 설치 추가
- PHP FPM 소유자/그룹 자동 변경 스크립트 https://github.com/php79/stack/wiki#yum-%EC%97%85%EB%8D%B0%EC%9D%B4%ED%8A%B8%EC%8B%9C-%EC%A3%BC%EC%9D%98%EC%82%AC%ED%95%AD

### Fixed
- yum update 이후 PHP FPM 소유자/그룹 문제 해결 https://github.com/php79/stack/issues/12
- 일부 서버에서 ntpdate 실행 오류 보완 https://github.com/php79/stack/issues/13 

## v0.9.9 (2016-04-04)

- 공식 배포 
