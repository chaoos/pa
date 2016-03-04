#!/bin/bash
# SpiceURLHandler.sh - Spice Handler
#
# Author: Roman Gruber <roman.gruber@bwzofingen.ch>
# Version: 1.0
# Called by: SpiceURLHandler.app
# Calls: RemoteViewer.app/Contents/MacOS/RemoteViewer
# Description: Examines the mount point of the USB Device. Check the provided Spice Link.
#              Extract the host, the port and the password and build a command for 
#              RemoteViewer.app.
#
# Changelog: 03.12.2014 - roman.gruber@bwzofingen.ch
#             - initial version 1.0
#            23.09.2015 - roman.gruber@bwzofingen.ch
#             - version 1.1: added more portablility
#            04.03.2016 - roman.gruber@bwzofingen.ch
#             - version 1.2: read from windows newlinebreaked config file, added URLMapper functionality
#

# poor mans pgrep
function _pgrep {
  if [ -n "$1" ]; then
    p="$1"
    ps axo pid,command,args | \
      awk '/['${p:0:1}']'${p:1}'/{x=$1; print x; exit 0} END{if(length(x)==0){exit 1}}' && \
      return 0 || return 1
  else
    return 0
  fi
}

# log the output
exec 1> >(perl -nle 'BEGIN{$|=1} $d = localtime(); s/^/$d - /; print' >>"$(cd "$(dirname "$0")" && pwd)/../logs/osx-$(basename "$0").log")
exec 2>&1

echo "URL: $1"
URI="$1"

# the dir path of the script
sd="$( cd "$(dirname "$0")"; pwd -P )"

# the root dir
rootdir="${sd%/*/*}"

# get the values in settings.conf of the sections General and OSX
eval "$(perl -pe 'y|\r||d' "${sd}/../config/settings.conf" | sed -n -e '/^\[General\]$/,/^\[/ {' -e '/^[^\[]/p' -e '}')"
eval "$(perl -pe 'y|\r||d' "${sd}/../config/settings.conf" | sed -n -e '/^\[OSX\]$/,/^\[/ {' -e '/^[^\[]/p' -e '}')"
eval "$(perl -pe 'y|\r||d' "${sd}/../config/settings.conf" | sed -n -e '/^\[URLMapper\]$/,/^\[/ {' -e '/^[^\[]/p' -e '}')"

# check if it is a valid spice URL
echo $URI | grep -qE 'spice://[a-zA-z0-9\.]+\?port=[0-9]+\&password=[a-zA-Z0-9\-]+$'
if [ $? -eq 0 ]; then
  [ -n "${SpiceClientBinary}" ] && SpiceClientBinary="${rootdir}/${SpiceClientBinary}"

  # apply all URL mappings from the config file
  for (( i=0; i<${#SpiceURLSearchString[@]}; i++ )); do
    URI="${URI//${SpiceURLSearchString[$i]}/${SpiceURLReplaceString[$i]}}"
  done

  echo "CMD: \"${SpiceClientBinary}\" ${SpiceClientArgs} \"$URI\""

  # call the application in the background
  "${SpiceClientBinary}" ${SpiceClientArgs} "$URI" &

  osascript -e "
    set i to 0
    repeat while i < 20
      if application \"RemoteViewer\" is running then
        delay 2
        tell application \"RemoteViewer\" to activate
        set i to 20
      end if
      delay 1
      set i to i + 1
    end repeat"

else

  # notification if it is not a valid spice URL
  echo "Not a valid spice URL: $URI"
  osascript -e "tell app \"SystemUIServer\" to display alert \"This is not a valid spice URL: $URI\""
fi
