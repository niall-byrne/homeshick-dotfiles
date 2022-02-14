#!/bin/bash

# ------------------------------------------------------------
# Openssl Decryption Wrapper
# ------------------------------------------------------------

# shellcheck disable=SC2001

[[ -z $1 ]] && echo "Please specify a filename." && exit 1

outputfilename="$(echo "${1}" | sed 's/.enc$//g')"
openssl aes-256-cbc -d -a -in "$1" -out "${outputfilename}"

