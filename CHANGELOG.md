# php79 stack 변경 내역

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
