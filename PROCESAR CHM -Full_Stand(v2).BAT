@echo off
title=CREANDO CHM ...
echo %1 
SET IN=%~dpf1
SET OUT=PROYECTO_CHM
set ME=%~dp0

echo IN: %IN%
echo OUT: %OUT%
echo.
title=Creando HHP-HHC-HHK ...
perl "%ME%\CREA_CHM - v3.5.PL" "%IN%" "%OUT%"
echo.
pause
cls
REM CALL HHC.EXE FICHERO.HHP
title=Compilando ...
echo Compilando ... Espera ...
"%ME%\hhc.exe" "%IN%\%OUT%.HHP" 
Rem >"%IN%\DEBUG.TXT"
Rem notepad "%IN%\DEBUG.TXT"
echo.
cls
title=Done
pause
