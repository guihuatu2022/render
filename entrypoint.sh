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

# Nezha configuration - support both old and new variable names
NEZHA_SERVER_ADDR="${NZ_SERVER:-${NEZHA_SERVER}}"
NEZHA_CLIENT_KEY="${NZ_CLIENT_SECRET:-${NEZHA_KEY}}"
NEZHA_USE_TLS="${NZ_TLS:-${NEZHA_TLS}}"

# Start Nezha Agent (if configured)
if [ -n "${NEZHA_SERVER_ADDR}" ] && [ -n "${NEZHA_CLIENT_KEY}" ]; then
    echo "Nezha Agent configuration detected"
    echo "Server: ${NEZHA_SERVER_ADDR}"
    
    # Check if nezha-agent binary exists
    if [ -f "./nezha-agent" ]; then
        echo "Creating Nezha Agent config..."
        
        # Create config file for new version
        cat > /app/nezha-config.yml <<EOF
client_secret: ${NEZHA_CLIENT_KEY}
debug: false
disable_auto_update: false
disable_command_execute: false
disable_force_update: false
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 1
skip_connection_count: false
skip_procs_count: false
temperature: false
tls: ${NEZHA_USE_TLS:-false}
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: ""
EOF

        # Add server address to config
        if [ -n "${NEZHA_SERVER_ADDR}" ]; then
            echo "server: ${NEZHA_SERVER_ADDR}" >> /app/nezha-config.yml
        fi
        
        echo "Starting Nezha Agent with config file..."
        
        # Run nezha-agent in background with config file
        nohup ./nezha-agent -c /app/nezha-config.yml > /var/log/nezha-agent.log 2>&1 &
        NEZHA_PID=$!
        
        echo "Nezha Agent started with PID: ${NEZHA_PID}"
        
        # Wait and check status
        sleep 3
        if ps -p ${NEZHA_PID} > /dev/null 2>&1; then
            echo "Nezha Agent is running successfully"
        else
            echo "Warning: Nezha Agent may have failed to start"
            echo "=== Nezha Agent Log ==="
            [ -f /var/log/nezha-agent.log ] && cat /var/log/nezha-agent.log
            echo "======================="
        fi
    else
        echo "Nezha Agent binary not found, trying to download..."
        if wget --timeout=10 -qO nezha-agent.zip "https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip" 2>/dev/null; then
            unzip -q nezha-agent.zip 2>/dev/null
            chmod +x nezha-agent 2>/dev/null
            rm -f nezha-agent.zip
            echo "Nezha Agent downloaded, please restart the service"
        else
            echo "Failed to download Nezha Agent"
        fi
    fi
else
    echo "Nezha Agent not configured (set NZ_SERVER and NZ_CLIENT_SECRET to enable)"
fi

# Start web services
nginx >/dev/null 2>&1

base64 -d config > config.json 2>/dev/null
./${RELEASE_RANDOMNESS} run >/dev/null 2>&1 &

# Keep container running
echo "Web server started successfully"
tail -f /dev/null
