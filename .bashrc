#!/bin/bash

# ------------------------------------------------------------------------------
# HOME DIR LOCAL ENVIRONMENTS
#

# Pip download cache
mkdir -p "${HOME}/.cache/pip_download" && export PIP_DOWNLOAD_CACHE="${HOME}/.cache/pip_download"

# Don't let virtualenv change the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Only do this automatically if not root
if [ $UID != 0 ]; then

    # Maybe load Node version manager
    [ -f "${HOME}/.nvm/nvm.sh" ] && source "${HOME}/.nvm/nvm.sh"

    # Set virtualenvwrapper hooks dir
    [ -e "${HOME}/.virtualenvwrapper-hooks" ] && VIRTUALENVWRAPPER_HOOK_DIR="${HOME}/.virtualenvwrapper-hooks" && export VIRTUALENVWRAPPER_HOOK_DIR

    # Maybe load virtualenvburruto or else pythonbrew
    if [ -f "${HOME}/.venvburrito/startup.sh" ]; then
        source "${HOME}/.venvburrito/startup.sh" && [ -z "${VIRTUAL_ENV}" ] && workon default
    elif  [ -f "${HOME}/.pythonbrew/etc/bashrc" ]; then
        source "${HOME}/.pythonbrew/etc/bashrc"
    fi

    # Maybe load Ruby version manager
    [ -f "${HOME}/.rvm/scripts/rvm" ] && source "${HOME}/.rvm/scripts/rvm"
fi

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
# BASH
#
shopt -s checkwinsize
shopt -s checkjobs
shopt -s cdspell
shopt -s dirspell
# bash history

if [ $UID != 0 ]; then
    export HISTFILE=~/.bash_history
else
    export HISTFILE=~/.bash_history_root
fi
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE="&:ls:cd:[bf]g:exit:pwd:clear:mount:umount:?"
PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"

# ------------------------------------------------------------------------------
#
# TERMINAL OPTIONS
#
# enable xon/xoff flow control
stty -ixon
# set bell frequency to 0
[ $(which setterm) ] && setterm -bfreq 0

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

# Activate the prompt
__prompt_activate
