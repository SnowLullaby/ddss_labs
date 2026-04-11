@echo off
setlocal

docker compose exec client bash /opt/lab/scripts/demo_stage1.sh
if errorlevel 1 exit /b %errorlevel%
