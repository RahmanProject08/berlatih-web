@echo off
if "%1"=="" (
    powershell -ExecutionPolicy Bypass -File "run.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "run.ps1" %1
)
