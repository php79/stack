#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/includes/function.inc.sh"

title "PHP Composer 를 설치합니다."

if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | /usr/bin/php && mv composer.phar /usr/local/bin/composer
fi
