@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo [lab4] Starting Cassandra nodes sequentially...
echo.

echo [lab4] Starting seed node cassandra-1...
docker compose up -d cassandra-1
if errorlevel 1 exit /b 1

call :wait_un 1
if errorlevel 1 exit /b 1

echo.
echo [lab4] Starting cassandra-2...
docker compose up -d cassandra-2
if errorlevel 1 exit /b 1

call :wait_un 2
if errorlevel 1 exit /b 1

echo.
echo [lab4] Starting cassandra-3...
docker compose up -d cassandra-3
if errorlevel 1 exit /b 1

call :wait_un 3
if errorlevel 1 exit /b 1

echo.
echo [lab4] Cassandra cluster is ready.
docker compose exec -T cassandra-1 nodetool status

endlocal
exit /b 0


:wait_un
set "EXPECTED=%~1"
set /a ATTEMPT=0
set /a MAX_ATTEMPTS=60

:wait_loop
set /a ATTEMPT+=1
set "COUNT=0"

echo [wait] Checking Cassandra readiness, attempt !ATTEMPT!/%MAX_ATTEMPTS%...

docker compose exec -T cassandra-1 cqlsh -e "DESCRIBE KEYSPACES" >nul 2>nul
if errorlevel 1 (
    echo [wait] cqlsh is not ready yet.
) else (
    for /f %%C in ('docker compose exec -T cassandra-1 nodetool status 2^>nul ^| findstr /R /C:"^UN" ^| find /C /V ""') do set "COUNT=%%C"

    echo [wait] UN nodes: !COUNT!/%EXPECTED%

    if "!COUNT!"=="%EXPECTED%" (
        echo [wait] OK: expected UN node count reached.
        docker compose exec -T cassandra-1 nodetool status
        exit /b 0
    )
)

if !ATTEMPT! GEQ %MAX_ATTEMPTS% (
    echo.
    echo [wait] ERROR: expected %EXPECTED% UN nodes, but got !COUNT!.
    echo [wait] Current nodetool status:
    docker compose exec -T cassandra-1 nodetool status
    exit /b 1
)

timeout /t 5 /nobreak >nul
goto wait_loop
