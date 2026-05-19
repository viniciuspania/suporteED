@echo off
:: 1. VERIFICA E SOLICITA PRIVILÉGIOS DE ADMINISTRADOR
net session >nul 2>&1 || (powershell start -verb runas '%0' & exit /b)

chcp 65001 >nul
color 1F
title REPARADOR AUTOMÁTICO DE IMPRESSORA - EXPRESSO DELIVERY

cls
echo =====================================================================
echo          INICIANDO REPARO AUTOMÁTICO DA IMPRESSORA E QZ TRAY          
echo =====================================================================
echo.
echo [1/4] Parando o serviço de Spooler de Impressão do Windows...
net stop spooler /y >nul 2>&1
timeout /t 2 >nul

echo [2/4] Limpando a fila de documentos travados (Spooler)...
del /Q /F /S "%systemroot%\System32\Spool\Printers\*.*" >nul 2>&1
timeout /t 2 >nul

echo [3/4] Reiniciando o serviço de Spooler de Impressão...
net start spooler >nul 2>&1
timeout /t 2 >nul

echo [4/4] Encerrando e reiniciando o gerenciador de impressão QZ Tray...
taskkill /f /im "qz-tray.exe" >nul 2>&1
timeout /t 3 >nul

if exist "C:\Program Files\QZ Tray\qz-tray.exe" (
    echo [OK] Inicializando o QZ Tray novamente...
    start "" "C:\Program Files\QZ Tray\qz-tray.exe"
) else (
    echo [AVISO] QZ Tray não encontrado no caminho padrão.
)

echo.
echo =====================================================================
echo          [SUCESSO] Todos os procedimentos foram concluídos!          
echo =====================================================================
echo Fila de impressão limpa, serviços reiniciados e prontos para uso.
echo.
timeout /t 3
exit