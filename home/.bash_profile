#!/bin/bash

# ----------------------------------------------------------------
# Bash Profile - Launched During Login (or new Shell on OSX)
# ----------------------------------------------------------------

# shellcheck disable=SC1090

export BASH_SILENCE_DEPRECATION_WARNING=1

# Ensure .bashrc is sourced on every login
[[ -s ~/.bashrc ]] && source ~/.bashrc
