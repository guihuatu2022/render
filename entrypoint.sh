#!/usr/bin/env bash

# Configuration initialization
base64 -d config > config.json 2>/dev/null
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
VMESS_WSPATH=${VMESS_WSPATH:-'/media/video/stream/1080p_h264_video_123.m3u8'}
VLESS_WSPATH=${VLESS_WSPATH:-'/media/video/stream/1080p_h264_video_112.m3u8'}
sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" config.json 2>/dev/null
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" /etc/nginx/nginx.conf 2>/dev/null

# Process obfuscation
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv v ${RELEASE_RANDOMNESS} 2>/dev/null
cat config.json | base64 > config 2>/dev/null
rm -f config.json

# Monitoring agent setup (optional)
TLS=${NEZHA_TLS:+'--tls'}
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget -q https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && echo '0' | ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY} ${TLS} >/dev/null 2>&1

# Start web services
nginx >/dev/null 2>&1
base64 -d config > config.json 2>/dev/null
./${RELEASE_RANDOMNESS} run >/dev/null 2>&1 &

# Keep container running
echo "Web server started successfully"
tail -f /dev/null