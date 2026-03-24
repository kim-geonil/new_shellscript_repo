#!/bin/bash

# === undefined Check Result ===
# Check time: $(date)
# Applied config: Linux OS, Bash output format

# 1. System Permissions Check
echo "Checking system permissions..."
if [ "$(id -u)" -ne 0 ]; then
    echo "[FAIL] Script must be run as root or with sudo."
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
backup_files="/var/backups /home/*/.bash_backup"
for file in $backup_files; do
    if [ -f "$file" ]; then
        echo "[PASS] Backup file found: $file"
    else
        echo "[FAIL] No backup files found."
        exit 1
    fi
done

# === Summary ===
Overall: Good
Findings: N
Recommendations: None