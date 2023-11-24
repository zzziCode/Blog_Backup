hugo 
cd public
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890
git config --global http.proxy
git status
git add .
git commit -m "update %date%,%time%"
git push -f origin master
git config --global --unset http.proxy
echo ==========success==========
timeout /T 4 /NOBREAK
exit
