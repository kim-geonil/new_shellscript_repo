#!/bin/bash

# === undefined Check Result ===
# Check time: $(date)
# Applied config: targetOS=Linux, outputFormat=bash

# 1. System Permission Check
echo "Checking system permissions..."
if [ "$(id -u)" -ne 0 ]; then
    echo "[FAIL] This script must be run as root or with sudo privileges."
    exit 1
fi

# 2. Configuration File Access Check
CONFIG_FILE="/etc/nginx/nginx.conf"
echo "Checking access to $CONFIG_FILE..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[FAIL] $CONFIG_FILE does not exist."
    exit 1
fi
if [ ! -r "$CONFIG_FILE" ]; then
    echo "[FAIL] Cannot read $CONFIG_FILE."
    exit 1
fi

# 3. Service Status Check
echo "Checking NGINX service status..."
if systemctl is-active --quiet nginx; then
    echo "[PASS] NGINX is running."
else
    echo "[FAIL] NGINX is not running."
    exit 1
fi

# 4. Dependency Check
echo "Checking for required dependencies..."
REQUIRED_DEPS=("systemd" "nginx")
for DEP in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$DEP" &> /dev/null; then
        echo "[FAIL] $DEP is not installed."
        exit 1
    fi
done

# === Summary ===
echo "Overall: [Good]"
echo "Findings: N"
echo "Recommendations: None. Configuration appears to be in a good state."