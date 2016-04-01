# php79 stack

> Nginx, PHP 5.3 ~ 7.0, MariaDB 를 한번에 설치합니다.


## 특징

- 쉽게 빠른 설치, 운영, 업데이트까지 고려한 설계
- 쉬운 업데이트 지원.  (공식+인기 저장소를 사용하여 `yum update` 만으로 완료)
- 기본 설정 파일의 수정을 최소화하여 혼란 예방.  (주요 설정 내용을 z-php.ini 형태의 외부 파일로 분리)
- PHP 5.3, 5.4, 5.5, 5.6, 7.0 5가지 버전을 지원하며, 하나의 서버에서 2개 이상의 PHP 사용 가능.
- 시스템 계정, 디비 계정 자동 생성 지원.  ([user-add.sh](user-add.sh))
- Laravel, WordPress, XE, 그누보드, phpMyAdmin 자동 설치 지원.  ([app-install.sh](app-install.sh))

> 요약: 더 이상 설치에 시간을 낭비하지 마시고, 여러분의 코딩과 업무에 집중하세요! :)


## 설치 방법

> CentOS 6/7 만 지원됩니다.

```bash
cd /root/ \
&& git clone https://github.com/php79/stack.git \
&& cd stack \
&& ./install.sh
```

- 기본 설치 옵션은 **PHP 7.0** + Nginx + MariaDB 입니다.
 - 설치 화면에서 'y'만 누르면 바로 설치가 진행됩니다.

- **PHP 5.3** 등 다른 버전을 설치하시겠습니까?
 - 설치화면에서 'n'를 누르고 중단합니다.
 - 그리고 `stack.conf` 파일을 열어 `PHP53=1` 으로 활성화시켜주고, 다시 `./install.sh` 를 실행하면 됩니다.

- `./install.sh` 는 중복 실행해도 문제없도록 설계되었습니다.
 - 따라서 PHP 7.0 만 설치했다가 차후, PHP 5.3 , 5.4 등을 추가로 설치하실 수 있습니다.

- 설치시 git 명령이 없다고 에러가 발생합니까?
 -  `yum install git`으로 먼저 설치해주시면 됩니다.


## 주요 명령

- 먼저 stack 디렉토리로 이동합니다.

```bash
cd /root/stack
```

- 설치된 PHP 버전, 설정 파일 경로, 실행 여부, 서비스 재시작 명령 등의 모든 상태 정보를 확인할 수 있습니다.

```bash
./status.sh
```

- Laravel, WordPress, XE, 그누보드, phpMyAdmin 자동 설치를 지원합니다.
 - 시스템 계정, 디비 계정, 웹서버 설정, 앱 자동 설치까지 모두 한 번에 이루어 집니다.

```bash
./app-install.sh --user=php79 --password='php79!@' --domain=php79.com --app=laravel51 --php=70
```

```bash
./app-install.sh --user=wordpress --password='php79!@' --domain=wordpress.php79.com --app=wordpress --php=70
```

- 기존 사이트 이전이나 수동 설치를 위해, 시스템 계정, 디비 계정만 생성할 수 있습니다.

```bash
./user-add.sh --user=php79 --password='php79!@'
```

> 경고) 비밀번호는 반드시 변경하여 사용하세요.  특히 시스템 계정(SSH/SFTP)이 생성되므로, 단순한 비밀번호는 절대 안됩니다!!!


## 설치시 사용되는 yum 외부 저장소 목록

- EPEL    http://fedoraproject.org/wiki/EPEL
- Remi    http://rpms.famillecollet.com/
- Nginx   http://nginx.org/en/linux_packages.html
- MariaDB https://mariadb.com/kb/en/mariadb/yum/


## 설치 내역

- PHP 5.3, 5.4, 5.5, 5.6, 7.0
 - 단, CentOS 7 의 PHP 5.3 공식 저장소가 없어, 소스 컴파일 설치됩니다.
 - composer 설치

- Nginx 1.8


- MariaDB 10.1
 - utf8mb4 인코딩 기본 지원.  (모바일에서 이모티콘 저장이 잘 됩니다.)
 - 사용 메모리 최적화 설정 지원. (기본 4G)
 - 초기 root 비밀번호 자동 생성

- 서버 초기 셋팅
 - ntp 시간 자동 동기화.   (미래나 과거 날짜가 보여지는 문제는 이제 그만!)
 - SELinux 비활성화.
 - 타임존 설정.
 - S.M.A.R.T. 디스크 모니터링 smartd 설치. (선택가능)
 - 하드웨어 센서 모니터링 sensors 설치. (선택가능)
 - 서버 필수 유틸과 점검툴들 설치. (선택가능, rsync wget openssh-clients bind-utils git telnet nc vim-enhanced man
    ntsysv htop glances iotop iftop sysstat strace lsof mc lrzsz zip unzip bzip2)


## 방화벽 설정은 지원하지 않으므로, 수작업이 필요합니다.

- iptables 설정 방법: http://www.php79.com/59
- TODO: firewalld 설정 방법: (준비중입니다.)


## License

[The MIT License (MIT)](LICENSE.md)

라이선스 한글 번역본 - http://www.olis.or.kr/ossw/license/license/detail.do?lid=1006
