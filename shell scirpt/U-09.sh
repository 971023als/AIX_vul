#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-09"
riskLevel="상"
diagnosisItem="/etc/hosts 파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/hosts 파일의 소유자가 root이고, 권한이 600 이하인 경우
[취약]: /etc/hosts 파일의 소유자가 root가 아니거나, 권한이 600을 초과하는 경우
EOF

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

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$results_info,$results_status" >> $OUTPUT_CSV

# Log and output CSV
echo "현황: $results_info" >> $TMP1
echo "진단 결과: $results_status" >> $TMP1

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
