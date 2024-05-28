#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안 설정"
code="U-18"
riskLevel="상"
diagnosisItem="접속 IP 및 포트 제한 (AIX 특화)"
service="Network Management"
diagnosisResult=""
status=""

hosts_deny_path="/etc/hosts.deny"
hosts_allow_path="/etc/hosts.allow"
result=""
status_list=()

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
    diagnosisResult="취약"
    status_list+=("$hosts_deny_path 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다.")
else
    # /etc/hosts.allow 파일 검증
    if check_file_exists_and_content "$hosts_allow_path" "ALL: ALL"; then
        diagnosisResult="취약"
        status_list+=("$hosts_allow_path 파일에 'ALL: ALL' 설정이 있습니다.")
    else
        diagnosisResult="양호"
        status_list+=("적절한 IP 및 포트 제한 설정이 확인되었습니다.")
    fi
fi

# Combine status messages into a single string
status=$(IFS="; " ; echo "${status_list[*]}")

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Display the result
echo "category: $category"
echo "code: $code"
echo "riskLevel: $riskLevel"
echo "diagnosisItem: $diagnosisItem"
echo "service: $service"
echo "diagnosisResult: $diagnosisResult"
echo "status: $status"

cat $OUTPUT_CSV
