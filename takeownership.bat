:::::::::::::::::::::::::::::::::::::::::::
:: Take Ownership of UnityEngine.CoreModule.dll + Assembly-CSharp.dll - Prevent DMM from patching your stuff
:: Partly by Globalnet
:: V 1.6 - 4/21/2020
:: Requires Administrator Privileges
:: Run in your \alicegearaegisexe\alice_Data\Managed folder
::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4 -Matt from StackOverflow
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description and source
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Take Ownership of UnityEngine.CoreModule.dll + Assembly-CSharp.dll - Prevent DMM from patching your stuff
 ECHO Partly by Globalnet - V 1.6 - 4/21/2020
 ECHO UAC elevate portion by Matt from StackOverflow
 ECHO Run in your \alicegearaegisexe\alice_Data\Managed folder
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::Ownership taking code here
 ::::::::::::::::::::::::::::

takeown /F UnityEngine.CoreModule.dll
attrib +R UnityEngine.CoreModule.dll
takeown /F Assembly-CSharp.dll

ECHO Changing privs now. Confirmation required
ECHO Change privs for UnityEngine.CoreModule.dll?
ECHO y | cacls UnityEngine.CoreModule.dll  /P Everyone:r "Authenticated Users:R" "Users:R" SYSTEM:R Administrators:R

ECHO Assembly-CSharp.dll options
ECHO 1.) Enable editing (DMM will also be able to patch the file)
ECHO 2.) Disable editing 
set /p input=?


IF "%input%"=="1" GOTO :1
IF "%input%"=="2" GOTO :2
:2
attrib +R Assembly-CSharp.dll
ECHO Change privs for Assembly-CSharp.dll?
ECHO y | cacls Assembly-CSharp.dll  /P Everyone:r "Authenticated Users:R" "Users:R" SYSTEM:R Administrators:R
ECHO 
ECHO Done!
pause
exit
:end 
:1
ECHO Change privs for Assembly-CSharp.dll?
ECHO y | cacls Assembly-CSharp.dll  /P Everyone:C "Authenticated Users:C" "Users:C" SYSTEM:C Administrators:C
attrib -R Assembly-CSharp.dll
:end
ECHO Done!
pause
exit
