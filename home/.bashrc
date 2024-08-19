#!/bin/bash

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Detect Platform on Login
PLATFORM="$(uname -s):$(uname -m)"

# Setup Git
git config --global core.excludesfile ~/.gitignore_global

# Path appends
[[ -f ~/.bash_path ]] && . ~/.bash_path

# Ensure .bash_env is sourced on every login
[[ -f ~/.bash_env ]] && source ~/.bash_env

# Ensure .bash_git_support is sourced
[[ -f ~/.bash_git_support ]] && source ~/.bash_git_support

# ASDF
if [[ -f "${HOME}/.asdf/asdf.sh" ]]; then
    # shellcheck disable=SC1091
    . "${HOME}/.asdf/asdf.sh"
    export ASDF_GOLANG_MOD_VERSION_ENABLED=true
fi
if [[ -f "$HOME/.asdf/completions/asdf.bash" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.asdf/completions/asdf.bash"
fi

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Optional components for an SSH connect
if [[ -n "$SSH_CONNECTION" ]]; then
    tmux has-session 2> /dev/null && tmux attach
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [[ -n "$force_color_prompt" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [[ "$color_prompt" = yes ]]; then
    PS1='${git_branch}${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${git_branch}${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolor ]]; then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

# Standard Bash Completion
if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
fi

# Custom Bash Completion Files
if [[ -d ~/.bash_includes ]]; then
 for f in ~/.bash_includes/*.bash; do source "$f"; done
fi

# pyenv Support
[[ -d ~/.pyenv ]] && export PATH="${HOME}/.pyenv/bin:$PATH" && eval "$(pyenv init -)"

# Openssl Fix for OSX
export PATH="/usr/local/opt/openssl/bin:$PATH"

# Homeshick
if [[ -f "${HOME}/.homesick/repos/homeshick/homeshick.sh" ]]; then
    # shellcheck disable=SC1091
    . "${HOME}/.homesick/repos/homeshick/homeshick.sh"
fi
if [[ -f "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash" ]]; then
    # shellcheck disable=SC1091
    . "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash"
fi

# gcloud SDK
if [[ -f "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc" ]]; then
   # shellcheck disable=SC1091
   source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
fi

# Custom Scripts
if [[ -f "${HOME}/bin/weather" ]]; then
    weather -city toronto -appid 43787c792001977957121d7a7d952674
fi

# GPG TTY
export GPG_TTY=$(tty)

# Docker
export DOCKER_USER_UID="$(id -u)"
export DOCKER_USER_GID="$(id -g)"

