@echo off
chcp 65001 >nul
title CONFIGURAR E ENVIAR PARA O GITHUB

:: Configuração de identidade (Altere para os seus dados do GitHub se necessário)
set /p "USER_NAME=Digite seu nome de usuario do GitHub: "
set /p "USER_EMAIL=Digite seu e-mail do GitHub: "

echo.
echo [1/5] Inicializando o repositorio local...
git init

echo.
echo [2/5] Vinculando ao seu repositorio remoto...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/viniciuspania/suporteED.git
git branch -M main

echo.
echo [3/5] Configurando credenciais locais...
git config --local user.name "%USER_NAME%"
git config --local user.email "%USER_EMAIL%"

echo.
echo [4/5] Adicionando arquivos e criando o commit...
git add .
git commit -m "Upload da estrutura inicial com atualizador e pasta de drivers"

echo.
echo [5/5] Enviando arquivos para o GitHub...
echo ATENCAO: Uma janela do navegador podera abrir para autenticar sua conta.
echo.
git push -u origin main --force

echo.
echo =======================================================================
echo          PROCESSO CONCLUIDO! VERIFIQUE SEU REPOSITORIO NO GIT
echo =======================================================================
pause