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
echo "Checking access to configuration files..."
config_files="/etc/passwd /etc/shadow /etc/group"
for file in $config_files; do
    if [ ! -r "$file" ]; then
        echo "[FAIL] Unable to read $file."
        exit 1
    fi
done

# 3. Service Status Check
echo "Checking service status..."
services="sshd cron"
for service in $services; do
    if systemctl is-active --quiet $service; then
        echo "[PASS] $service is active."
    else
        echo "[FAIL] $service is not active."
        exit 1
    fi
done

# 4. Backup File Identification
echo "Identifying backup files..."
backup_files="/etc/backup /var/backups"
for file in $backup_files; do
    if [ -d "$file" ]; then
        echo "[PASS] Backup directory $file exists."
    else
        echo "[FAIL] Backup directory $file does not exist."
        exit 1
    fi
done

# === Summary ===
Overall: Good
Findings: N
Recommendations: None