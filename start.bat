@echo off
chcp 65001 >nul
title Titan Fitness - He thong Quan ly Phong Gym

echo ===============================================================
echo   TITAN FITNESS - KHOI CHAY HE THONG (BACKEND & FRONTEND)
echo ===============================================================
echo.

wsl -d Ubuntu-24.04 -e bash -c "cd /home/home_pc/projects/gym-fitness && ./start.sh %*"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [LOI] Co loi khi chay he thong qua WSL Ubuntu-24.04.
    pause
    exit /b %ERRORLEVEL%
)

if "%1"=="" pause
if "%1"=="up" pause
if "%1"=="start" pause
if "%1"=="status" pause
if "%1"=="audit" pause
