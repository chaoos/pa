on open location spiceurl
	set pwd to POSIX path of ((path to me as text) & "::")
	do shell script "\"" & pwd & "/SpiceURLHandler.sh\" \"" & spiceurl & "\" > /dev/null 2>&1 &"
end open location
