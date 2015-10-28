#!/bin/bash
#
# PortableStarter.sh - Starter for portable Firefox
#

# log the output
exec 1> >(perl -nle 'BEGIN{$|=1} $d = localtime(); s/^/$d - /; print' >>"$(cd "$(dirname "$0")" && pwd)/../logs/osx-$(basename "$0").log")
exec 2>&1

# the dir path of the script
sd="$( cd $(dirname "$0"); pwd -P )"

# the root dir
rootdir="${sd%/*/*}"

# get the values in settings.conf of the sections General and OSX
eval "$(sed -n -e '/^\[General\]$/,/^\[/ {' -e '/^[^\[]/p' -e '}' "${sd}/../config/settings.conf")"
eval "$(sed -n -e '/^\[OSX\]$/,/^\[/ {' -e '/^[^\[]/p' -e '}' "${sd}/../config/settings.conf")"

# if the default_profile dir exists copy it recursively
[ -n "${FirefoxDefaultProfile}" ] && FirefoxDefaultProfile="${rootdir}/${FirefoxDefaultProfile}"
[ -n "${FirefoxProfileDir}" ] && FirefoxProfileDir="${rootdir}/${FirefoxProfileDir}"
[ -d "${FirefoxDefaultProfile}" ] && [ -d "${FirefoxProfileDir}" ] && \
  cp -r "${FirefoxDefaultProfile}" "${FirefoxProfileDir}"

# replace the placeholder in the mimeTypes.rdf file
[ -n "${FirefoxSpiceURLHandler}" ] && FirefoxSpiceURLHandler="${rootdir}/${FirefoxSpiceURLHandler}"
[ -n "${FirefoxMimetypes}" ] && FirefoxMimetypes="${rootdir}/${FirefoxMimetypes}"
sed "s|__INSERT_REMOTE_VIEWER_PATH_HERE__|${FirefoxSpiceURLHandler}|g" "${FirefoxMimetypes}" > "${FirefoxProfileDir}/mimeTypes.rdf"

[ -n "${FirefoxBinary}" ] && FirefoxBinary="${rootdir}/${FirefoxBinary}"

cmd="\"${FirefoxBinary}\" ${FirefoxArgs} -profile \"${FirefoxProfileDir}\" \"${StartPage}\""
echo "Command: ${cmd}"
"${FirefoxBinary}" ${FirefoxArgs} -profile "${FirefoxProfileDir}" "${StartPage}"

