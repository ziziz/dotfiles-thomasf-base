#!/bin/bash

# ------------------------------------------------------------------------------
# HOME DIR LOCAL ENVIRONMENTS
#

# Maybe load Node version manager
[ -f "${HOME}/.nvm/nvm.sh" ] && source "${HOME}/.nvm/nvm.sh"

# Maybe load virtualenvburruto
VIRTUAL_ENV_DISABLE_PROMPT=1 && export VIRTUAL_ENV_DISABLE_PROMPT
[ -f "${HOME}/.venvburrito/startup.sh" ] && source "${HOME}/.venvburrito/startup.sh" && workon default

# Maybe load Pythonbrew
# [ -f "${HOME}/.pythonbrew/etc/bashrc" ] && source "${HOME}/.pythonbrew/etc/bashrc"

# Maybe load Ruby version manager
[ -f "${HOME}/.rvm/scripts/rvm" ] && source "${HOME}/.rvm/scripts/rvm"

# -------------------------------------------------------------------------------
# Connect to gpg agent if possible
#
agent_file="$HOME/.gnupg/gpg-agent-info-$(hostname)"
if [ -r "$agent_file" ] && kill -0 $(grep GPG_AGENT_INFO "$agent_file" | cut -d: -f 2) 2>/dev/null; then
    source "$agent_file"
    export GPG_AGENT_INFO; export SSH_AUTH_SOCK; export SSH_AGENT_PID
fi
GPG_TTY=$(tty)
export GPG_TTY

keys_agent_connect

# ------------------------------------------------------------------------------
# NON INTERACTIVE RETURN POINT
#

[ -z "$PS1" ] && return 

# ------------------------------------------------------------------------------
# BASH OPTIONS
#

HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#HISTCONTROL=ignoreboth
HISTSIZE=1200
shopt -s histappend
shopt -s checkwinsize
stty -ixon
setterm -bfreq 0

# ------------------------------------------------------------------------------
# COMPLETION AND EXTENSIONS
#

[ -f "/etc/bash_completion" ] && ! shopt -oq posix && . "/etc/bash_completion"
[[ -r $rvm_path/scripts/completion ]] && source $rvm_path/scripts/completion

for file in $(find $HOME/.bash.d/ -not -type d -name \*.bash); do
    source $file # 2>/dev/null
done

  
# ------------------------------------------------------------------------------
# Bash PROMPT
#
# ref: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
# ref: http://www.reddit.com/r/programming/comments/697cu/bash_users_what_do_you_have_for_your_ps1/
#

function __prompt_date {
    echo -n `date +%H%M`
}

# Username or alias
function __prompt_username {
    if [ "$(type -t __user_alias)" == "function" ]; then
        __user_alias
    else 
        echo -n "$(whoami | cut -c1-4)"
    fi 
}

# Hostname or alias
function __prompt_hostname {
   if [[ -n ${HOST_ALIAS} ]]; then
       echo -n ${HOST_ALIAS}
   else
       echo -n "$(hostname | cut -c1-4)"
   fi 
}

# SSH agent indicator
function __prompt_ssh_agent {
    if [ -n "${SSH_CLIENT}" ] && [ -n "${SSH_AUTH_SOCK}" ] && [ -e "${SSH_AUTH_SOCK}" ]; then
        echo -n "@"
    fi
}

# SSH session session indicator
function __prompt_ssh {
    if [ -n "$SSH_CLIENT" ]; then
        echo -n 'ssh'
    fi
}

# Show version controlled repository status.
# vcprompt is used if installed, otherwise __git_ps1 will be tried as well.
# Install vcsprompt -> hg clone https://bitbucket.org/mitsuhiko/vcprompt
export GIT_PS1_SHOWDIRTYSTATE="yes"
export GIT_PS1_SHOWUPSTREAM="no"
export GIT_PS1_SHOWUNTRACKEDFILES="yes"
function __prompt_vcs {
    if [[ $(which vcprompt) ]]; then
        vcprompt -f "(%n:%b%m%u)"
    elif [[ $(type -t __git_ps1) == "function" ]]; then
        __git_ps1 "(%s)"
    fi
}



# Support function to compactify a path
# copied: http://stackoverflow.com/questions/3497885/code-challenge-bash-prompt-path-shortener
function __dir_chomp {
    local p=${1/#$HOME/\~} b s
    # Remove [ and ] from strings
    # (also, regular expression matching on [ ] below creates infinite recursion.)
    p=${p//[/ }
    p=${p//]/ }
    # Remove multiple spaces, don't need them
    p=${p//  / }
    s=${#p}
    while [[ $p != ${p//\/} ]]&&(($s>$2))
    do
        p=${p#/}
        [[ $p =~ \.?. ]]
        b=$b/${BASH_REMATCH[0]}
        p=${p#*/}
        ((s=${#b}+${#p}))
    done
    echo ${b/\/~/\~}${b+/}$p
}

# Compact version of current working directory
function __prompt_pwd {
    echo -n $(__dir_chomp  "$(pwd)" 25)
}

# 
function __prompt_last {
  if [[ $EUID -eq 0 ]]; then
      if [[ ${RET} = "0" ]]; then
          echo -n "#"
      else
          echo -n '!!! #'
      fi
  else
      if [[ ${RET} = "0" ]]; then
          echo -n "\$"
      else
          echo -n '¤%&!'
      fi
  fi
}


PROMPT_COMMAND="export RET=\$?;${PROMPT_COMMAND}"

# Set up prompt
function __prompt_activate {

    local resetFormating="\[\033[0m\]"     # reset text format
    
    # regular colors
    local black="\[\033[0;30m\]"
    local red="\[\033[0;31m\]"
    local green="\[\033[0;32m\]"
    local yellow="\[\033[0;33m\]"
    local blue="\[\033[0;34m\]"
    local magenta="\[\033[0;35m\]"
    local cyan="\[\033[0;36m\]"
    local white="\[\033[0;37m\]"

    # High intensity colors
    local blackH="\[\033[0;90m\]"
    local redH="\[\033[0;91m\]"
    local greenH="\[\033[0;92m\]"
    local yellowH="\[\033[0;93m\]"
    local blueH="\[\033[0;94m\]"
    local magentaH="\[\033[0;95m\]"
    local cyanH="\[\033[0;96m\]"
    local whiteH="\[\033[0;97m\]"
    
    # background colors
    local blackB="\[\033[40m\]"
    local redB="\[\033[41m\]"
    local greenB="\[\033[42m\]"
    local yellowB="\[\033[43m\]"
    local blueB="\[\033[44m\]"
    local magentaB="\[\033[45m\]"
    local cyanB="\[\033[46m\]"
    local whiteB="\[\033[47m\]"

    # Select host name color based on HOST_TAGS environment variable
    case ${HOST_TAGS} in
        *:server:*)
            local HOST_COLOR=${black}${redB}
            ;;
        *:workstation:*)
            local HOST_COLOR=${blue}
            ;;
        *)
            local HOST_COLOR=${white}${blackB}
            ;;
    esac
    
    # Set title in xterm*
    case $TERM in
        xterm*|rxvt*)
            TITLEBAR='\[\033]0;\u@\h:\w\007\]'
            ;;
        *)
            TITLEBAR=""
            ;;
    esac

# Set the prompt 
PS1="${TITLEBAR}\
${red}\$(__prompt_date) \
${yellow}\$(__prompt_username)${redH}@${HOST_COLOR}\$(__prompt_hostname)\
${cyan}\$(__prompt_pwd)${green}\$(__prompt_vcs) \
${white}${magentaB}\$(__prompt_ssh_agent)${black}${magentaB}\$(__prompt_ssh)\
${magenta}\$(__prompt_last) \
${resetFormating}"
PS2='> '
PS4='+ '
}

# ------------------------------------------------------------------------------
# DIRCOLORS
#

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ------------------------------------------------------------------------------
# MISC
#

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ------------------------------------------------------------------------------
# ALIASES AND FUNCTIONS
#

alias df='df -h'

alias clean='echo -n "Really clean this directory?";
        read yorn;
        if test "$yorn" = "y"; then
           rm -f \#* *~ .*~ *.bak .*.bak  *.tmp .*.tmp core a.out;
           echo "Cleaned.";
        else
           echo "Not cleaned.";
        fi'


function eless {
    zless $(which ${1})
}

alias j="jobs -l"
alias ls="ls --group-directories-first --color"
alias l="ls -l "
alias la='ls -A'
alias ll="ls -l"
alias pu="pushd"
alias po="popd"

alias t='tree'
alias t2='tree -d -L 2'
alias t3='tree -d -L 3'

alias agent='exec ssh-agent ${SHELL} -c "ssh-add; ${SHELL}"'

alias apt-update-upgrade='sudo apt-get update && sudo apt-get dist-upgrade'


ffmpeg-for-phone () {
    for A in $@; do ffmpeg -i ${A} -s qvga -vcodec mpeg4 -acodec libfaac ${A}.mp4 ;done
}

ex () {
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.gz)            tar -xf $1     ;;
      *.tar)               tar -xf $1     ;;
      *.tgz)               tar -xf $1     ;;
      *.bz2)               bunzip2 $1     ;;
      *.rar)               unrar x $1     ;;
      *.gz)                gunzip $1      ;;
      *.lzma)              unxz $1        ;;
      *.rpm)               bsdtar xf $1   ;;
      *.zip)               unzip $1       ;;
      *.Z)                 uncompress $1  ;;
      *.7z)                7z x $1        ;;
      *.exe)               cabextract $1  ;;
      *)                   echo "'$1': unrecognized file compression" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

#ghclone() {
#  (( $# == 2 )) || return 1
#  git clone git://github.com/$1/${2%.git}.git
#}

mkcd() {
  [[ $1 ]] || return 0
  [[ ! -d $1 ]] && mkdir -vp "$1"
  [[ -d $1 ]] && builtin cd "$1"
}

[[ -d ${HSYNC_REPOS_PATH} ]] && alias cdhs='cd $HSYNC_REPOS_PATH'


# ------------------------------------------------------------------------------
# PRIVATE AND LOCAL
#
[ -e "${HOME}/.bashrc-private" ] && . "${HOME}/.bashrc-private"
[ -e "${HOME}/.bashrc-local" ] && . "${HOME}/.bashrc-local"

# ------------------------------------------------------------------------------
# HACKS :/
#


# if runnung under osx, make some changes
if [ "$OSTYPE" == "darwin10.0" ]; then
    unalias ls
fi


__prompt_activate

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
