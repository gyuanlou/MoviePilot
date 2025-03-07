FROM python:3.10.11-slim
ARG MOVIEPILOT_FRONTEND_VERSION
ENV LANG="C.UTF-8" \
    HOME="/moviepilot" \
    TERM="xterm" \
    TZ="Asia/Shanghai" \
    PUID=0 \
    PGID=0 \
    UMASK=000 \
    MOVIEPILOT_AUTO_UPDATE=true \
    MOVIEPILOT_CN_UPDATE=false \
    NGINX_PORT=3000 \
    CONFIG_DIR="/config" \
    API_TOKEN="moviepilot" \
    AUTH_SITE="iyuu" \
    DOWNLOAD_PATH="/downloads" \
    DOWNLOAD_CATEGORY="false" \
    TORRENT_TAG="MOVIEPILOT" \
    LIBRARY_PATH="" \
    LIBRARY_CATEGORY="false" \
    TRANSFER_TYPE="copy" \
    COOKIECLOUD_HOST="https://nastool.org/cookiecloud" \
    COOKIECLOUD_KEY="" \
    COOKIECLOUD_PASSWORD="" \
    MESSAGER="telegram" \
    TELEGRAM_TOKEN="" \
    TELEGRAM_CHAT_ID="" \
    DOWNLOADER="qbittorrent" \
    QB_HOST="127.0.0.1:8080" \
    QB_USER="admin" \
    QB_PASSWORD="adminadmin" \
    MEDIASERVER="emby" \
    EMBY_HOST="http://127.0.0.1:8096" \
    EMBY_API_KEY=""
WORKDIR "/app"
COPY . .
RUN apt-get update \
    && apt-get -y install \
        musl-dev \
        nginx \
        gettext-base \
        locales \
        procps \
        gosu \
        bash \
        wget \
        curl \
        busybox \
    && cp -f /app/nginx.conf /etc/nginx/nginx.template.conf \
    && cp /app/update /usr/local/bin/mp_update \
    && chmod +x /app/start.sh /usr/local/bin/mp_update \
    && mkdir -p ${HOME} \
    && groupadd -r moviepilot -g 911 \
    && useradd -r moviepilot -g moviepilot -d ${HOME} -s /bin/bash -u 911 \
    && apt-get install -y build-essential \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && playwright install-deps chromium \
    && python_ver=$(python3 -V | awk '{print $2}') \
    && echo "/app/" > /usr/local/lib/python${python_ver%.*}/site-packages/app.pth \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf \
    && locale-gen zh_CN.UTF-8 \
    && curl -sL "https://github.com/jxxghp/MoviePilot-Frontend/releases/download/v${MOVIEPILOT_FRONTEND_VERSION}/dist.zip" | busybox unzip -d / - \
    && mv /dist /public \
    && apt-get remove -y build-essential \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf \
        /tmp/* \
        /moviepilot/.cache \
        /var/lib/apt/lists/* \
        /var/tmp/*
EXPOSE 3000
VOLUME ["/config"]
ENTRYPOINT [ "/app/start.sh" ]
