' SpiceURLHandler.vbs - Spice Handler
'
' Author: Roman Gruber <roman.gruber@bwzofingen.ch>
' Description: Examines the Drive Letter of the USB Device. Check the provided Spice Link.
'              Extract the host, the port and the password and build a command for remote-
'              viewer.exe.
'

' This function returns a value read from an INI file
' Arguments:
' strFilePath  [string]  the (path and) file name of the INI file
' strSection   [string]  the section in the INI file to be searched
' strKey       [string]  the key whose value is to be returned
'
' Returns:
' string value for the specified key in the specified section
Function GetInivalue(strFilePath,strSection,strKey)

  Dim intEqualPos, objFSO, objIniFile, strLeftString, strLine

  Set objFSO = CreateObject( "Scripting.FileSystemObject" )

  GetInivalue = ""

  If objFSO.FileExists( strFilePath ) Then
    Set objIniFile = objFSO.OpenTextFile( strFilePath, 1, False )
    Do While objIniFile.AtEndOfStream = False
      strLine = Trim( objIniFile.ReadLine )

      ' Check if section is found in the current line
      If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
        strLine = Trim( objIniFile.ReadLine )

        ' Parse lines until the next section is reached
        Do While Left( strLine, 1 ) <> "["
          ' Find position of equal sign in the line
          intEqualPos = InStr( 1, strLine, "=", 1 )
          If intEqualPos > 0 Then
            strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
            ' Check if item is found in the current line
            If LCase( strLeftString ) = LCase( strKey ) Then
              GetInivalue = Trim( Mid( strLine, intEqualPos + 1 ) )
			  GetInivalue = Replace(GetInivalue, """", "")
              ' Abort loop when item is found
              Exit Do
            End If
          End If

          ' Abort if the end of the INI file is reached
          If objIniFile.AtEndOfStream Then Exit Do

          ' Continue with next line
          strLine = Trim( objIniFile.ReadLine )
          Loop
        Exit Do
      End If
    Loop
    objIniFile.Close
  End If
End Function

' Query the win32_process instances if the script is alreay running
Dim svc, query, ncount
Set svc = getobject("winmgmts:root\cimv2")
query = "select commandline from win32_process " & _
    "where (not ((commandline like ""%command.com%"") or (commandline like ""%cmd.exe%""))) and " & _
    "(commandline like ""%[WC]Script.exe%" & wscript.scriptname & "%"")"

If svc.execquery(query).count > 1 Then
  ' Already running, so quit
  wscript.quit
End if
Set svc = nothing

Dim sho, fso
Set sho = WScript.CreateObject("Wscript.Shell")
set fso = CreateObject("Scripting.FileSystemObject")

' Read the first agrument given: the spice URL
SpiceURL = WScript.Arguments(0)

' Examine the USB Drive letter
dim CurrentDirectory
CurrentDirectory = fso.GetAbsolutePathName(".")
DriveLetter = fso.GetDriveName(CurrentDirectory)

' The Ini File
IniFile = fso.BuildPath(CurrentDirectory, "\.data\config\settings.conf")

' The logfile
LogFile = fso.BuildPath(CurrentDirectory, "\.data\logs\win-SpiceURLHandler.log")

' Open the logfile
Set objLogFile = fso.OpenTextFile(LogFile, 8, True) 

' Regex to check a spice URL
Set regex = new regexp
regex.Pattern = "spice://[a-zA-z0-9\.]+\?port=[0-9]+\&password=[a-zA-Z0-9\-]+$"

' Check the spice URL
if regex.Test(SpiceURL) Then
  ' Log the original URL
  objLogFile.Write Date & " " & Time & " - URL Pre: " & SpiceURL & vbCrLf

  SpiceClientBinary = fso.BuildPath(CurrentDirectory, GetInivalue( IniFile, "Windows", "SpiceClientBinary" ))
  SpiceClientArgs = GetInivalue( IniFile, "Windows", "SpiceClientArgs" )

  ' Log the extracted information
  objLogFile.Write Date & " " & Time & " - URL Post: " & SpiceURL & vbCrLf
  objLogFile.Write Date & " " & Time & " - Client: " & SpiceClientBinary & vbCrLf
  objLogFile.Write Date & " " & Time & " - CMD: " & SpiceClientBinary &  " " & SpiceClientArgs & " " & SpiceURL & vbCrLf

  ' Run the spice client with the URL as argument
  sho.Run(SpiceClientBinary & " " & SpiceClientArgs & " " & SpiceURL)
Else
  ' Log it, if it's not a valid spice URL and prompt a message box
  objLogFile.Write Date & " " & Time & " - Not a valid spice URL: " & SpiceURL & vbCrLf
  msgbox("This is not a valid spice URL: " & SpiceURL), 12, "SpiceURLHandler.vbs: Error"
End if

' Close the log file
objLogFile.Close
