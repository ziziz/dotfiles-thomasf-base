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
ppath "${HOME}/.opt/depot_tools"
ppath "/var/lib/gems/1.8/bin"
ppath "/var/lib/gems/1.9/bin"
ppath "/usr/local/git/bin"
ppath "${HOME}/.cabal/bin"
ppath "${HOME}/.opt/go/bin" \
    && GOROOT="${HOME}/.opt/go/" \
    && export GOROOT
ppath "${HOME}/.opt/ec2-api-tools/bin" \
    && EC2_HOME="${HOME}/.opt/ec2-api-tools" \
    && export EC2_HOME
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

# set JAVA_HOME
if [ $(which javac) ]; then
    JAVA_HOME=$(readlink -f $(which javac) | sed "s:/bin/javac::")
    export JAVA_HOME
elif [ $(which java) ]; then
    JAVA_HOME=$(readlink -f $(which java) | sed "s:/bin/java::")
    export JAVA_HOME
fi

# Locale settings (man page: locale)
unset LC_ALL
LANGUAGE="en_US:en" && export LANGUAGE
LANG="en_US.UTF-8" && export LANG
LC_CTYPE="sv_SE.utf8" && export LC_CTYPE
LC_NUMERIC="sv_SE.utf8" && export LC_NUMERIC
LC_TIME="sv_SE.utf8" && export LC_TIME
LC_COLLATE="sv_SE.utf8" && export LC_COLLATE
LC_MONETARY="sv_SE.utf8" && export LC_MONETARY
LC_MESSAGES="en_US.UTF-8" && export LC_MESSAGES
LC_PAPER="sv_SE.utf8" && export LC_PAPER
LC_NAME="sv_SE.utf8" && export LC_NAME
LC_ADDRESS="sv_SE.utf8" && export LC_ADDRESS
LC_TELEPHONE="sv_SE.utf8" && export LC_TELEPHONE
LC_MEASUREMENT="sv_SE.utf8" && export LC_MEASUREMENT
LC_IDENTIFICATION="sv_SE.utf8" && export LC_IDENTIFICATION
# Prohibit perl from complaining about missing locales
PERL_BADLANG=0 && export PERL_BADLANG

# iptyhon configuration directory
IPYTHONDIR="${HOME}/.config-base/ipython"
export IPYTHONDIR

# coffeelint configuration file
COFFEELINT_CONFIG="${HOME}/.config-base/coffeelint.json"
export COFFEELINT_CONFIG


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
[ $(which less) ] && PAGER="less -R" && export PAGER
