#!/bin/bash

# AIX 시스템의 /etc/hosts.deny 와 /etc/hosts.allow 파일을 점검하여
# 접근 제어 설정이 적절한지 확인하는 스크립트

hosts_deny_path="/etc/hosts.deny"
hosts_allow_path="/etc/hosts.allow"
result=""
status=()
diagnostic="접속 IP 및 포트 제한 (AIX 특화)"

function check_file_exists_and_content {
    local file_path=$1
    local search_string=$2

    if [ -f "$file_path" ]; then
        if grep -qEi "$search_string" "$file_path" && ! grep -E "^#" "$file_path" | grep -qEi "$search_string"; then
            return 0 # True, found and not commented out
        fi
    fi
    return 1 # False, not found or file doesn't exist
}

# /etc/hosts.deny 파일 검증
if ! check_file_exists_and_content "$hosts_deny_path" "ALL: ALL"; then
    result="취약"
    status+=("$hosts_deny_path 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다.")
else
    # /etc/hosts.allow 파일 검증
    if check_file_exists_and_content "$hosts_allow_path" "ALL: ALL"; then
        result="취약"
        status+=("$hosts_allow_path 파일에 'ALL: ALL' 설정이 있습니다.")
    else
        result="양호"
        status+=("적절한 IP 및 포트 제한 설정이 확인되었습니다.")
    fi
fi

# 결과를 JSON 형태로 출력
echo "{"
echo "    \"분류\": \"네트워크 보안 설정\","
echo "    \"코드\": \"U-18\","
echo "    \"위험도\": \"상\","
echo "    \"진단 항목\": \"$diagnostic\","
echo "    \"진단 결과\": \"$result\","
echo "    \"현황\": ["
for ((i=0; i<${#status[@]}; i++)); do
    echo "        \"${status[$i]}\"$(if [[ $i -lt $((${#status[@]} - 1)) ]]; then echo ","; fi)"
done
echo "    ],"
echo "    \"대응방안\": \"AIX IPSec 또는 방화벽 규칙을 사용하여 특정 호스트 접근 제한\""
echo "}"
