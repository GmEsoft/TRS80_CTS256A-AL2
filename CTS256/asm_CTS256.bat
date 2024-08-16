@echo off
set NAME=CTS256
set ZMAC=..\ZMAC\ZMAC

echo CP/M Exec     - CTS256.COM
%ZMAC% --zmac %NAME%.ASM -P0=2 --od . --oo CIM,LST,BDS -f
if errorlevel 1 pause && goto :eof
move %NAME%.CIM %NAME%.COM
if errorlevel 1 pause && goto :eof

echo LS-DOS Driver - CTS256/DVR
%ZMAC% --zmac %NAME%.ASM -P0=4 --od . --oo CMD,LST,BDS -f
if errorlevel 1 pause && goto :eof
move %NAME%.CMD %NAME%.DVR
if errorlevel 1 pause && goto :eof

echo LS-DOS Filter - CTS256/FLT
%ZMAC% --zmac %NAME%.ASM -P0=5 --od . --oo CMD,LST,BDS -f
if errorlevel 1 pause && goto :eof
move %NAME%.CMD %NAME%.FLT
if errorlevel 1 pause && goto :eof

echo LS-DOS Exec   - CTS256/CMD
%ZMAC% --zmac %NAME%.ASM -P0=3 --od . --oo CMD,LST,BDS -f
if errorlevel 1 pause && goto :eof

echo Build successful.
