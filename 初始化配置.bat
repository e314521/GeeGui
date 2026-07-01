@echo off
chcp 65001 >nul
:: 设置输出文件名

set "CURRENT_DIR=%~dp0Delphi7\"
set "LIB_PATH=%CURRENT_DIR%lib"
set "LIB_OBJ_PATH=%CURRENT_DIR%lib\Obj"
set "OUTPUT_FILE=%CURRENT_DIR%bin\dcc32.cfg"

:: 第一行使用 > 清空文件并写入
echo -aWinTypes=Windows;WinProcs=Windows;DbiProcs=BDE;DbiTypes=BDE;DbiErrs=BDE > "%OUTPUT_FILE%"

:: 第二行使用 >> 追加写入
echo -u"%LIB_PATH%";"%LIB_OBJ_PATH%" >> "%OUTPUT_FILE%"


