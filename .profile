#!/bin/sh
#
#   Profie
#   Man page: profile
#   Useful reference: https://help.ubuntu.com/community/EnvironmentVariables

#set -x

# Prepend paths
ppath() {
 [ -d "${1}" ] && PATH="${1}:${PATH}"
}
ppath "/sbin"
ppath "/bin"
ppath "/usr/sbin"
ppath "/usr/bin"
ppath "/var/lib/gems/1.8/bin"
ppath "/var/lib/gems/1.9/bin"
ppath "${HOME}/.cabal/bin"
ppath "${HOME}/.opt/go/bin" \
    && GOROOT="${HOME}/.opt/go/" \
    && export GOROOT
ppath "${HOME}/.opt/groovy/bin"
ppath "${HOME}/.opt/gradle/bin"
ppath "${HOME}/.opt/apache-maven/bin"
ppath "${HOME}/.opt/android-sdks/tools"
ppath "${HOME}/.opt/android-sdks/platform-tools"
ppath "${HOME}/.opt/AdobeAIRSDK/bin"
ppath "${HOME}/Library/Haskell/bin"
# Add all ~/.bin and all ~/.bin-* directories to path
for D in $(find $HOME -maxdepth 1 -name ".bin-*" -o -name ".bin" | sort); do
    ppath ${D}
done
unset -f ppath
export PATH

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
