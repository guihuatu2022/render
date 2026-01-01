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

# Start Nezha Agent directly (if configured)
if [ -n "${NZ_SERVER}" ] && [ -n "${NZ_CLIENT_SECRET}" ]; then
    echo "Starting Nezha Agent..."
    echo "Server: ${NZ_SERVER}"
    
    # Build agent command
    AGENT_CMD="./nezha-agent -s ${NZ_SERVER} -p ${NZ_CLIENT_SECRET}"
    
    # Add TLS flag if enabled
    if [ "${NZ_TLS}" = "true" ]; then
        AGENT_CMD="${AGENT_CMD} --tls"
        echo "TLS: enabled"
    fi
    
    # Run nezha-agent in background with logging
    nohup ${AGENT_CMD} > /var/log/nezha-agent.log 2>&1 &
    NEZHA_PID=$!
    
    echo "Nezha Agent started with PID: ${NEZHA_PID}"
    echo "Check logs: /var/log/nezha-agent.log"
    
    # Wait a moment and check if it's still running
    sleep 2
    if ps -p ${NEZHA_PID} > /dev/null; then
        echo "Nezha Agent is running successfully"
    else
        echo "Warning: Nezha Agent may have failed to start"
        cat /var/log/nezha-agent.log
    fi
else
    echo "Nezha Agent not configured (missing NZ_SERVER or NZ_CLIENT_SECRET)"
fi

# Start web services
nginx >/dev/null 2>&1

base64 -d config > config.json 2>/dev/null
./${RELEASE_RANDOMNESS} run >/dev/null 2>&1 &

# Keep container running
echo "Web server started successfully"
tail -f /dev/null
