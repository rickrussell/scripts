@echo off
taskkill /f /im EXCEL.EXE
taskkill /f /im ONENOTE.EXE
taskkill /f /im OUTLOOK.EXE
taskkill /f /im POWERPNT.EXE
taskkill /f /im WINPROJ.EXE
taskkill /f /im VISIO.EXE
taskkill /f /im WINWORD.EXE
taskkill /f /im MSACCESS.EXE
taskkill /f /im MSPUB.EXE
taskkill /f /im lync.exe
taskkill /f /im groove.exe
taskkill /f /im msosync.exe

(

echo REGEDIT4
echo [HKEY_CURRENT_USER\Software\Microsoft\Office\15.0\Common\Identity]
echo "FederationProvider"=- ) > %TEMP%\94cf28e9-3a0e-4d3d-8161-d4b1d7bc94c0.reg

regedit /s %TEMP%\94cf28e9-3a0e-4d3d-8161-d4b1d7bc94c0.reg

del %TEMP%\94cf28e9-3a0e-4d3d-8161-d4b1d7bc94c0.reg
