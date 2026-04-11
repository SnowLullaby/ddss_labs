@echo off
setlocal

docker compose up -d --build
if errorlevel 1 exit /b %errorlevel%

echo Cluster is starting.
echo Check readiness with: docker compose ps
echo Then run: demo.cmd
