@echo off
goto :main
::-----------------------------------------------------------------------------
::
::  Note:
::    Requires Windows default code page: 850 to successfully process asciiTbl.
::    Set code page to this default value using "chcp 850" command when running
::    as github action or in local environment where the asciiTbl test fails.
::
::-----------------------------------------------------------------------------
:main:
setlocal
  @echo on
  dir
  cd %~p0
  dir 
  ::call textFileReverse.cmd /v
  call .\textFileReverse.cmd /?
  @echo off
  exit /b
  
  call :githubActionPatch

  for %%f in (
      ":test_help"
      ":test_version"
      ":test_compare singleLine"
      ":test_compare doubleLine"
      ":test_compare tripleLine"
      ":test_compare doubleLine1024"
      ":test_compare singleLine4058"
      ":test_compare tripleLine4058"
      ":singleLine4059"
      ":test_compare file4091"
      ":test_compare file10000"
      ":test_compare space"
      ":test_compare tripleLineNewlineOnly"
      ":test_compare asciiTbl"
    ) do (
    call %%~f || ( echo Test failed: '%%~f' >&2 & goto :error)
    echo Test '%%~f' successfully completed.
  )
endlocal
exit /b 0


::-----------------------------------------------------------------------------
::
::  Function below is currently required when running the test in github's CI
::  pipeline in the cloud.  Although Windows supports the notion of a symlink
::  you must be an administrator to enable the use of this feature.  The
::  following workarounds were attempted but they failed:
::  -  Within the github CI yaml, used multiline "run:" to enable developer mode:
::     reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
::     immediately before calling this test command. 
::  -  Ran the "reg add" within the body of this script.  Again it reported that it
::     successfully executed but the link didn't work.
::  -  Ran the "reg add" as a step prior to the one that runs this command.
::
::  Registry changes may require a "restart" of the enviornment to recognized that
::  it's been enabled.
::
::  For now, hard code the directory reference when it's required.
::
::  Note:
::    Intentionally affecting caller's variable context, in order to include 
::    TEXT_FILE_REVERSE_CMD varible in its and its child functions.
::
::-----------------------------------------------------------------------------
:githubActionPatch:

  set TEXT_FILE_REVERSE_CMD=textFileReverse.cmd
  textFileReverse.cmd /v | findstr /r /c:"^version: 0\.5">nul
  if not %errorlevel% == 0 (
    set TEXT_FILE_REVERSE_CMD=..\component\textFileReverse.cmd
  )
  %TEXT_FILE_REVERSE_CMD% /v | findstr /r /c:"^version: 0\.5">nul
  if not %errorlevel% == 0 (
    endlocal
    exit /b 1
  )
exit /b 0


:error:
exit /b


:test_help:
  %TEXT_FILE_REVERSE_CMD% /? | findstr /r /c:"^Usage.*textFileReverse">nul
exit /b


:test_version:
  %TEXT_FILE_REVERSE_CMD% /v | findstr /r /c:"^version: 0\.5">nul
exit /b


:singleLine4059:
  call :test_compare "singleLine4059"
  if not %errorlevel% == 0 (
    del FileSystem\singleLine4059_out.txt>nul
    exit /b 0
  )
exit /b 1


:test_compare:
setlocal 
  set TEST_FILE_NAME=%~1

  more FileSystem\%TEST_FILE_NAME%.txt | %TEXT_FILE_REVERSE_CMD% >FileSystem\%TEST_FILE_NAME%_out.txt
  echo n|comp FileSystem\%TEST_FILE_NAME%_out.txt FileSystem\%TEST_FILE_NAME%_out_expected.txt >nul 2>nul
  if not %errorlevel% == 0 (
    endlocal
    exit /b 1
  )
  del FileSystem\%TEST_FILE_NAME%_out.txt>nul
endlocal 
exit /b 0
