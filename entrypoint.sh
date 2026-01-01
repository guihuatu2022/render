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

# Nezha configuration - read variables
NEZHA_SERVER="${NEZHA_SERVER}"
NEZHA_PORT="${NEZHA_PORT}"
NEZHA_KEY="${NEZHA_KEY}"
NEZHA_TLS="${NEZHA_TLS}"

# Construct server address (combine server and port)
if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ]; then
    NEZHA_SERVER_ADDR="${NEZHA_SERVER}:${NEZHA_PORT}"
elif [ -n "${NEZHA_SERVER}" ]; then
    NEZHA_SERVER_ADDR="${NEZHA_SERVER}"
else
    NEZHA_SERVER_ADDR=""
fi

# Start Nezha Agent (if configured)
if [ -n "${NEZHA_SERVER_ADDR}" ] && [ -n "${NEZHA_KEY}" ]; then
    echo "Nezha Agent configuration detected"
    echo "Server: ${NEZHA_SERVER}"
    echo "Port: ${NEZHA_PORT}"
    echo "Full Address: ${NEZHA_SERVER_ADDR}"
    
    # Check if nezha-agent binary exists
    if [ -f "./nezha-agent" ]; then
        echo "Creating Nezha Agent config..."
        
        # Determine TLS setting (default to false if not set)
        if [ "${NEZHA_TLS}" = "true" ]; then
            TLS_SETTING="true"
            echo "TLS: enabled"
        else
            TLS_SETTING="false"
            echo "TLS: disabled (set NEZHA_TLS=true to enable)"
        fi
        
        # Create config file
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
        
        echo "Config file created at /app/nezha-config.yml"
        
        # Run nezha-agent in background
        nohup ./nezha-agent -c /app/nezha-config.yml >> /var/log/nezha-agent.log 2>&1 &
        NEZHA_PID=$!
        
        echo "Nezha Agent started with PID: ${NEZHA_PID}"
        
        # Wait and check status
        sleep 5
        
        if ps -p ${NEZHA_PID} > /dev/null 2>&1; then
            echo "✓ Nezha Agent is running successfully"
            echo "Recent logs:"
            tail -n 5 /var/log/nezha-agent.log 2>/dev/null || echo "No logs yet"
        else
            echo "✗ Nezha Agent process exited"
            echo "=== Full Nezha Agent Log ==="
            cat /var/log/nezha-agent.log 2>/dev/null || echo "No log file"
            echo "============================"
        fi
    else
        echo "Nezha Agent binary not found"
    fi
else
    echo "Nezha Agent not configured (need NEZHA_SERVER, NEZHA_PORT, NEZHA_KEY)"
fi

# Start web services
nginx >/dev/null 2>&1

base64 -d config > config.json 2>/dev/null
./${RELEASE_RANDOMNESS} run >/dev/null 2>&1 &

# Keep container running
echo "Web server started successfully"
tail -f /dev/null
