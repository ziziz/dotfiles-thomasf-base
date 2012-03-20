#!/bin/bash
# ------------------------------------------------------------------------------
# ALIASES AND FUNCTIONS
#

alias df='df -h'

rm_clean() {
    echo -n "Really clean $(pwd)?"
    read -n 1 yorn;
    if test "$yorn" = "y"; then
        echo
        rm -f \#* *~ .*~ *.bak .*.bak  *.tmp .*.tmp core a.out;
    else
        echo
        return 1
    fi
}


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

