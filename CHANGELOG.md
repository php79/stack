# php79 stack 변경 내역

## develop

### Added
- app-install.sh 에서 --skip-install 옵션을 추가하여 앱 자동 설치만 제외할 수 있도록 개선함 https://github.com/php79/stack/issues/4

### Fixed
- status.sh 실행 속도 개선 및 서비스별 설정을 구분하여 표시하도록 개선 https://github.com/php79/stack/issues/22
- 시간 동기화 명령인 ntpdate 실패(대부분 방화벽 차단, DNS 이슈)시에도 경고만 보여지고 설치가 진행되도록 개선 https://github.com/php79/stack/issues/31
- cpu core 수가 2개 인 경우, nginx.conf 의 worker_processes 가 0 으로 잘못 설정되던 오류 수정 

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
