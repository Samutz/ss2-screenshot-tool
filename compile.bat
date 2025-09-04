del /s /q .\Scripts\SS2_ScreenshotTool\
"..\..\Stock Game\Papyrus Compiler\PapyrusCompiler.exe" "project.ppj"

:: copy to CPC
@echo off
set "SOURCE=%CD%"
set "DEST=E:\CPC\mods\SS2 Screenshot Tool Scripts"

robocopy "%SOURCE%" "%DEST%" /E /MIR /R:3 /W:5  >nul 2>&1