@echo off
echo Setting up Privacy-Policy repository...

cd c:\GitHub

REM Clone repo if it doesn't exist
if not exist "Privacy-Policy" (
    echo Cloning Privacy-Policy repository...
    git clone https://github.com/savargeir-byte/Privacy-Policy.git
)

cd Privacy-Policy

REM Copy template files
echo Copying Solar Eclipse legal documents...
copy /Y ..\Radio_App\Solareklips\docs\SolarEclipse_Privacy_Policy_TEMPLATE.md SolarEclipse_Privacy_Policy.md
copy /Y ..\Radio_App\Solareklips\docs\SolarEclipse_Terms_of_Use_TEMPLATE.md SolarEclipse_Terms_of_Use.md

REM Git add and commit
echo Committing changes...
git add SolarEclipse_Privacy_Policy.md SolarEclipse_Terms_of_Use.md
git commit -m "Add Solar Eclipse privacy policy and terms of use"

REM Push to GitHub
echo Pushing to GitHub...
git push

echo.
echo Done! Solar Eclipse legal documents are now in the Privacy-Policy repo.
echo URLs:
echo - Privacy: https://github.com/savargeir-byte/Privacy-Policy/blob/main/SolarEclipse_Privacy_Policy.md
echo - Terms: https://github.com/savargeir-byte/Privacy-Policy/blob/main/SolarEclipse_Terms_of_Use.md
echo.
pause
