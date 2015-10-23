' SpiceURLHandler.vbs - Spice Handler
'
' Author: Roman Gruber <roman.gruber@bwzofingen.ch>
' Version: 1.0
' Called by: Firefox
' Calls: remote-viewer.exe
' Description: Examines the Drive Letter of the USB Device. Check the provided Spice Link.
'              Extract the host, the port and the password and build a command for remote-
'              viewer.exe.
'
' Changelog: 03.12.2014 - roman.gruber@bwzofingen.ch
'             - initial version 1.0
'

Dim sho
Dim fso
Set sho = WScript.CreateObject("Wscript.Shell")
set fso = CreateObject("Scripting.FileSystemObject")

' Read the first agrument given: the spice URL
SpiceURL = WScript.Arguments(0)

' Examine the USB Drive letter
dim CurrentDirectory
CurrentDirectory = fso.GetAbsolutePathName(".")
DriveLetter = fso.GetDriveName(CurrentDirectory)

' The logfile
LogFile = fso.BuildPath(DriveLetter, "\.data\logs\win-SpiceURLHandler.log")

' Open the logfile
Set objLogFile = fso.OpenTextFile(LogFile, 8, True) 

' Regex to check a spice URL
Set regex = new regexp
regex.Pattern = "spice://[a-zA-z0-9\.]+\?port=[0-9]+\&password=[a-zA-Z0-9\-]+$"

' Check the spice URL
if regex.Test(SpiceURL) Then
  ' Log the original URL
  objLogFile.Write Date & " " & Time & " - URL Pre: " & SpiceURL & vbCrLf

  SpiceClient = fso.BuildPath(DriveLetter, "\.data\win\VirtViewer\bin\remote-viewer.exe")

  ' Replace the ip adresses (should be removed later)
  SpiceURL = Replace(SpiceURL, "192.168.140.13", "vmsrv01.kszofingen.ch")
  SpiceURL = Replace(SpiceURL, "192.168.140.14", "vmsrv02.kszofingen.ch")

  ' Log the extracted information
  objLogFile.Write Date & " " & Time & " - URL Post: " & SpiceURL & vbCrLf
  objLogFile.Write Date & " " & Time & " - Client: " & SpiceClient & vbCrLf
  objLogFile.Write Date & " " & Time & " - CMD: " & SpiceClient &  " " & SpiceURL & vbCrLf

  ' Run the spice client with the URL as argument
  sho.Run(SpiceClient &  " " & SpiceURL)
Else
  ' Log it, if it's not a valid spice URL and prompt a message box
  objLogFile.Write Date & " " & Time & " - Not a valid spice URL: " & SpiceURL & vbCrLf
  msgbox("This is not a valid spice URL: " & SpiceURL), 12, "SpiceURLHandler.vbs: Error"
End if

' Close the log file
objLogFile.Close
