@echo off
::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBxBRQiOAE60EKYg/O3o+9aJpktQRPsrcIDV5rCPNOEv40bre4URxmNUnM1CBRhXHg==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpSI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBNQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBxBRQiOAE60EKYg/O3o+9aJpktQRPsrcIDV5rqKJq4W8kCE
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
:: Development helper, used locally and by the CI
::   dev.bat install : create the virtual environment .venv and install the dependencies
::   dev.bat test    : check the dependencies and run the tests
::   dev.bat run     : launch the application (arguments are passed through)
::   dev.bat exe     : generate ndf.exe from this script (needs Bat To Exe Converter)
::   dev.bat         : install then test
setlocal

SET "ROOT=%~dp0"
SET "VENV_PYTHON=%ROOT%.venv\Scripts\python.exe"

IF DEFINED b2eprogramfilename GOTO :launch
IF "%~1"=="" GOTO :all
IF /I "%~1"=="install" GOTO :install
IF /I "%~1"=="test" GOTO :test
IF /I "%~1"=="run" GOTO :run_command
IF /I "%~1"=="exe" GOTO :exe
ECHO Usage: dev.bat [install^|test^|run [arguments]^|exe]
EXIT /B 1

:all
CALL :install || EXIT /B 1
CALL :test
EXIT /B %ERRORLEVEL%

:install
IF NOT EXIST "%VENV_PYTHON%" (
    ECHO Creating the virtual environment .venv
    python -m venv "%ROOT%.venv" || EXIT /B 1
)
"%VENV_PYTHON%" -m pip install -e "%ROOT%.[dev]" || EXIT /B 1
EXIT /B 0

:test
CALL :check_venv || EXIT /B 1
:: Run Qt without display
SET "QT_QPA_PLATFORM=offscreen"
"%VENV_PYTHON%" -m pip check || EXIT /B 1
PUSHD "%ROOT%"
"%VENV_PYTHON%" -m pytest tests -ra
SET "RESULT=%ERRORLEVEL%"
POPD
EXIT /B %RESULT%

:run_command
SHIFT
CALL :check_venv || EXIT /B 1
GOTO :launch

:exe
:: The path of the converter can be overridden with the environment variable B2E
IF NOT DEFINED B2E SET "B2E=%ProgramFiles%\Bat To Exe Converter\Bat_To_Exe_Converter.exe"
IF NOT EXIST "%B2E%" (
    ECHO Bat To Exe Converter not found: "%B2E%"
    ECHO Install it from https://www.f2ko.de/en/b2e.php or set B2E to its path.
    EXIT /B 1
)
"%B2E%" /bat "%ROOT%dev.bat" /exe "%ROOT%ndf.exe" /icon "%ROOT%data\icons\pyndf.ico" /overwrite || EXIT /B 1
EXIT /B 0

:launch
:: When compiled, use the executable's directory as the repository root.
SET "NDF_EXE="
IF DEFINED b2eprogramfilename SET "NDF_EXE=%b2eprogramfilename:"=%"
IF DEFINED NDF_EXE FOR %%I IN ("%NDF_EXE%") DO SET "ROOT=%%~dpI"
SET "VENV_PYTHON=%ROOT%.venv\Scripts\python.exe"

IF NOT EXIST "%VENV_PYTHON%" (
    ECHO Virtual environment not found: "%VENV_PYTHON%"
    ECHO Create it with "dev.bat install" at the root of the repository.
    IF DEFINED NDF_EXE PAUSE
    EXIT /B 1
)

:: Bat To Exe Converter may pass the executable path as the first argument.
IF DEFINED NDF_EXE IF /I "%~1"=="%NDF_EXE%" SHIFT

:: Forward the arguments as they were given (an empty "" argument doesn't stop the loop)
SET NDF_ARGS=
:collect_args
IF [%1]==[] GOTO :execute
SET NDF_ARGS=%NDF_ARGS% %1
SHIFT
GOTO :collect_args

:execute
"%VENV_PYTHON%" "%ROOT%src\pyndf\main.py"%NDF_ARGS%
SET "NDF_ERROR=%ERRORLEVEL%"

IF NOT "%NDF_ERROR%"=="0" (
    ECHO The application stopped with the error code %NDF_ERROR%.
    IF DEFINED NDF_EXE PAUSE
)
EXIT /B %NDF_ERROR%

:check_venv
IF NOT EXIST "%VENV_PYTHON%" (
    ECHO Virtual environment not found, run "dev.bat install" first.
    EXIT /B 1
)
EXIT /B 0
