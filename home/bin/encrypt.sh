#!/bin/bash

# ------------------------------------------------------------
# Openssl Encryption Wrapper
# ------------------------------------------------------------

[[ -z $1 ]] && echo "Please specify a filename." && exit 1

openssl aes-256-cbc -a -salt -in "$1" -out "$1.enc"

