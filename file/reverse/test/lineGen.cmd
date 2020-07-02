@echo off
setlocal EnableDelayedExpansion
for /L %%p in (1,1,4091) do (
    set /A BYTE=%%p%%10
    set LINE=!LINE!!BYTE!
)
echo %LINE%
endlocal
exit /b 0