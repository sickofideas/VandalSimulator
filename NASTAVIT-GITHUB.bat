@echo off
chcp 65001 >nul
title 3D Vandal Simulator - Nastaveni Gitu a GitHubu
cd /d "%~dp0"
echo ========================================================
echo   3D Vandal Simulator - Automaticke nastaveni GitHubu
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "Tools\setup-github.ps1"
echo.
pause
