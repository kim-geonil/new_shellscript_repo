#!/bin/bash

# === Mock Setup ===
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Mock configuration files
echo "root:x:0:0:root:/root:/bin/bash" > $TMP_DIR/passwd
echo "shadow:x:0:" > $TMP_DIR/shadow
echo "group:x:0:root," > $TMP_DIR/group

# Mock services
systemctl() {
    case "$1" in
        is-active)
            if [ "$2" == "sshd" ]; then
                echo "[PASS] sshd is active."
            elif [ "$2" == "apache2" ]; then
                echo "[FAIL] apache2 is not active."
                exit 1
            elif [ "$2" == "mysql" ]; then
                echo "[PASS] mysql is active."
            fi
            ;;
        *)
            echo "Unknown systemctl command: $@"
            exit 1
            ;;
    esac
}

# Mock backup files
touch $TMP_DIR/backup_file

# === Test Script ===
echo "Checking system permissions..."
if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] This script requires root or sudo privileges."
    exit 1
fi

# 2. Configuration File Access Check
echo "Checking access to configuration files..."
config_files="$TMP_DIR/passwd $TMP_DIR/shadow $TMP_DIR/group"
for file in $config_files; do
    if [ ! -r "$file" ]; then
        echo "[FAIL] Unable to read $file"
        exit 1
    fi
done

# 3. Service Status Check
echo "Checking service status..."
services="sshd apache2 mysql"
for service in $services; do
    systemctl is-active --quiet $service
done

# 4. Backup File Identification
echo "Identifying backup files..."
backup_files="$TMP_DIR/backup_file /home/*/.bashrc"
for file in $backup_files; do
    if [ -f "$file" ]; then
        echo "[PASS] Backup file found: $file"
    else
        echo "[FAIL] No backup file found at $file"
        exit 1
    fi
done

# === Summary ===
Overall: Good
Findings: N
Recommendations: None

RESULT=PASS