@echo off

:: =========================================================================
:: 1. VERIFICAÇÃO DE PRIVILÉGIOS DE ADMINISTRADOR (Modo Compatível)
:: =========================================================================
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%comspec%' -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: =========================================================================
:: 2. CONFIGURAÇÃO DE AMBIENTE E VARIÁVEIS
:: =========================================================================
chcp 65001 >nul
mode con: cols=90 lines=35
color 1F
title SUPORTE EXPRESSO DELIVERY - PRO

:: URLs de Download
set "GIT_RAW=https://raw.githubusercontent.com/viniciuspania/suporteED/main"
set "JAVA_URL=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=253195_f7fe8e644f724108bdb54139381e29a7"
set "QZ_URL=https://github.com/qzind/tray/releases/download/v2.2.4/qz-tray-2.2.4.exe"
set "URL_64=https://expressodelivery.com.br/downloads/gerenciadorqz_64.zip"
set "URL_32=https://expressodelivery.com.br/downloads/gerenciadorqz_32.zip"
set "WARP_URL=https://downloads.cloudflareclient.com/v1/download/windows/ga"

set "DL_DIR=%TEMP%\ExpressoDownloads"
if not exist "%DL_DIR%" mkdir "%DL_DIR%"

:menu
cls
echo =======================================================================
echo                 SUPORTE EXPRESSO DELIVERY - FERRAMENTAS
echo =======================================================================
echo.
echo  [1]  DNS e Conexao (Configurar Google DNS)
echo  [2]  Reparar Impressora e QZ (Reset Completo Spooler)
echo  [3]  Diagnostico (Verificar Java, QZ e Portas)
echo  [4]  Instalar JAVA (Modo Silencioso)
echo  [5]  Instalar QZ TRAY (Modo Silencioso)
echo  [6]  Listar Impressoras e Status
echo  [7]  Remover QZ e Java (Limpeza Profunda)
echo  [8]  Instalar Gerenciador (64 bits - Automatico)
echo  [9]  Instalar Gerenciador (32 bits - Automatico)
echo  [10] Correcao de Rede, SMB1 e Compartilhamento
echo  [11] Instalar Cloudflare WARP (Modo Silencioso)
echo  [12] Teste de Rede Completo (Ping/Tracert com Log)
echo  [13] Coletar Logs do Gerenciador (Zipar e Salvar Desktop)
echo  [14] Atualizar Horario Local (NTP.br)
echo  [15] Painel de Instalacao de Drivers (Impressoras)
echo.
echo  [0]  Sair
echo =======================================================================
echo.
set /p "opcao=Selecione uma opcao: "

if "%opcao%"=="1" goto dns
if "%opcao%"=="2" goto spooler
if "%opcao%"=="3" goto diag
if "%opcao%"=="4" goto inst_java
if "%opcao%"=="5" goto inst_qz
if "%opcao%"=="6" goto list_imp
if "%opcao%"=="7" goto remover_tudo
if "%opcao%"=="8" set "GERENCIADOR_URL=%URL_64%" & goto instalar_gerenciador
if "%opcao%"=="9" set "GERENCIADOR_URL=%URL_32%" & goto instalar_gerenciador
if "%opcao%"=="10" goto correcao_rede
if "%opcao%"=="11" goto inst_warp
if "%opcao%"=="12" goto teste_rede
if "%opcao%"=="13" goto coletar_logs
if "%opcao%"=="14" goto atualizar_horario
if "%opcao%"=="15" goto menu_drivers
if "%opcao%"=="0" exit
goto menu

:barra
cls
echo =======================================================================
echo                   SUPORTE EXPRESSO - EXECUTANDO TAREFA
echo =======================================================================
echo.
echo  Processo: %~2
echo  Progresso: [%~1%%]
echo.
exit /b

:menu_drivers
cls
echo =======================================================================
echo                       INSTALACAO DE DRIVERS
echo =======================================================================
echo.
echo  [1] Bematech 4200 TH       [5] Elgin I8
echo  [2] Bematech 4200 HS       [6] Elgin I9
echo  [3] Driver POS Universal   [7] Epson T20
echo  [4] Elgin I7               [8] Epson T20X
echo.
echo  [0] Voltar ao Menu Principal
echo =======================================================================
echo.
set /p "op_driver=Selecione o driver para instalacao: "

if "%op_driver%"=="1" set "NOME_DRIVER=Bematech 4200 TH" & set "ARQUIVO_DRV=bematch_4200th.zip" & goto baixar_driver
if "%op_driver%"=="2" set "NOME_DRIVER=Bematech 4200 HS" & set "ARQUIVO_DRV=bematch_4200hs.zip" & goto baixar_driver
if "%op_driver%"=="3" set "NOME_DRIVER=Driver POS Universal" & set "ARQUIVO_DRV=pos_universal.zip" & goto baixar_driver
if "%op_driver%"=="4" set "NOME_DRIVER=Elgin I7" & set "ARQUIVO_DRV=elgin_i7.zip" & goto baixar_driver
if "%op_driver%"=="5" set "NOME_DRIVER=Elgin I8" & set "ARQUIVO_DRV=elgin_i8.zip" & goto baixar_driver
if "%op_driver%"=="6" set "NOME_DRIVER=Elgin I9" & set "ARQUIVO_DRV=elgin_i9.zip" & goto baixar_driver
if "%op_driver%"=="7" set "NOME_DRIVER=Epson T20" & set "ARQUIVO_DRV=epson_t20.zip" & goto baixar_driver
if "%op_driver%"=="8" set "NOME_DRIVER=Epson T20X" & set "ARQUIVO_DRV=epson_t20x.zip" & goto baixar_driver
if "%op_driver%"=="0" goto menu
goto menu_drivers

:baixar_driver
set "PASTA_DRV=%DL_DIR%\%NOME_DRIVER%"
if exist "%PASTA_DRV%" rd /s /q "%PASTA_DRV%"
mkdir "%PASTA_DRV%"

call :barra 40 "Baixando Driver %NOME_DRIVER%..."
curl -L -o "%DL_DIR%\%ARQUIVO_DRV%" "%GIT_RAW%/drivers/%ARQUIVO_DRV%"
if not exist "%DL_DIR%\%ARQUIVO_DRV%" (
    echo [ERRO] Falha ao baixar o arquivo.
    pause & goto menu_drivers
)

call :barra 70 "Extraindo arquivos do instalador..."
powershell -Command "Expand-Archive -Path '%DL_DIR%\%ARQUIVO_DRV%' -DestinationPath '%PASTA_DRV%' -Force"
del /f /q "%DL_DIR%\%ARQUIVO_DRV%"

call :barra 90 "Iniciando instalador do driver..."
:: Entra na pasta do driver, procura por qualquer .exe ou .msi e o executa
pushd "%PASTA_DRV%"
set "INSTALADOR_FOUND="
for %%f in (*.exe *.msi) do (
    set "INSTALADOR_FOUND=%%f"
)

if defined INSTALADOR_FOUND (
    start "" "%INSTALADOR_FOUND%"
) else (
    echo [AVISO] O instalador executavel nao foi encontrado dentro do pacote.
    echo Abrindo a pasta para verificacao manual...
    explorer.exe "%PASTA_DRV%"
)
popd
goto menu_drivers

:dns
call :barra 50 "Configurando DNS Dinamico (Google)..."
netsh interface ip set dns name="Ethernet" source=static addr=8.8.8.8 primary >nul 2>&1
netsh interface ip add dns name="Ethernet" addr=8.8.4.4 index=2 >nul 2>&1
netsh interface ip set dns name="Wi-Fi" source=static addr=8.8.8.8 primary >nul 2>&1
netsh interface ip add dns name="Wi-Fi" addr=8.8.4.4 index=2 >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [SUCESSO] DNS Configurado!
pause & goto menu

:spooler
call :barra 30 "Parando servicos..."
taskkill /f /im "qz-tray.exe" >nul 2>&1
taskkill /f /im "printisolationhost.exe" >nul 2>&1
net stop spooler /y >nul 2>&1
call :barra 60 "Limpando Spooler..."
del /Q /F /S "%systemroot%\System32\Spool\Printers\*.*" >nul 2>&1
call :barra 80 "Reiniciando servicos..."
net start spooler >nul 2>&1
timeout /t 2 >nul
if exist "C:\Program Files\QZ Tray\qz-tray.exe" (
    start "" "C:\Program Files\QZ Tray\qz-tray.exe"
) else if exist "%LOCALAPPDATA%\Programs\qz-tray\qz-tray.exe" (
    start "" "%LOCALAPPDATA%\Programs\qz-tray\qz-tray.exe"
)
echo [SUCESSO] Impressao restaurada!
pause & goto menu

:diag
cls
echo [1/3] Versao do Java:
java -version 2>&1 || echo [AVISO] Java nao encontrado.
echo [2/3] Portas do QZ Tray (8181/8182):
netstat -ano | findstr "8181 8182" >nul && echo [OK] QZ Rodando || echo [ERRO] QZ Fechado
echo [3/3] Loopback:
ping 127.0.0.1 -n 2 >nul && echo [OK] TCP/IP OK || echo [ERRO] Falha TCP/IP
pause & goto menu

:inst_java
call :barra 40 "Baixando Java..."
curl -L -o "%DL_DIR%\java_install.exe" "%JAVA_URL%"
call :barra 80 "Instalando Java..."
start /wait "" "%DL_DIR%\java_install.exe" /s
del /f /q "%DL_DIR%\java_install.exe"
pause & goto menu

:inst_qz
call :barra 40 "Baixando QZ Tray..."
curl -L -o "%DL_DIR%\qz_install.exe" "%QZ_URL%"
call :barra 80 "Instalando QZ..."
start /wait "" "%DL_DIR%\qz_install.exe" /S
del /f /q "%DL_DIR%\qz_install.exe"
pause & goto menu

:instalar_gerenciador
set "DEST_DIR=%USERPROFILE%\Desktop\Gerenciador_Expresso"
if exist "%DEST_DIR%" rd /s /q "%DEST_DIR%"
mkdir "%DEST_DIR%" >nul 2>&1
call :barra 30 "Baixando Gerenciador..."
curl -L -o "%DL_DIR%\gerenciador.zip" "%GERENCIADOR_URL%"
call :barra 60 "Extraindo..."
powershell -Command "Expand-Archive -Path '%DL_DIR%\gerenciador.zip' -DestinationPath '%DEST_DIR%' -Force"
del /f /q "%DL_DIR%\gerenciador.zip"
pushd "%DEST_DIR%"
for %%f in (gerenciador_expresso*.exe) do start "" "%%f"
popd
pause & goto menu

:remover_tudo
taskkill /f /im "qz-tray.exe" >nul 2>&1
taskkill /f /im "java.exe" >nul 2>&1
rd /s /q "C:\Program Files\QZ Tray" >nul 2>&1
rd /s /q "C:\Program Files\Java" >nul 2>&1
reg delete "HKCU\Software\JavaSoft" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\JavaSoft" /f >nul 2>&1
echo [SUCESSO] Limpeza Concluida!
pause & goto menu

:correcao_rede
powershell -Command "Set-NetConnectionProfile -NetworkCategory Private" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "AllowInsecureGuestAuth" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Print" /v "RpcAuthnLevelPrivacyEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
echo [SUCESSO] Rede Corrigida! Reinicie o PC.
pause & goto menu

:inst_warp
call :barra 40 "Baixando WARP..."
curl -L -o "%DL_DIR%\warp.msi" "%WARP_URL%"
call :barra 80 "Instalando..."
msiexec /i "%DL_DIR%\warp.msi" /qn /norestart
del /f /q "%DL_DIR%\warp.msi"
pause & goto menu

:list_imp
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer | Select-Object Name, PortName, PrinterStatus | Format-Table -AutoSize; Write-Host 'ENTER para voltar...'; Read-Host"
goto menu

:teste_rede
cls
set /p "alvo=Digite a URL ou IP para testar (Ex: 8.8.8.8 ou google.com): "
call :barra 50 "Testando rede e gerando Log..."
set "LOG_REDE=%USERPROFILE%\Desktop\Log_Rede_Expresso.txt"
echo === TESTE DE REDE GERADO EM %date% as %time% === > "%LOG_REDE%"
echo. >> "%LOG_REDE%"
echo --- CONFIG DA REDE --- >> "%LOG_REDE%"
ipconfig /all >> "%LOG_REDE%"
echo. >> "%LOG_REDE%"
echo --- PING --- >> "%LOG_REDE%"
ping %alvo% -n 10 >> "%LOG_REDE%"
echo. >> "%LOG_REDE%"
echo --- TRACERT --- >> "%LOG_REDE%"
tracert %alvo% >> "%LOG_REDE%"

echo [SUCESSO] Teste concluido. Log salvo em: "%LOG_REDE%"
pause & goto menu

:coletar_logs
set "ORIGEM=%APPDATA%\Gerenciador de Pedidos\logs"
set "DESTINO=%USERPROFILE%\Desktop\Logs_Expresso.zip"
set "TEMP_LOGS=%DL_DIR%\temp_logs"
if exist "%TEMP_LOGS%" rd /s /q "%TEMP_LOGS%"
robocopy "%ORIGEM%" "%TEMP_LOGS%" /E /R:0 /W:0 >nul 2>&1
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('%TEMP_LOGS%', '%DESTINO%')"
rd /s /q "%TEMP_LOGS%"
echo Logs na Area de Trabalho!
pause & goto menu

:atualizar_horario
w32tm /config /manualpeerlist:"pool.ntp.br time.windows.com" /syncfromflags:manual /reliable:YES /update >nul 2>&1
net stop w32tm >nul 2>&1 & net start w32tm >nul 2>&1
w32tm /resync /force >nul 2>&1
pause & goto menu
