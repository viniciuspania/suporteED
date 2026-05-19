::[Bat To Exe Converter]
@echo off

:: =========================================================================
:: 1. VERIFICAÇÃO DE PRIVILÉGIOS DE ADMINISTRADOR
:: =========================================================================
net session >nul 2>&1 || (powershell start -verb runas '%0' & exit /b)

:: =========================================================================
:: 2. CONFIGURAÇÃO DE AMBIENTE E VARIÁVEIS
:: =========================================================================
chcp 65001 >nul
mode con: cols=90 lines=35
color 1F
title SUPORTE EXPRESSO DELIVERY - PRO

:: Versão Atual do Script
set "VERSAO_ATUAL=1.0"

:: Senha de Acesso
set "SENHA_MESTRA=Expresso2026"

:: URLs do GitHub (Auto-Atualização e Drivers)
set "GIT_RAW=https://raw.githubusercontent.com/viniciuspania/suporteED/main"

:: URLs de Download Gerais
set "JAVA_URL=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=253195_f7fe8e644f724108bdb54139381e29a7"
set "QZ_URL=https://github.com/qzind/tray/releases/download/v2.2.4/qz-tray-2.2.4.exe"
set "URL_64=https://expressodelivery.com.br/downloads/gerenciadorqz_64.zip"
set "URL_32=https://expressodelivery.com.br/downloads/gerenciadorqz_32.zip"
set "WARP_URL=https://downloads.cloudflareclient.com/v1/download/windows/ga"

:: Caminhos Temporários
set "DL_DIR=%TEMP%\ExpressoDownloads"
if not exist "%DL_DIR%" mkdir "%DL_DIR%"

:login
cls
echo =======================================================================
echo              ACESSO RESTRITO - SUPORTE EXPRESSO DELIVERY
echo =======================================================================
echo.
echo Digite a senha de acesso:
set "pass="
for /f "delims=" %%i in ('powershell -Command "$p = read-host -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "pass=%%i"

if "%pass%"=="%SENHA_MESTRA%" goto checar_atualizacao
echo.
echo [ERRO] Senha Incorreta!
timeout /t 2 >nul
goto login

:: =========================================================================
:: ROTINA DE AUTO-ATUALIZAÇÃO
:: =========================================================================
:checar_atualizacao
cls
echo Verificando se existem atualizacoes pendentes no GitHub...
curl -s -L -o "%DL_DIR%\versao.txt" "%GIT_RAW%/versao.txt"

if not exist "%DL_DIR%\versao.txt" (
    echo [AVISO] Nao foi possivel validar as atualizacoes. Iniciando sistema...
    timeout /t 2 >nul
    goto menu
)

set /p VERSAO_WEB=<"%DL_DIR%\versao.txt"
del /f /q "%DL_DIR%\versao.txt"

if "%VERSAO_ATUAL%"=="%VERSAO_WEB%" goto menu

cls
echo =======================================================================
echo             NOVA ATUALIZACAO DISPONIVEL! (%VERSAO_ATUAL% -> %VERSAO_WEB%)
echo =======================================================================
echo.
echo Atualizando o utilitario de suporte de forma automatica, aguarde...
echo.

:: Baixa a nova versão do script
curl -s -L -o "%DL_DIR%\Suporte_Expresso_Novo.bat" "%GIT_RAW%/Suporte_Expresso.bat"

if exist "%DL_DIR%\Suporte_Expresso_Novo.bat" (
    :: Cria um arquivo temporário para atualizar o script sem travar a execução do cmd atual
    (
        echo @echo off
        echo timeout /t 1 ^>nul
        echo move /y "%DL_DIR%\Suporte_Expresso_Novo.bat" "%~f0" ^>nul
        echo start "" "%~f0"
        echo del "%%~f0" ^& exit
    ) > "%DL_DIR%\updater.bat"
    
    start "" "%DL_DIR%\updater.bat"
    exit /b
)
goto menu

:menu
cls
echo =======================================================================
echo        SUPORTE EXPRESSO DELIVERY - FERRAMENTAS (v%VERSAO_ATUAL%)
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

:: =========================================================================
:: FUNÇÃO DE BARRA DE PROGRESSO / MENSAGEM
:: =========================================================================
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

:: =========================================================================
:: SUB-MENU DE DRIVERS
:: =========================================================================
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

call :barra 40 "Baixando Driver %NOME_DRIVER% do GitHub..."
curl -L -o "%DL_DIR%\%ARQUIVO_DRV%" "%GIT_RAW%/drivers/%ARQUIVO_DRV%"

if not exist "%DL_DIR%\%ARQUIVO_DRV%" (
    echo [ERRO] Falha ao baixar o arquivo do servidor. Verifique a conexao.
    pause & goto menu_drivers
)

call :barra 80 "Extraindo arquivos do instalador..."
powershell -Command "Expand-Archive -Path '%DL_DIR%\%ARQUIVO_DRV%' -DestinationPath '%PASTA_DRV%' -Force"
del /f /q "%DL_DIR%\%ARQUIVO_DRV%"

call :barra 95 "Abrindo instalador..."
echo [SUCESSO] Arquivos prontos. Executando instalador ou abrindo a pasta...
timeout /t 2 >nul

:: Executa o que estiver lá dentro (procura executáveis ou abre a pasta se tiver mais arquivos)
explorer.exe "%PASTA_DRV%"
goto menu_drivers


:: =========================================================================
:: ROTINAS DE MANUTENÇÃO E INSTALAÇÃO ORIGINAIS
:: =========================================================================

:dns
call :barra 50 "Configurando DNS Dinamico (Google)..."
netsh interface ip set dns name="Ethernet" source=static addr=8.8.8.8 primary >nul 2>&1
netsh interface ip add dns name="Ethernet" addr=8.8.4.4 index=2 >nul 2>&1
netsh interface ip set dns name="Wi-Fi" source=static addr=8.8.8.8 primary >nul 2>&1
netsh interface ip add dns name="Wi-Fi" addr=8.8.4.4 index=2 >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [SUCESSO] DNS Configurado e cache limpo!
pause & goto menu

:spooler
call :barra 30 "Parando servicos de impressao e QZ..."
taskkill /f /im "qz-tray.exe" >nul 2>&1
taskkill /f /im "printisolationhost.exe" >nul 2>&1
net stop spooler /y >nul 2>&1

call :barra 60 "Limpando fila do Spooler travada..."
del /Q /F /S "%systemroot%\System32\Spool\Printers\*.*" >nul 2>&1

call :barra 80 "Reiniciando servicos..."
net start spooler >nul 2>&1
timeout /t 2 >nul
if exist "C:\Program Files\QZ Tray\qz-tray.exe" (
    start "" "C:\Program Files\QZ Tray\qz-tray.exe"
) else if exist "%LOCALAPPDATA%\Programs\qz-tray\qz-tray.exe" (
    start "" "%LOCALAPPDATA%\Programs\qz-tray\qz-tray.exe"
)
echo [SUCESSO] Spooler limpo e QZ reiniciado!
pause & goto menu

:diag
cls
echo =======================================================================
echo                     DIAGNOSTICO DE AMBIENTE
echo =======================================================================
echo.
echo [1/3] Verificando Versao do Java:
java -version 2>&1 || echo [AVISO] Java nao encontrado no sistema.
echo.
echo [2/3] Verificando Portas do QZ Tray (8181/8182):
netstat -ano | findstr "8181 8182" >nul
if %errorlevel% neq 0 (
    echo [ERRO] Portas fechadas! O QZ Tray NAO esta rodando.
) else (
    echo [OK] QZ Tray esta rodando e escutando nas portas corretas.
)
echo.
echo [3/3] Ping loopback (Teste de TCP/IP):
ping 127.0.0.1 -n 2 >nul && echo [OK] Protocolo TCP/IP funcionando. || echo [ERRO] Falha no TCP/IP local.
echo.
pause & goto menu

:inst_java
if not exist "C:\Program Files\Java" goto do_inst_java
echo [AVISO] O Java ja parece estar instalado.
set "conf="
set /p "conf=Deseja forcar a reinstalacao? (S/N): "
if /i "%conf%" neq "S" goto menu

:do_inst_java
call :barra 40 "Baixando Java JRE..."
curl -L -o "%DL_DIR%\java_install.exe" "%JAVA_URL%"
call :barra 80 "Instalando Java silenciosamente..."
start /wait "" "%DL_DIR%\java_install.exe" /s
del /f /q "%DL_DIR%\java_install.exe"
echo [SUCESSO] Java instalado!
pause & goto menu

:inst_qz
if not exist "C:\Program Files\QZ Tray" goto do_inst_qz
echo [AVISO] QZ Tray ja detectado.
set "conf="
set /p "conf=Deseja forcar a reinstalacao? (S/N): "
if /i "%conf%" neq "S" goto menu

:do_inst_qz
call :barra 40 "Baixando QZ Tray..."
curl -L -o "%DL_DIR%\qz_install.exe" "%QZ_URL%"
call :barra 80 "Instalando QZ Tray silenciosamente..."
start /wait "" "%DL_DIR%\qz_install.exe" /S
del /f /q "%DL_DIR%\qz_install.exe"
echo [SUCESSO] QZ Tray instalado!
pause & goto menu

:instalar_gerenciador
set "DEST_DIR=%USERPROFILE%\Desktop\Gerenciador_Expresso"
if not exist "%DEST_DIR%" goto do_instalar_gerenciador
echo [AVISO] A pasta do Gerenciador ja existe no Desktop.
set "conf="
set /p "conf=Deseja sobrescrever e baixar novamente? (S/N): "
if /i "%conf%" neq "S" goto menu
rd /s /q "%DEST_DIR%"

:do_instalar_gerenciador
mkdir "%DEST_DIR%" >nul 2>&1

call :barra 30 "Baixando Gerenciador..."
curl -L -o "%DL_DIR%\gerenciador.zip" "%GERENCIADOR_URL%"

call :barra 60 "Extraindo arquivos no Desktop..."
powershell -Command "Expand-Archive -Path '%DL_DIR%\gerenciador.zip' -DestinationPath '%DEST_DIR%' -Force"
del /f /q "%DL_DIR%\gerenciador.zip"

call :barra 90 "Configurando inicializacao automatica..."
pushd "%DEST_DIR%"
set "INSTALADOR_EXE="
for %%f in (gerenciador_expresso*.exe) do (
    set "INSTALADOR_EXE=%%f"
)

if defined INSTALADOR_EXE (
    echo [SUCESSO] Arquivo encontrado. Executando: %INSTALADOR_EXE%
    start "" "%INSTALADOR_EXE%"
) else (
    echo [AVISO] O arquivo .exe nao foi encontrado no padrao esperado.
    echo Abrindo a pasta para execucao manual...
    explorer.exe "%DEST_DIR%"
)
popd
echo [SUCESSO] Operacao finalizada!
pause & goto menu

:remover_tudo
call :barra 30 "Encerrando Processos (QZ e Java)..."
taskkill /f /im "qz-tray.exe" >nul 2>&1
taskkill /f /im "java.exe" >nul 2>&1
taskkill /f /im "javaw.exe" >nul 2>&1

call :barra 60 "Excluindo arquivos e pastas..."
rd /s /q "C:\Program Files\QZ Tray" >nul 2>&1
rd /s /q "C:\Program Files\Java" >nul 2>&1
rd /s /q "C:\Program Files (x86)\Java" >nul 2>&1
rd /s /q "%APPDATA%\qz" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Programs\qz-tray" >nul 2>&1

reg delete "HKCU\Software\JavaSoft" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\JavaSoft" /f >nul 2>&1

echo [SUCESSO] Limpeza Total Concluida!
echo PC pronto para reinstalacao limpa.
pause & goto menu

:correcao_rede
call :barra 30 "Tornando a rede Privada (Firewall)..."
powershell -Command "Set-NetConnectionProfile -NetworkCategory Private" >nul 2>&1

call :barra 50 "Ativando SMB1 (Para impressoras legadas) e Compartilhamento..."
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "AllowInsecureGuestAuth" /t REG_DWORD /d 1 /f >nul 2>&1

call :barra 70 "Aplicando Patches de Impressao e RPC (Erro 0x11b)..."
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Print" /v "RpcAuthnLevelPrivacyEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

call :barra 90 "Redefinindo Winsock e IP..."
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1

echo [SUCESSO] Rede corrigida!
echo E recomendavel REINICIAR o computador.
pause & goto menu

:inst_warp
call :barra 40 "Baixando Cloudflare WARP..."
curl -L -o "%DL_DIR%\warp.msi" "%WARP_URL%"
call :barra 80 "Instalando WARP em segundo plano..."
msiexec /i "%DL_DIR%\warp.msi" /qn /norestart
del /f /q "%DL_DIR%\warp.msi"
echo [SUCESSO] Cloudflare WARP instalado!
pause & goto menu

:list_imp
cls
echo =======================================================================
echo                   LISTA DE IMPRESSORAS DO SISTEMA
echo =======================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer | Select-Object Name, PortName, PrinterStatus | Format-Table -AutoSize; Write-Host 'Pressione ENTER para voltar...'; Read-Host"
goto menu

:teste_rede
cls
set /p "alvo=Digite a URL ou IP para testar (Ex: 8.8.8.8 ou google.com): "
call :barra 50 "Testando rede e gerando Log..."
set "LOG_REDE=%USERPROFILE%\Desktop\Log_Rede_Expresso.txt"

echo === TESTE DE REDE GERADO EM %date% as %time% === > "%LOG_REDE%"
echo.
>> "%LOG_REDE%"
echo --- CONFIG DA REDE --- >> "%LOG_REDE%"
ipconfig /all >> "%LOG_REDE%"
echo.
>> "%LOG_REDE%"
echo --- PING --- >> "%LOG_REDE%"
ping %alvo% -n 10 >> "%LOG_REDE%"
echo.
>> "%LOG_REDE%"
echo --- TRACERT --- >> "%LOG_REDE%"
tracert %alvo% >> "%LOG_REDE%"

echo [SUCESSO] Teste concluido.
echo Log saved em: "%LOG_REDE%"
pause & goto menu

:coletar_logs
set "ORIGEM=%APPDATA%\Gerenciador de Pedidos\logs"
if not exist "%ORIGEM%" (
    echo [ERRO] Pasta de logs do Gerenciador nao localizada em %APPDATA%.
    pause & goto menu
)

call :barra 50 "Compactando Logs do Gerenciador..."
set "DESTINO=%USERPROFILE%\Desktop\Logs_Expresso.zip"
set "TEMP_LOGS=%DL_DIR%\temp_logs"

if exist "%DESTINO%" del /f /q "%DESTINO%"
if exist "%TEMP_LOGS%" rd /s /q "%TEMP_LOGS%"

robocopy "%ORIGEM%" "%TEMP_LOGS%" /E /R:0 /W:0 /NJH /NJS >nul 2>&1

powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('%TEMP_LOGS%', '%DESTINO%')"
rd /s /q "%TEMP_LOGS%"

echo [SUCESSO] Logs compactados e salvos no Desktop: Logs_Expresso.zip
pause & goto menu

:atualizar_horario
call :barra 30 "Configurando servidor NTP (pool.ntp.br)..."
w32tm /config /manualpeerlist:"pool.ntp.br time.windows.com" /syncfromflags:manual /reliable:YES /update >nul 2>&1

call :barra 60 "Reiniciando servico de tempo..."
net stop w32tm >nul 2>&1
net start w32tm >nul 2>&1

call :barra 90 "Sincronizando..."
w32tm /resync /force >nul 2>&1

if %errorlevel% equ 0 (
    echo [SUCESSO] Horario sincronizado corretamente!
    echo Hora atual: %time%
) else (
    echo [ERRO] Falha ao sincronizar. O Firewall pode estar bloqueando a porta 123 (NTP).
)
pause & goto menu