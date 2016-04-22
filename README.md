# Install
```sh
sudo cnpm install -g chrome-cookie-decryptor
```

# Get chrome key in Mac
```sh
security find-generic-password -w -s "Chrome Safe Storage"
```

# Command line
```sh
decryptor cookie文件路径 chrome钥匙串 [cookie的host] [cookie的名字]

# 导出所有cookie
decryptor cookie-file your-chrome-key

# 导出host为10.2.69.69的cookie
decryptor cookie-file your-chrome-key cookie-host

# 导出10.2.69.69下名字为LBCLUSTERID的cookie
decryptor cookie-file your-chrome-key cookie-host cookie-name

```
