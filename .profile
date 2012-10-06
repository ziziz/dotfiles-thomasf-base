#!/bin/sh
#
#   Profie
#   Man page: profile
#   Useful reference: https://help.ubuntu.com/community/EnvironmentVariables

#set -x

# Prepend path function
ppath() {
 [ -d "${1}" ] && PATH="${1}:${PATH}" && export PATH
}

# Common system paths
ppath "/sbin"
ppath "/bin"
ppath "/usr/sbin"
ppath "/usr/bin"
ppath "/var/lib/gems/1.8/bin"
ppath "/var/lib/gems/1.9/bin"
# common user paths
ppath "${HOME}/.cabal/bin"
ppath "${HOME}/.go/bin"
# my paths
ppath "${HOME}/programming/applib/gradle/bin"
ppath "${HOME}/programming/applib/groovy/bin"
ppath "${HOME}/programming/applib/android-sdks/tools"
ppath "${HOME}/programming/applib/android-sdks/platform-tools"
ppath "${HOME}/Library/Haskell/bin"
ppath "/Applications/AdobeAIRSDK/bin"
# Add all ~/.bin and all ~/.bin-* directories to path
for D in $(find $HOME -maxdepth 1 -name ".bin-*" -o -name ".bin" | sort); do
    ppath ${D}
done

unset -f ppath


# Music player daemon client host and ports
MPD_PORT=6205 && export MPD_PORT
MPD_HOST=localhost && export MPD_HOST

# ------------------------------------------------------------------------------
# PRIVATE AND LOCAL
#
[ -e "${HOME}/.profile-private" ] && . "${HOME}/.profile-private"
[ -e "${HOME}/.profile-local" ] && . "${HOME}/.profile-local"

# Application configuration
EDITOR="editor" && export EDITOR
VISUAL="${EDITOR}" && export VISUAL
ALTERNATE_EDITOR="${EDITOR}" && export ALTERNATE_EDITOR
[ $(which less) ] && PAGER="$(which less)" && export PAGER
