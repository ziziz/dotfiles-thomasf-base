## Bash completion for the Android SDK tools.
##
## Copyright (c) 2009 Matt Brubeck
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.

function _android()
{
  local cur prev opts cmds type types c subcommand
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="--help --silent --verbose"
  cmds="list create move delete update"
  types="avd target project lib-project test-project sdk"
  subcommand=""
  type=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    for w in $types; do
      if [ "$w" = "$word" ]; then
        type="$word"
      fi
    done
    c=$((++c))
  done

  case "$subcommand $type" in
    " ")
      case "$cur" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          ;;
      esac
      COMPREPLY=( $(compgen -W "$cmds" -- ${cur}) )
      ;;
    "list ")
      COMPREPLY=( $(compgen -W "avd target sdk" -- ${cur}) )
      ;;
    "create "|"update ")
      COMPREPLY=( $(compgen -W "avd project test-project lib-project" -- ${cur}) )
      ;;
    "move "|"delete ")
      COMPREPLY=( $(compgen -W "avd" -- ${cur}) )
      ;;
  esac

  case "$cur" in
    -*)
      case "$subcommand $type" in
        "delete ")
          COMPREPLY=( $(compgen -W "avd" -- ${cur}) )
          ;;
        "create avd")
          COMPREPLY=( $(compgen -W "--target --sdcard --path --name --force --skin --snapshot --abi" -- ${cur}) )
          ;;
        "move avd")
          COMPREPLY=( $(compgen -W "--path --name --rename" -- ${cur}) )
          ;;
        "delete avd"|"update avd")
          COMPREPLY=( $(compgen -W "--name" -- ${cur}) )
          ;;
        "create project")
          COMPREPLY=( $(compgen -W "--package --name --activity --target --path" -- ${cur}) )
          ;;
        "create lib-project")
          COMPREPLY=( $(compgen -W "--package --name --target --path" -- ${cur}) )
          ;;
        "create test-project")
          COMPREPLY=( $(compgen -W "--main --name --path" -- ${cur}) )
          ;;
        "update project")
          COMPREPLY=( $(compgen -W "--target --path --name --library --subprojects" -- ${cur}) )
          ;;
        "update lib-project")
          COMPREPLY=( $(compgen -W "--target --path" -- ${cur}) )
          ;;
        "update test-project")
          COMPREPLY=( $(compgen -W "--main --path" -- ${cur}) )
          ;;
      esac
      ;;
  esac
  return 0
}
complete -o default -F _android android

function _adb()
{
  local cur prev opts cmds c subcommand device_selected
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-d -e -s -p"
  cmds="devices push pull sync shell emu logcat forward jdwp install \
        uninstall bugreport help version wait-for-device start-server \
        reboot reboot-bootloader \
        kill-server get-state get-serialno status-window remount root ppp"
  cmds_not_need_device="devices help version start-server kill-server"
  subcommand=""
  device_selected=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-d" -o "$word" = "-e" -o "$word" = "-s" ]; then
      device_selected=true
      opts="-p"
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -p)
          return 0;
          ;;
        -s)
          # Use 'adb devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$(adb devices|grep 'device$'|cut -f1)" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $(adb devices 2>/dev/null|wc -l) - 2 ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "${opts} ${cmds_not_need_device}" -- ${cur}) )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    install)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-l -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    forward)
      # Filename or installation option.
      COMPREPLY=( $(compgen -W "tcp: localabstract: localreserved: localfilesystem: dev: jdwp:" -- ${cur}) )
      return 0
      ;;
    uninstall)
      local apks=$(adb shell ls /data/data 2>/dev/null | tr '\n' ' ' | tr -d '\r')
      if [[ $prev != "-k" && $cur == "-" ]]; then
          COMPREPLY=( $(compgen -W "-k $apks" -- ${cur}) )
      else
          COMPREPLY=( $(compgen -W "$apks" -- ${cur}) )
      fi
      return 0
      ;;
    logcat)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-v -b -c -d -f -g -n -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      case "${prev}" in
        -v)
          COMPREPLY=( $(compgen -W "brief process tag thread raw time long" -- ${cur}) )
          return 0
          ;;
        -b)
          COMPREPLY=( $(compgen -W "radio events main" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    pull)
      if [ ${prev} == "pull" ]; then
          if [ -z ${cur} ]; then
              local files=$(adb shell "ls -a -d /*" 2>/dev/null | tr '\n' ' ' | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          else
              local files=$(adb shell "ls -a -d ${cur}*" 2>/dev/null | tr '\n' ' ' | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          fi
          return 0
      fi
      ;;
    push)
      if [ "${COMP_WORDS[COMP_CWORD-2]}" == "push" ]; then
          if [ -z "${cur}" ]; then
              local files=$(adb shell "ls -a -d /*" 2>/dev/null | tr '\n' ' ' | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          else
              local files=$(adb shell "ls -a -d ${cur}*" 2>/dev/null | tr '\n' ' ' | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          fi
          return 0
      fi
      ;;
  esac
}
complete -o default -F _adb adb

function _fastboot()
{
  local cur prev opts cmds c subcommand device_selected
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-w -s -p -c -i -b -n"
  cmds="update flashall flash erase getvar boot devices \
        reboot reboot-bootloader oem"
  subcommand=""
  partition_list="boot recovery system userdata"
  device_selected=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-s" ]; then
      device_selected=true
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -s)
          # Use 'fastboot devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$(fastboot devices|cut -f1)" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $(fastboot devices 2>/dev/null|wc -l) ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "-s" -- ${cur}) )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    flash)
      # partition name
      COMPREPLY=( $(compgen -W "${partition_list}" -- ${cur}) )
      return 0
      ;;
    erase)
      # partition name
      COMPREPLY=( $(compgen -W "${partition_list}" -- ${cur}) )
      return 0
      ;;
  esac
}
complete -o default -F _fastboot fastboot

function _emulator()
{
  local cur prev opts onion_opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-sysdir -system -datadir -kernel -ramdisk -initdata -data -partition-size -cache -no-cache -sdcard -snapstorage -no-snapstorage -snapshot -no-snapshot -no-snapshot-save -no-snapshot-load -snapshot-list -no-snapshot-update-time -wipe-data -avd -skindir -skin -no-skin -memory -netspeed -netdelay -netfast -trace -show-kernel -shell -no-jni -logcat -no-audio -audio -raw-keys -radio -port -ports -onion -scale -dpi-device -http-proxy -timezone -dns-server -cpu-delay -no-boot-anim -no-window -version -report-console -gps -keyset -shell-serial -tcpdump -bootchart -charmap -prop -shared-net-id -nand-limits -memcheck -gpu -fake-camera -webcam -screen -qemu -verbose -debug -help -help-disk-images -help-keys -help-debug-tags -help-char-devices -help-environment -help-keyset-file -help-virtual-device -help-sdk-images -help-build-images -help-all"
  onion_opts="-onion-alpha -onion-rotation"

  if [ ${COMP_CWORD} -eq 1 ]; then
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
  fi

  case "${prev}" in
      -avd)
          local avds=$(for a in $HOME/.android/avd/*.avd; do \
              echo $a | sed 's|.*/\(.*\)\.avd$|\1|'; \
              done)
         COMPREPLY=( $(compgen -W "${avds}" -- ${cur}) )
          ;;
      -onion-rotation)
          local rotations="0 1 2 3"
         COMPREPLY=( $(compgen -W "${rotations}" -- ${cur}) )
          return 0
          ;;
      -audio)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -bootchart)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -cache)
         COMPREPLY=( $(compgen -A file -o filenames -G '*.img' -- ${cur}) )
          ;;
      -cache-size)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -camera-back)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -camera-front)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -charmap)
         COMPREPLY=( $(compgen -A file -o filenames -- ${cur}) )
          ;;
      -cpu-delay)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -data)
         COMPREPLY=( $(compgen -A file -o filenames -- ${cur}) )
          ;;
      -datadir)
         COMPREPLY=( $(compgen -A directory -- ${cur}) )
          ;;
      -debug)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -dns-server)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -dpi-device)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -gps)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -gpu)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -http-proxy)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -initdata)
         COMPREPLY=( $(compgen -A file -o filenames -- ${cur}) )
          ;;
      -kernel)
         COMPREPLY=( $(compgen -A file -o filenames -- ${cur}) )
          ;;
      -keyset)
         COMPREPLY=( $(compgen -A file -o filenames -- ${cur}) )
          ;;
      -logcat)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -memcheck)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -memory)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -nand-limits)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -netdelay)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -netspeed)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -onion)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -onion-alpha)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -partition-size)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -port)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -ports)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -prop)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -radio)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -ramdisk)
         COMPREPLY=( $(compgen -A file -o filenames -G '*.img' -- ${cur}) )
          ;;
      -report-console)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -scale)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -screen)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -sdcard)
         COMPREPLY=( $(compgen -A file -o filenames -G '*.img' -- ${cur}) )
          ;;
      -shared-net-id)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -shell-serial)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -skin)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -skindir)
         COMPREPLY=( $(compgen -A directory -- ${cur}) )
          ;;
      -snapshot)
         COMPREPLY=( $(compgen -A file -- ${cur}) )
          ;;
      -snapstorage)
         COMPREPLY=( $(compgen -A file -- ${cur}) )
          ;;
      -sysdir)
         COMPREPLY=( $(compgen -A directory -- ${cur}) )
          ;;
      -system)
         COMPREPLY=( $(compgen -A file -o filenames -G '*.img' -- ${cur}) )
          ;;
      -tcpdump)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -timezone)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      -trace)
         COMPREPLY=( $(compgen -W "" -- ${cur}) )
          ;;
      *)
          COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
          ;;
  esac
}
complete -o default -F _emulator emulator
complete -o default -F _emulator emulator-arm
complete -o default -F _emulator emulator-x86

# http://source-android.frandroid.com/ndk/docs/NDK-BUILD.html
function _ndk_build()
{
  local cur prev cmds opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  cmds="clean NDK_APP_APPLICATION_MK= NDK_DEBUG=0 NDK_DEBUG=1 NDK_LOG=1 V=1"
  opts="-b -B -C -d -e -f -h -i -I -j -k -l -L -n -o -p -q -r -R -s -S -t -v -w -W --always-make --directory= --debug --environment-overrides --file= --help --ignore-errors --include-dir= --jobs --keep-going --load-average --check-symlink-times --just-print --old-file= --print-data-base --question --no-builtin-rules --no-builtin-variables --silent --no-keep-going --touch --version --print-directory even --what-if= --warn-undefined-variables"

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=( $(compgen -W "${opts} ${cmds}" -- ${cur}) )
      return 0
  fi
}
complete -o default -F _ndk_build ndk-build

function _ndk_gdb()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-d -e -h -? -p -s -x --help --verbose --force --start --launch= --launch-list --delay= --project= --port= --exec= --adb= --awk="

  if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
  fi
}
complete -o default -F _ndk_gdb ndk-gdb
