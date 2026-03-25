#!/bin/bash

# Script Info
# ID: MON-102
# Category: 일반
# Difficulty: medium
# Risk: medium
# Description: MON-102 스크립트의 기본 설정 정보가 없어 자동 생성된 기본 메타데이터를 사용합니다.

# Generation Time: $(date)
# Applied Config: targetOS=Linux, outputFormat=bash

# Error handling
set -Eeuo pipefail
trap 'echo "Error occurred at line $LINENO"; exit 1' ERR

# Function to check MongoDB authentication
check_mongodb_auth() {
    local config_file="/etc/mongod.conf"
    
    # Check if the configuration file exists
    if [[ ! -f "$config_file" ]]; then
        echo "---   MON-102   ---"
        echo "MongoDB configuration file not found: $config_file"
        return 1
    fi
    
    # Load the entire config file into memory
    IFS=$'\n' read -r -d '' -a lines < "$config_file"
    
    # Search for 'security:' section and then 'authorization:'
    auth_enabled=false
    in_security_section=false
    for line in "${lines[@]}"; do
        if [[ $line == *"security:"* ]]; then
            in_security_section=true
        elif [[ $in_security_section && $line == *"authorization:"* ]]; then
            if [[ $line == *"enabled"* ]]; then
                auth_enabled=true
                break
            fi
        fi
    done
    
    # Output the result
    echo "---   MON-102   ---"
    if [ "$auth_enabled" = true ]; then
        echo "MongoDB authentication is enabled."
        return 0
    else
        echo "MongoDB authentication is disabled."
        return 1
    fi
}

# Main loop to perform checks
final_exit_code=0

echo "+++   MON-102   +++"
check_mongodb_auth
if [ $? -ne 0 ]; then
    final_exit_code=1
fi
echo "---   MON-102   ---"

# Output the final result
if [ "$final_exit_code" -eq 0 ]; then
    echo "Final Result: Pass"
else
    echo "Final Result: Fail"
fi