@echo off
setlocal enabledelayedexpansion

set ROOT=%~dp0
cd /d "%ROOT%"

set SDK=%ProgramFiles(x86)%\Fractal Softworks\Starsector
set API="%SDK%\starsector-core\starfarer.api.jar"
set OBF="%SDK%\starsector-core\starfarer_obf.jar"
set JANINO="%SDK%\starsector-core\janino.jar"
set COMMONS="%SDK%\starsector-core\commons-compiler.jar"

if not exist %API% (
  echo Could not find starfarer.api.jar at %API%
  exit /b 1
)

set SRC=src
set OUT=out
set JARDIR=jars
set JAR=%JARDIR%\CommandSaturationProtocol.jar

if not exist "%OUT%" mkdir "%OUT%"
if not exist "%JARDIR%" mkdir "%JARDIR%"

set CP=%API%;%OBF%;%JANINO%;%COMMONS%

for /r "%SRC%" %%f in (*.java) do (
  set FILES=!FILES! "%%f"
)

javac -encoding UTF-8 -source 1.8 -target 1.8 -cp %CP% -d "%OUT%" %FILES%
if errorlevel 1 exit /b 1

pushd "%OUT%"
jar cfm "%ROOT%%JAR%" "%ROOT%MANIFEST.MF" *
popd

echo Built %JAR%

