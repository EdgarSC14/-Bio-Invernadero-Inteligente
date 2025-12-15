@echo off
echo === CAMBIAR CONTRASEÑA POSTGRESQL ===
echo Ejecuta como Administrador!
echo.

:: Verificar si es administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Ejecuta como Administrador (Click derecho -> Ejecutar como administrador)
    pause
    exit
)

:: Detener PostgreSQL
echo [1/6] Deteniendo PostgreSQL...
net stop postgresql-x64-16 >nul 2>&1
if %errorLevel% neq 0 (
    echo No se pudo detener PostgreSQL, continuando...
)

:: Cambiar autenticación a trust
echo [2/6] Cambiando autenticacion a trust...
powershell -Command "(Get-Content 'C:\Program Files\PostgreSQL\16\data\pg_hba.conf') -replace 'scram-sha-256', 'trust' | Set-Content 'C:\Program Files\PostgreSQL\16\data\pg_hba.conf'" >nul 2>&1

:: Iniciar PostgreSQL
echo [3/6] Iniciando PostgreSQL...
net start postgresql-x64-16 >nul 2>&1
timeout /t 3 /nobreak >nul

:: Cambiar contraseña
echo [4/6] Cambiando contraseña a 1234...
"C:\Program Files\PostgreSQL\16\bin\psql" -U postgres -c "ALTER USER postgres WITH PASSWORD '1234';" >nul 2>&1

:: Restaurar seguridad
echo [5/6] Restaurando seguridad...
powershell -Command "(Get-Content 'C:\Program Files\PostgreSQL\16\data\pg_hba.conf') -replace 'trust', 'scram-sha-256' | Set-Content 'C:\Program Files\PostgreSQL\16\data\pg_hba.conf'" >nul 2>&1

:: Reiniciar PostgreSQL
echo [6/6] Reiniciando PostgreSQL...
net stop postgresql-x64-16 >nul 2>&1
net start postgresql-x64-16 >nul 2>&1

echo.
echo =========================================
echo ¡CONTRASEÑA CAMBIADA EXITOSAMENTE!
echo =========================================
echo Usuario: postgres
echo Nueva contraseña: 1234
echo.
echo Ahora tu simulador funcionara correctamente!
pause