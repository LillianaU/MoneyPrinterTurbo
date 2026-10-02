@echo off
REM Inicia la API y la WebUI de MoneyPrinterTurbo en ventanas separadas.
REM Uso: doble click o ejecutar "dev.bat" desde la raiz del proyecto.

echo Iniciando MoneyPrinterTurbo...
start "MPT API" cmd /k "uv run python main.py"
timeout /t 3 /nobreak >nul
start "MPT WebUI" cmd /k "call .\webui.bat"
echo.
echo   API   : http://127.0.0.1:8080/docs
echo   WebUI : http://127.0.0.1:8501
echo.
echo Ambas ventanas muestran sus propios logs. Cierra cada ventana para detener ese servicio.
