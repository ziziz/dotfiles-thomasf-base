#!/bin/bash
# ------------------------------------------------------------------------------
# Bash PROMPT
#
# ref: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
# ref: http://www.reddit.com/r/programming/comments/697cu/bash_users_what_do_you_have_for_your_ps1/
#

function __prompt_date {
    echo -n `date +%H%M`
}

function __prompt_h {
    echo -n `date +%H`
}

function __prompt_m {
    echo -n `date +%M`
}


function __prompt_venv {
    # [[ -n ${VIRTUAL_ENV} ]] && [ "${VIRTUAL_ENV##*/}" != "default" ] && echo -n " p:${VIRTUAL_ENV##*/} "
    [[ -n ${VIRTUAL_ENV} ]] && echo -n "(p:${VIRTUAL_ENV##*/}) "

}

function __prompt_rvm {
    which rvm-prompt >/dev/null 2>/dev/null && echo -n "(r:$(rvm-prompt v g 2>/dev/null)) "
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
        vcprompt -f "(%n:%b%m%u) "
    elif [[ $(type -t __git_ps1) == "function" ]]; then
        __git_ps1 "(%s) "
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
    local w=$(($(tput cols)-50))
    echo -n $(__dir_chomp  "$(pwd)" $w)
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
${red}▶\$(__prompt_h) \
${blue}\$(__prompt_pwd) \
${yellow}\$(__prompt_vcs)\
${cyan}\$(__prompt_venv)\
${green}\$(__prompt_rvm)\
\n${red}:\$(__prompt_m) \
${yellow}\$(__prompt_username)${redH}@${HOST_COLOR}\$(__prompt_hostname)${white}${magentaB}\$(__prompt_ssh_agent)${black}${magentaB}\$(__prompt_ssh)\
${magenta}\$(__prompt_last) \
${resetFormating}"
PS2='> '
PS4='+ '
}
