#!/bin/bash

# ----------------------------------------------------------------
# Bash Aliases - Cross Platform Aliases and Source Logic
# ----------------------------------------------------------------

# shellcheck disable=SC1090

# Lazy Git
alias gg="lazygit"

# Networking
alias n.online="ping -c 3 8.8.8.8"

# Vagrant
alias b.status='vagrant global-status'

# Editing
alias v.alias="vi ~/.bash_aliases"
alias v.alias_osx="vi ~/.bash_aliases.osx"
alias v.env="vi ~/.bash_env"
alias v.path="vi ~/.bash_path"
alias v.profile="vi ~/.bash_profile"
alias v.rc="vi ~/.bashrc"

# File Utils
alias f.clean="find . -name '.DS_Store'  -exec rm {} \;"

# Column Manipulation Shortcuts
# shellcheck disable=SC2139,SC2140
for i in {1..10}; do alias "a${i}"="awk '{ print \$${i} }'"; done
# shellcheck disable=SC2139,SC2140
for i in {1..10}; do alias "c${i}"="cut -d, -f ${i}"; done

# White Space Remover
function trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
  echo -n "$var"
}

# SSL Shortcuts
function s.date() {
	PORT=${2:-443}	
	HOST=${1}	
	echo | openssl s_client -servername "${HOST}" -connect "${HOST}":"${PORT}" 2>/dev/null | openssl x509 -noout -dates
}

# Docker Shortcuts

function d.quickey() {
  docker run -it --name "${1}" "${2}" sh
}

function d.rm() {
  containers="$(docker ps -qa)"
  [[ -z "${containers}" ]] && echo "No containers to remove." && return 1
  for container in ${containers}; do docker rm "$container"; done
}

function d.rmi() {
  images="$(docker images -q)"
  [[ -z "${images}" ]] && echo "No images to remove." && return 1
  for image in ${images}; do docker rmi "$image"; done
}

function d.clean() {
  images="$(docker images | grep none | awk '{print $3}')"
  [[ -z "${images}" ]] && echo "No images to remove." && return 1
  for image in ${images}; do docker rmi "$image"; done
}

function d.stop() {
  containers="$(docker ps -q)"
  [[ -z "${containers}" ]] && echo "No containers to stop." && return 1
  for container in ${containers}; do docker rm "$container"; done
}

function d.start() {
  containers=$(docker ps -qa)
	[[ -z "${containers}" ]] && echo "No containers to stop." && return 1
  for container in ${containers}; do docker rm "$container"; done
}


function d.status() {
  docker ps -a
}


function d.kill() {
	containers="$(docker ps -q)"
	[[ -z "${containers}" ]] && echo "No containers to stop." && return 1
  for container in ${containers}; do docker rm "$container"; done
}

# Load Platform Specific Alias Files
case "${PLATFORM}" in
*Darwin*)
    [[ -f ~/.bash_aliases.osx ]] && source ~/.bash_aliases.osx
    ;;
*Linux*)
    [[ -f ~/.bash_aliases.linux ]] && source ~/.bash_aliases.linux
    ;;
*)
    echo "WARNING: Cannot set environment for this unknown platform."
    ;;
esac

# Security Shortcuts

function k.gen() {
  [[ -z $1 ]] && echo "Specify a target filename." && return 1
  [[ ! -d ${HOME}/.ssh ]] && mkdir -p "${HOME}/.ssh"
  ssh-keygen -f "${HOME}/.ssh/$1"
}


genpass() {
	chars=${1:-20}
	env LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | head -c "${chars}"
}
