@echo off

set title=game
set target=.\game
set out=%title%.exe
set sdl_source=engine\3rd\sdl\bin\win\SDL3.dll

set debug_out=.out\debug
set release_out=.out\release

set build=odin build %target% -vet-semicolon -show-timings -collection:engine=./engine
set debug=%build% -debug -o:none -out:%debug_out%\%out%
set release=%build% -debug -o:none -out:%release_out%\%out%

echo Build of %title% started at %time%.

if "%1"=="release" (
    if not exist %release_out% mkdir %release_out%
    %release%
) else (
    if not exist %debug_out% mkdir %debug_out%
    %debug%
)

if %errorlevel%==0 (
    echo Build succeeded at %time%.
    
    if "%1"=="release" (
        copy /Y %sdl_source% %release_out% >nul
    ) else (
        copy /Y %sdl_source% %debug_out% >nul
    )
) else (
    echo Build failed.
)