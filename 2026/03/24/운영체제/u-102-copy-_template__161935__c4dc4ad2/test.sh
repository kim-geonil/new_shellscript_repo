#!/bin/bash

# === Mock Setup ===
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Mock configuration files
echo "root:x:0:0:root:/root:/bin/bash" > $TMP_DIR/passwd
echo "" > $TMP_DIR/shadow
echo "users:x:100:" > $TMP_DIR/group

# Mock backup files
touch $TMP_DIR/backup_file.txt

# Mock service status
systemctl() {
    case "$1" in
        is-active)
            if [ "$2" == "--quiet sshd" ]; then
                echo "active"
            elif [ "$2" == "--quiet cron" ]; then
                echo "inactive"
            fi
            ;;
        *)
            echo "Unknown command: $@"
            exit 1
            ;;
    esac
}

# === Mocked Main Script Execution ===
echo "Checking system permissions..."
if [ "$(id -u)" -ne 0 ]; then
    echo "[FAIL] Script must be run as root or with sudo."
    RESULT=FAIL
    exit 1
fi

echo "Checking access to configuration files..."
config_files="$TMP_DIR/passwd $TMP_DIR/shadow $TMP_DIR/group"
for file in $config_files; do
    if [ ! -r "$file" ]; then
        echo "[FAIL] Unable to read $file."
        RESULT=FAIL
        exit 1
    fi
done

echo "Checking service status..."
services="sshd cron"
for service in $services; do
    if systemctl is-active --quiet $service; then
        echo "[PASS] $service is active."
    else
        echo "[FAIL] $service is not active."
        RESULT=FAIL
        exit 1
    fi
done

echo "Identifying backup files..."
backup_files="$TMP_DIR/backup_file.txt"
for file in $backup_files; do
    if [ -f "$file" ]; then
        echo "[PASS] Backup file found: $file"
    else
        echo "[FAIL] No backup files found."
        RESULT=FAIL
        exit 1
    fi
done

# === Summary ===
Overall: Good
Findings: N
Recommendations: None

RESULT=$([[ "$RESULT" == "FAIL" ]] && echo "FAIL" || echo "PASS")
echo $RESULT