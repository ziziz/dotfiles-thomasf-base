#!/bin/bash
# ------------------------------------------------------------------------------
# ALIASES AND FUNCTIONS
#

alias df='df -h'

rmclean() {
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
if [ ${OSTYPE:0:6} = darwin ]; then
    alias ls="ls -G"
else
    alias ls="ls --group-directories-first --color"
fi
alias l="ls -l "
alias la='ls -A'
alias ll="ls -l"
alias pu="pushd"
alias po="popd"

alias t='tree'
alias t2='tree -d -L 2'
alias t3='tree -d -L 3'

alias py='python'

function sshmnt {
    local MOUNT_POINT_PREFIX=
    local MOUNT_POINT_HOME=~/media
    local NODE=$1
    local VOL
    local HOST
    local MOUNT_POINT

	# is hostname fully qualified?
	if [ ${NODE%%.*} == $NODE ]
	then
		VOL=${NODE%:}
	else
		VOL=${NODE%%.*}
	fi
	# remove username if present
	VOL=${VOL#*@}
	# removing trailing slash
	NODE=${NODE%/}
	# is slash in $NODE? (are we mounting a non-default folder?)
	if [ "${NODE#*/}" == "$NODE" ]
	then
		# no slash. set the folder
		# making sure NODE ends with colon
		if [ "${NODE%:}" == "$NODE" ]
		then
			NODE=$NODE:
		fi
	else
		# use the folder name as volumn name
		VOL=${NODE##*/}
		# also making sure colon is present
		HOST=${NODE%%/*}
		NODE=${HOST%:}:/${NODE#*/}
	fi

	MOUNT_POINT=$MOUNT_POINT_HOME/$MOUNT_POINT_PREFIX$VOL
	echo "mounting $NODE on $MOUNT_POINT..."

	if ! (stat $MOUNT_POINT 2>/dev/null | grep staff &> /dev/null)
	then
		mkdir -p $MOUNT_POINT
		sshfs $NODE $MOUNT_POINT 2>&1 | grep -v 'nodelay'
	fi
}

alias agent='exec ssh-agent ${SHELL} -c "ssh-add; ${SHELL}"'

alias apt-update-upgrade='sudo apt-get update && sudo apt-get dist-upgrade'

# ffmpeg - for - phone
ffmpeg-for-phone () {
    for A in $@; do ffmpeg -i ${A} -s qvga -vcodec mpeg4 -acodec libfaac ${A}.mp4 ;done
}

# Extract wrapper for a number of archive formats
ex () {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)           tar xjf $1     ;;
            *.tar.gz)            tar xzf $1     ;;
            *.tar)               tar xf $1      ;;
            *.tgz)               tar xf $1      ;;
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

# Make directory and change to it
mkcd() {
  [[ $1 ]] || return 0
  [[ ! -d $1 ]] && mkdir -vp "$1"
  [[ -d $1 ]] && builtin cd "$1"
}

# Change directory to homesync directory
[[ -d ${HSADMIN_REPOS_PATH} ]] && alias cdhs='builtin cd $HSADMIN_REPOS_PATH'


# Disk usage - recursive for each child folder
du_dir () {
    du -sk ./* | sort -n | awk 'BEGIN{ pref[1]="K"; pref[2]="M"; pref[3]="G";} { total = total + $1; x = $1; y = 1; while( x > 1024 ) { x = (x + 1023)/1024; y++; } printf("%g%s\t%s\n",int(x*10)/10,pref[y],$2); } END { y = 1; while( total > 1024 ) { total = (total + 1023)/1024; y++; } printf("Total: %g%s\n",int(total*10)/10,pref[y]); }'
}


# Git or possibly other repositories or possibly anything.

# cd to repository root
cdr () {
    local dir=$(git rev-parse --show-toplevel) && builtin cd $dir
}

s () {
    git status --short
}

d () {
    git diff
}


octopress-create () {
    local name="${1}"
    mkdir $name &&
    cd $name &&
    git init . &&
    git remote add octopress https://github.com/imathis/octopress &&
    git pull octopress master
}
