@echo off
goto :main
::-----------------------------------------------------------------------------
::
::  Note:
::  - Requires Windows default code page: 850 to successfully process asciiTbl.
::    Set code page to this default value using "chcp 850" command when running
::    as github action or in local environment where the asciiTbl test fails.
::  - Docker/Github Virtual Environment doesn't represent relative symbolic link
::    in repository directory correctly.  It eliminates the symlink property
::    then tries to run the contents of the symbolic file.  To circumvent this
::    issue, the github workflow yaml runs "del&mklink" to recreate the symbolic
::    file so it's once again a symbolic link. 
::
::-----------------------------------------------------------------------------
:main:
setlocal

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


:error:
exit /b


:test_help:
  textFileReverse.cmd /? | findstr /r /c:"^Usage.*textFileReverse">nul
exit /b


:test_version:
  textFileReverse.cmd /v | findstr /r /c:"^version: 0\.5">nul
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

  more FileSystem\%TEST_FILE_NAME%.txt | textFileReverse.cmd >FileSystem\%TEST_FILE_NAME%_out.txt
  echo n|comp FileSystem\%TEST_FILE_NAME%_out.txt FileSystem\%TEST_FILE_NAME%_out_expected.txt >nul 2>nul
  if not %errorlevel% == 0 (
    endlocal
    exit /b 1
  )
  del FileSystem\%TEST_FILE_NAME%_out.txt>nul
endlocal 
exit /b 0
