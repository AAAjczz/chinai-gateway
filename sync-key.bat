@echo off
REM sync-key.bat — 把中央 api key 同步到 chinai-gateway 的 .env，然后重启容器
REM 用法：改完 ~\.deepseek\api_key.txt 后，双击这个文件即可

for /f "delims=" %%k in (%USERPROFILE%\.deepseek\api_key.txt) do set "NEW_KEY=%%k"

powershell -Command "(gc 'D:\Projects\chinai-gateway\.env') -replace 'DEEPSEEK_API_KEY=.*', 'DEEPSEEK_API_KEY=%NEW_KEY%' | Out-File -Encoding utf8 'D:\Projects\chinai-gateway\.env'"

echo Key synced to .env. Restarting chinai-gateway...
cd /d D:\Projects\chinai-gateway
docker restart chinai-gateway

echo Done.
pause
