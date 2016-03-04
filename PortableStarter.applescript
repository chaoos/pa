# PortableStarter.applescript - Starter for portable Firefox
#

# find path to script
set pwd to POSIX path of ((path to me as text) & "::")

# run the starter script
do shell script "'" & pwd & "/.data/osx/PortableStarter.sh'"

