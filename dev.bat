@echo off
REM Inicia la API y la WebUI de MoneyPrinterTurbo en ventanas separadas.
REM Uso: doble click o ejecutar "dev.bat" desde la raiz del proyecto.

REM Codificacion UTF-8 para que la consola muestre correctamente la enie y las tildes.
chcp 65001 >nul
set "PYTHONIOENCODING=utf-8"
set "PYTHONUTF8=1"

echo Iniciando MoneyPrinterTurbo...
start "MPT API" cmd /k "chcp 65001 >nul && set PYTHONIOENCODING=utf-8 && set PYTHONUTF8=1 && uv run python -X utf8 main.py"
timeout /t 3 /nobreak >nul
start "MPT WebUI" cmd /k "chcp 65001 >nul && call .\webui.bat"
echo.
echo   API   : http://127.0.0.1:8080/docs
echo   WebUI : http://127.0.0.1:8501
echo.
echo Ambas ventanas muestran sus propios logs. Cierra cada ventana para detener ese servicio.
