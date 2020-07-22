@echo off
goto :main


:main:
setlocal
:: Test date difference interface using four digit (YYYY) dates
:: Then test date calculate past/future using four digit (YYYY) dates
for %%E in (
    "OneLeapYearDiffNegative :dateDiffAssert 20191231 - 20201231 2019 12 -366"
    "OneLeapYearDiffPositive :dateDiffAssert 20201231 - 20191231 2020 12 366"
    "20200721-19000101DiffPositive :dateDiffAssert 20200721 - 19000101 2020 7 44031"
    
    "OneLeapYearFuture :dateCalcAssert 20191231 + 366 2020 12 31"
    "OneLeapYearPast   :dateCalcAssert 20201231 - 366 2019 12 31"
) do  call :metaTestFieldExtract %%~E || goto :main_error

endlocal
exit /b 0
:main_error:
endlocal
exit /b 1


:metaTestFieldExtract:
setlocal
    set TEST_NAME=%~1
    set RTN_ASSERT=%~2

    echo Running test: %TEST_NAME%
    call %RTN_ASSERT% %3 %4 %5 %6 %7 %8 %9
    if not %errorlevel% == 0 (
        echo Test failed: %TEST_NAME%>&2
        exit /b 1
    )
endlocal
exit /b 0


:dateDiffAssert:
setlocal
    set DATE_START=%~1
    set DATE_OPER=%~2
    set DATE_END=%~3
    set YEAR_DIFF=%~4
    set MONTH_DIFF=%~5
    set DAY_DIFF=%~6

    call dateMath.cmd %DATE_START:~0,4% %DATE_START:~4,2% %DATE_START:~6,2% %DATE_OPER% %DATE_END:~0,4% %DATE_END:~4,2% %DATE_END:~6,2%>nul

    if not %errorlevel% == 0 (
        echo Error: Unexpected return code: %errorlevel% >&2
        endlocal
        exit /b 1
    )
    set rtnCode=0
    if not "%_yy_int%" ==  "%YEAR_DIFF%" (
        call :diffError "year" "%_yy_int%" "%YEAR_DIFF%"
        set rtnCode=1
    )
    if not "%_mm_int%" ==  "%MONTH_DIFF%" (
        call :diffError "month" "%_mm_int%" "%MONTH_DIFF%"
        set rtnCode=1
    )
    if not "%_dd_int%" ==  "%DAY_DIFF%" (
        call :diffError "day" "%_dd_int%" "%DAY_DIFF%"
        set rtnCode=1
    )
    if not %rtnCode% == 0 (
        endlocal
        exit /b 1
    )
endlocal
exit /b 0


:diffError:
setlocal
    set DIFF_UOM=%~1
    set DIFF_CALC=%~2
    set DIFF_EXPECTED=%~3

    echo Error: Calculated %DIFF_UOM% difference=%DIFF_CALC% not equal expected=%DIFF_EXPECTED%>&2

endlocal
exit /b 1 


:dateCalcAssert:
setlocal
    set DATE_START=%~1
    set DATE_OPER=%~2
    set INTERVAL_DAYS=%3
    set YEAR_EXPECTED=%~4
    set MONTH_EXPECTED=%~5
    set DAY_EXPECTED=%~6

    call dateMath.cmd %DATE_START:~0,4% %DATE_START:~4,2% %DATE_START:~6,2% %DATE_OPER% %INTERVAL_DAYS% >nul

    if not %errorlevel% == 0 (
        echo Error: Unexpected return code: %errorlevel% >&2
        endlocal
        exit /b 1
    )
    set rtnCode=0
    if not "%_yy_int%" ==  "%YEAR_EXPECTED%" (
        call :calcError "year" "%_yy_int%" "%YEAR_EXPECTED%"
        set rtnCode=1
    )
    if not "%_mm_int%" ==  "%MONTH_EXPECTED%" (
        call :calcError "month" "%_mm_int%" "%MONTH_EXPECTED%"
        set rtnCode=1
    )
    if not "%_dd_int%" ==  "%DAY_EXPECTED%" (
        call :calcError "day" "%_dd_int%" "%DAY_EXPECTED%"
        set rtnCode=1
    )
    if not %rtnCode% == 0 (
        endlocal
        exit /b 1
    )
endlocal
exit /b 0


:calcError:
setlocal
    set CALC_UOM=%~1
    set CALC=%~2
    set CALC_EXPECTED=%~3

    echo Error: Calculated %CALC_UOM%=%CALC% not equal expected=%CALC_EXPECTED%>&2

endlocal
exit /b 1