set pwd to POSIX path of ((path to me as text) & "::")

do shell script "[ -d \"" & pwd & "/.data/firefox/profile\" ] || cp -r \"" & pwd & "/.data/osx/Other/default_profile\" \"" & pwd & "/.data/firefox/profile\""

do shell script "sed 's|__INSERT_REMOTE_VIEWER_PATH_HERE__|" & pwd & ".data/osx/SpiceURLHandler|g' \"" & pwd & ".data/osx/Other/mimeTypes.rdf\" >\"" & pwd & ".data/firefox/profile/mimeTypes.rdf\""

do shell script "\"" & pwd & "/.data/osx/Firefox.app/Contents/MacOS/firefox-bin\" -no-remote -profile \"" & pwd & "/.data/firefox/profile/\" >> \"" & pwd & "/.data/logs/osx-firefox.log\" 2>&1 &"
