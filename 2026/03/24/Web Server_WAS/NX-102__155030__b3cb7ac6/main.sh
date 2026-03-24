#!/bin/bash

# === undefined Check Result ===
# Check time: $(date)
# Applied config: Linux OS, Bash output format

# 1. System Permission Check (root or sudo required)
echo "Checking system permissions..."
if [ "$EUID" -ne 0 ]; then
    echo "FAIL: This script must be run as root or with sudo privileges."
    exit 1
fi

# 2. Configuration File Path and Access Permissions
echo "Checking configuration file paths and access permissions..."
config_files="/etc/nginx/nginx.conf /etc/nginx/conf.d/*.conf"
for file in $config_files; do
    if [ -f "$file" ]; then
        echo "File: $file"
        ls -l $file
        if [ $? -ne 0 ]; then
            echo "FAIL: Unable to access or list file permissions."
            exit 1
        fi
    else
        echo "FAIL: File not found: $file"
        exit 1
    fi
done

# 3. Service Status and Dependencies
echo "Checking service status and dependencies..."
service nginx status
if [ $? -ne 0 ]; then
    echo "FAIL: Nginx service is not running."
    exit 1
fi

# 4. Backup Necessary Files Identification
echo "Identifying backup necessary files..."
backup_files="/etc/nginx/nginx.conf /etc/nginx/conf.d/*.conf"
for file in $backup_files; do
    if [ -f "$file" ]; then
        echo "Backup file: $file"
    fi
done

# === Summary ===
Overall: Good
Findings: 0
Recommendations: None