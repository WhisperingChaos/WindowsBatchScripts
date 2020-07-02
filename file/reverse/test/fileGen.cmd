@echo off
setlocal
    for /L %%p in (1,1,10000) do (
        echo %%p
    )
endlocal
exit /b 0