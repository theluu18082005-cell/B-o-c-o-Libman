@echo off
setlocal
cd /d "%~dp0" || goto failed
if not exist "pom.xml" goto missing_project
if not exist "sql\mysql\libman_mysql.sql" goto missing_project

set "LIBMAN_LAUNCHER_MVN="
for /f "delims=" %%I in ('where.exe mvn.cmd 2^>nul') do if not defined LIBMAN_LAUNCHER_MVN set "LIBMAN_LAUNCHER_MVN=%%I"
if not defined LIBMAN_LAUNCHER_MVN if exist "%TEMP%\apache-maven-3.10.0\bin\mvn.cmd" set "LIBMAN_LAUNCHER_MVN=%TEMP%\apache-maven-3.10.0\bin\mvn.cmd"
if not defined LIBMAN_LAUNCHER_MVN goto missing_maven

set "LIBMAN_DB_URL=jdbc:mysql://localhost:3306/libman_b23dccn520?characterEncoding=UTF-8&sslMode=PREFERRED&allowPublicKeyRetrieval=true&connectTimeout=5000"
set "LIBMAN_DB_USER=root"
set "LIBMAN_DB_PASSWORD="
set "LIBMAN_MYSQL_SETUP=1"

echo LibMan - MySQL 8.0 at localhost:3306
echo Enter the root password used in MySQL Workbench. Typing is hidden.
powershell.exe -NoProfile -Command "$pw = Read-Host 'Mat khau root MySQL' -AsSecureString; try { $env:LIBMAN_DB_PASSWORD = [System.Net.NetworkCredential]::new('', $pw).Password; & $env:LIBMAN_LAUNCHER_MVN test-compile exec:java; exit $LASTEXITCODE } finally { Remove-Item Env:LIBMAN_DB_PASSWORD -ErrorAction SilentlyContinue }"
if errorlevel 1 goto failed
exit /b 0

:missing_project
echo Extract the ZIP first, then run this file from the folder containing pom.xml.
goto failed

:missing_maven
echo Maven was not found in PATH or in %%TEMP%%\apache-maven-3.10.0.
echo Install Maven or use the portable Maven already downloaded. See README.md.
goto failed

:failed
echo.
echo LibMan did not start. Check the error above.
pause
exit /b 1
