#!/bin/bash

# ------------------------------------------------------------------------------
# HOME DIR LOCAL ENVIRONMENTS
#

# Maybe load Node version manager
[ -f "${HOME}/.nvm/nvm.sh" ] && source "${HOME}/.nvm/nvm.sh"

# Maybe load virtualenvburruto or else pythonbrew
if [ -f "${HOME}/.venvburrito/startup.sh" ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1 && export VIRTUAL_ENV_DISABLE_PROMPT
    VIRTUALENVWRAPPER_HOOK_DIR="${HOME}/.virtualenvwrapper-hooks" && export VIRTUALENVWRAPPER_HOOK_DIR
    source "${HOME}/.venvburrito/startup.sh" && workon default
elif  [ -f "${HOME}/.pythonbrew/etc/bashrc" ]; then
    source "${HOME}/.pythonbrew/etc/bashrc"
fi

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
# COMPLETION
#
[ -f "/etc/bash_completion" ] && ! shopt -oq posix && . "/etc/bash_completion"
[[ -r $rvm_path/scripts/completion ]] && source $rvm_path/scripts/completion
[[ -r "${HOME}/.nvm/bash_completion" ]] && source "${HOME}/.nvm/bash_completion"

for file in $(find $HOME/.bash.d/ -not -type d -name \*-completion.bash); do
    source $file # 2>/dev/null
done

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
# Misc
#
[ -f "${HOME}/.bash.d/z.bash" ] && ! shopt -oq posix && . "${HOME}/.bash.d/z.bash"
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
[ -f "${HOME}/.bash.d/functions.bash" ] && ! shopt -oq posix && . "${HOME}/.bash.d/functions.bash"
[ -f "${HOME}/.bash.d/prompt.bash" ] && ! shopt -oq posix && . "${HOME}/.bash.d/prompt.bash"

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

# Activate the prompt
__prompt_activate
