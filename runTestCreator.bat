@echo off
mkdir C:\TestCreator

REM Tải xuống tệp PowerShell
@echo Dơnload PowerShell file
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/HoanChan/download/raw/main/runTestCreator.ps1' -OutFile 'C:\TestCreator\runTestCreator.ps1' -UseBasicP"

REM Chạy tệp PowerShell với quyền admin
@echo Run PowerShell file
powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File C:\TestCreator\runTestCreator.ps1' -Verb RunAs"

REM Đếm ngược 15 giây
echo Done! Exit in
for /L %%i in (15,-1,1) do (
    echo %%i
    timeout /t 1 >nul
)
REM powershell -command "irm https://github.com/HoanChan/download/raw/main/runTestCreator.ps1 | iex"