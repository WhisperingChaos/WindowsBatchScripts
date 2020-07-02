@echo off
:main:
setlocal

echo current directory: %CD%
..\component\textFileReverse.cmd /v | findstr /r /c:"^version: 0\.5"
exit /b
::      ":test_help"
:: ":test_version"

  for %%f in (
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
