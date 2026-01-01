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

# Nezha Agent setup (optional)
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ]; then
    # Construct server address
    NEZHA_SERVER_ADDR="${NEZHA_SERVER}:${NEZHA_PORT}"
    
    # Check if nezha-agent binary exists
    if [ -f "./nezha-agent" ]; then
        # Determine TLS setting
        if [ "${NEZHA_TLS}" = "true" ]; then
            TLS_SETTING="true"
        else
            TLS_SETTING="false"
        fi
        
        # Create Nezha config file
        cat > /app/nezha-config.yml <<EOF
server: ${NEZHA_SERVER_ADDR}
client_secret: ${NEZHA_KEY}
tls: ${TLS_SETTING}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 3
skip_connection_count: false
skip_procs_count: false
temperature: false
use_gitee_to_upgrade: false
use_ipv6_country_code: false
EOF
        
        # Start Nezha Agent in background
        nohup ./nezha-agent -c /app/nezha-config.yml >/dev/null 2>&1 &
    fi
fi

# Start web services
nginx >/dev/null 2>&1

base64 -d config > config.json 2>/dev/null
./${RELEASE_RANDOMNESS} run >/dev/null 2>&1 &

# Keep container running
echo "Web server started successfully"
tail -f /dev/null
