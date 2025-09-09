powershell -Command "$PSDefaultParameterValues['*:Encoding'] = 'utf8'"
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
powershell .\setup.ps1