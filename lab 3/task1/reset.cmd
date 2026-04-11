@echo off
setlocal

docker compose down -v --remove-orphans
if errorlevel 1 exit /b %errorlevel%
