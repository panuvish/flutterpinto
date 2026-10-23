@echo off
echo ========================================
echo  Building Pinto App - Windows (Dev)
echo ========================================

:: Read version from pubspec.yaml
for /f "tokens=2 delims= " %%a in ('findstr /B "version:" pubspec.yaml') do set FULL_VERSION=%%a
for /f "tokens=1 delims=+" %%a in ("%FULL_VERSION%") do set VERSION=%%a
echo  Version: %VERSION%
echo ========================================

echo.
echo [1/5] Killing existing pinto_app.exe...
taskkill /f /im pinto_app.exe >nul 2>&1

echo.
echo [Setup] Preparing Dev Environment...
if exist .env copy /Y .env .env.bak >nul
if exist .env.dev (
    copy /Y .env.dev .env >nul
) else (
    echo .env.dev not found!
    pause
    exit /b 1
)

echo.
echo [4/5] Building Windows release (Dev)...
call fvm flutter build windows --dart-define=flavor=dev
if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED!
    if exist .env.bak (
        move /Y .env.bak .env >nul
    ) else (
        if exist .env del .env
    )
    pause
    exit /b 1
)

echo.
echo [5/5] Creating zip...
set ZIP_NAME=Pinto-Windows-Dev-v%VERSION%.zip
set RELEASE_DIR=%~dp0build\windows\x64\runner\Release
set OUTPUT_ZIP=%~dp0build\%ZIP_NAME%

:: Delete old zip if exists
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"

:: Use PowerShell to create zip
powershell -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%OUTPUT_ZIP%' -Force"

if %errorlevel% neq 0 (
    echo.
    echo ZIP FAILED!
    if exist .env.bak (
        move /Y .env.bak .env >nul
    ) else (
        if exist .env del .env
    )
    pause
    exit /b 1
)

echo.
echo ========================================
echo  BUILD SUCCESS!
echo  Output: build\%ZIP_NAME%
echo ========================================

if exist .env.bak (
    move /Y .env.bak .env >nul
) else (
    if exist .env del .env
)

pause
