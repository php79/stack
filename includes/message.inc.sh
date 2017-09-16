#!/usr/bin/env bash

# Copyright:: Copyright (c) 2016 Been Kyung-yoon (http://www.php79.com/)
# License:: The MIT License (MIT)


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NO_COLOR='\033[0m'

function outputInfo
{
  printf "${GREEN}${1}${NO_COLOR}"
}

function outputComment
{
  printf "${YELLOW}${1}${NO_COLOR}"
}

function outputQuestion
{
  printf "\033[30;46m${1}${NO_COLOR}"
}

function outputError
{
  printf "\033[0;41m${1}${NO_COLOR}"
}

function abort
{
  if [ ! "${@}" = "" ]; then
    echo
    outputError "${@}"
    echo
  fi
  echo
  outputError "Exiting installer. (설치를 중단합니다.)\n"
  exit 1
}

function title
{
  echo
  outputComment "### $@ ###"
  echo
  echo
}

function notice
{
  echo
  outputInfo "Notice) $@"
  echo
  echo
}

function error
{
  echo
  outputError "Error) $@"
  echo
  echo
}
