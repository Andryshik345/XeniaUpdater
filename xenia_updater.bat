::by GooseWing in 2024
@echo off
title Xenia Canary updater
cls
SetLocal EnableDelayedExpansion

cd /d "%~dp0"

echo:
echo Xenia Canary updater
echo:
echo Please ensure to use that script in the same folder of your Xenia.
echo:
echo:
echo:

echo Checking version
call :CheckGHVersion remote_ver
if exist "last_update.txt" (
	set local_ver=0
	for /F %%i in ('powershell -Command "Get-Content -Path "%~dp0last_update.txt""') do (set "local_ver=%%i")
	if not "!local_ver!" == "%remote_ver%" (
		call :DownloadRelease
		echo %remote_ver%>last_update.txt
	)
) else (
	echo Last update info not found, redownloading in any way
	call :DownloadRelease
	echo %remote_ver%>last_update.txt
)

goto LaunchXenia


:DownloadRelease
SetLocal EnableDelayedExpansion
if exist xenia_canary.exe (
	echo Backing up current version
	move /Y xenia_canary.exe xenia_canary.old >nul 2>&1
)
echo Downloading latest release
powershell -Command "Invoke-WebRequest https://github.com/xenia-canary/xenia-canary/releases/download/experimental/xenia_canary.zip -OutFile xenia_canary.zip"
echo Extracting
powershell Expand-Archive -Path xenia_canary.zip -DestinationPath .\ -Force
echo Deleting zip file
del xenia_canary.zip
echo Done!
echo:
EndLocal
exit /b

:CheckGHVersion
SetLocal EnableDelayedExpansion
set "url=https://api.github.com/repos/xenia-canary/xenia-canary/releases/tags/experimental"
set commit_hash=0
for /F "delims=" %%i in ('powershell -Command "Invoke-RestMethod -Uri '%url%' -Headers @{ 'User-Agent' = 'PowerShell' } | Select-Object -ExpandProperty target_commitish"') do (
	set commit_hash=%%i
)
EndLocal && (set "%~1=%commit_hash%")
exit /b

:LaunchXenia
echo Xenia is up-to-date, launching
start xenia_canary.exe
goto EOF

:EOF
EndLocal
choice /d y /t 3 > nul
exit /b
