@echo off
goto :main
:help:
setlocal
    echo.
    echo Usage: %~nx0 [Option]
    echo.
    echo    Reverse the order of a text file's newline terminated lines. 
    echo.
    echo Option: No options - perform reverse on STDIN.
    echo.
    echo    /v    Print version.
    echo.   /?    Display help.
    echo.
    echo  Visit: https://github.com/WhisperingChaos/WindowsBatchScripts/issues to report problems.
    echo.
    echo Note:
    echo    - The maximum length of a given line is bounded by Windows.  Due to bugs
    echo      and variations between Windows OS versions, a line length =^< 1024 bytes
    echo      should always work. However, the absolute maximum is limited to 4057
    echo      bytes due to "find" (see https://ss64.com/nt/find.html) and padding
    echo      added to facilitate sorting.
    echo.
    echo    - Current padding supports files with a maximum of 999,999,999 lines.
    echo      Processing this amount of data is beyond the scope of Windows Batch.
    echo      However, files around 10,000 smallish length lines, can be reversed 
    echo      within the order of single seconds on older equipment of 2007.
    echo.
    echo    - A byte value of 0x1A ASCII (SUB) represents EOF within a text file.
    echo      Encountering this value while reading an input stream using a piped
    echo      "type" command terminates this phase but continues reversing the
    echo      already consumed input.  However, a piped "more" command circumvents
    echo      this issue, as it treats 0x1A as an ordinary byte value, unlike "type".
    echo      Unfortunately, the "sort" command used to reverse lines scans for
    echo      0x1A and treats it as EOF.  Therefore, this script should operate
    echo      on only text files - not arbitrary binary ones that might include
    echo      0x1A anywhere within them.
    echo.      
    echo    - The reversed, resultant file will always be terminated by
    echo      a Windows newline character sequence: "0x0D 0x0A".  If the
    echo      original text file isn't terminated by this character sequence,
    echo      then besides appearing in reverse order, the files will differ by
    echo      this newline sequence.  Also, if the text file is terminated by
    echo      0x1A this value will be removed.  Therefore, even reversing 
    echo      a reversed text file might not yeild a binary duplicate of
    echo      the original.
    echo.
    call :versionEcho
endlocal
exit /b


:versionEcho:
    echo version: 0.6
exit /b


:main:
setlocal EnableDelayedExpansion
    set MYSELF=%~0

    if "%~1" == "/?" (
        call :help
        exit /b 0
    )
    if "%~1" == "/v" (
        call :versionEcho
        exit /b 0
    )
    :: global constant
    set PAD_LEN=9
    set PAD_DELIMINTERS_LEN=3
    set FIND_LINE_LEN_MAX=4091
    :: Maximum line length accepted is limited by FIND command, length of sort field (padding),
    :: length of FIND numbering that preserves empty lines, and delimiter characters "-[]"
    set /A REVERSE_LINE_LEN_MAX=%FIND_LINE_LEN_MAX%-%PAD_DELIMINTERS_LEN%-%PAD_LEN%*2

    if /i not "%~1" == "/p" (
        call :reversePipe "%MYSELF%"
        exit /b
    )
    if /i "%~2" == ":padAdd" (
        call :padAdd "%PAD_LEN%" "%REVERSE_LINE_LEN_MAX%"
        exit /b
    )
    if /i "%~2" == ":padRemove" (
        call :padRemove
        exit /b
    )
    echo Abort: logic error unknown phase='%~2'>&2
exit /b 1


:reversePipe:
setlocal
    set MYSELF=%~1

      "%MYSELF%" /p :padAdd^
    | sort /r^
    | "%MYSELF%" /p :padRemove

    if not %errorlevel% == 0 (
        endlocal
        exit /b 1
    )
endlocal
exit /b 0


:padAdd:
setlocal EnableDelayedExpansion
    set PAD_LEN=%~1
    set REVERSE_LINE_LEN_MAX=%~2

    if %PAD_LEN% lss 3 (
        echo Abort: PAD_LEN should be 3 or more characters.>&2
        endlocal
        exit /b 1 
    )
    for /L %%i in (0,1,%PAD_LEN%) do (
        set PAD_ZERO=!PAD_ZERO!0
    )
    set /A LINE_NUM=0
    :: /n argument below preserves empty line
    :: using caret (^) below to specify parameter values so eol
    :: becomes undefined instead of default ';'.
    :: also delims definition below defines no delims :: line will always be single token.
    for /F delims^=^ eol^= %%m in ('find /n /v ""') do (
        set /A LINE_NUM=!LINE_NUM! + 1
        set SORT_KEY=!PAD_ZERO!!LINE_NUM!
        set SORT_KEY=!SORT_KEY:~-%PAD_LEN%!
        set "LINE=!SORT_KEY!_%%m"
        echo !LINE:~0,%REVERSE_LINE_LEN_MAX%!
    )
endlocal
exit /b 0


:padRemove:
setlocal EnableDelayedExpansion 

    :: echo. special case to display empty line
    for /F delims^=^ eol^= %%m in ('more') do (
        set "LINE=%%m"
        if "!LINE:*]=!" == "" (
            echo.
        ) else (
            echo !LINE:*]=!
        )
    )
endlocal
exit /b 0