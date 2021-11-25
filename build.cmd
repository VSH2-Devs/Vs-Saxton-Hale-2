@ECHO OFF
powershell -NoLogo -NoProfile -ExecutionPolicy ByPass -Command "& """%~dp0build.ps1"""  %*"
EXIT /B %ERRORLEVEL%