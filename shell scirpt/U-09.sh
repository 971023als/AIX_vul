#!/bin/bash

# Variables
hosts_file="/etc/hosts"
results_status="양호"
results_info=""

# Check if /etc/hosts exists
if [ -e "$hosts_file" ]; then
    # Get owner and permissions
    owner_uid=$(stat -c '%u' "$hosts_file")
    permissions=$(stat -c '%a' "$hosts_file")

    # Check if owner is root
    if [ "$owner_uid" -eq 0 ]; then
        # Check file permissions
        if [ "$permissions" -le 600 ]; then
            results_info="/etc/hosts 파일의 소유자가 root이고, 권한이 ${permissions}입니다."
        else
            results_status="취약"
            results_info="/etc/hosts 파일의 권한이 ${permissions}로 설정되어 있어 취약합니다."
        fi
    else
        results_status="취약"
        results_info="/etc/hosts 파일의 소유자가 root가 아닙니다."
    fi
else
    results_status="N/A"
    results_info="/etc/hosts 파일이 없습니다."
fi

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"파일 및 디렉터리 관리\","
echo "  \"코드\": \"U-09\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"/etc/hosts 파일 소유자 및 권한 설정\","
echo "  \"진단 결과\": \"$results_status\","
echo "  \"현황\": [\"$results_info\"],"
echo "  \"대응방안\": \"/etc/hosts 파일의 소유자가 root이고, 권한이 600 이하인 경우\""
echo "}"
