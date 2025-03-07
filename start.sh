#!/bin/bash

# 使用 `envsubst` 将模板文件中的 ${NGINX_PORT} 替换为实际的环境变量值
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf
# 自动更新
if [ "${MOVIEPILOT_AUTO_UPDATE}" = "true" ]; then
    /usr/local/bin/mp_update
else
    echo "程序自动升级已关闭，如需自动升级请在创建容器时设置环境变量：MOVIEPILOT_AUTO_UPDATE=true"
fi
# 更改 moviepilot userid 和 groupid
groupmod -o -g ${PGID} moviepilot
usermod -o -u ${PUID} moviepilot
# 更改文件权限
chown -R moviepilot:moviepilot ${HOME} /app /config /etc/hosts
# 下载浏览器内核
gosu moviepilot:moviepilot playwright install chromium
# 启动前端nginx服务
nginx
# 设置后端服务权限掩码
umask ${UMASK}
# 启动后端服务
exec gosu moviepilot:moviepilot python3 app/main.py
