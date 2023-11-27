git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890
git config --global http.proxy
git status
git add .
git commit -m "update blog %date%,%time%"
git push -f blog_backup master
git config --global --unset http.proxy
echo ==========success==========
timeout /T 4 /NOBREAK