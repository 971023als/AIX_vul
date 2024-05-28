#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-55"
riskLevel="하"
diagnosisItem="hosts.lpd 파일 소유자 및 권한 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-55"
diagnosisItem="hosts.lpd 파일 소유자 및 권한 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: hosts.lpd 파일이 없거나, root 소유 및 권한 600 설정된 경우
[취약]: hosts.lpd 파일이 root 소유가 아니거나, 권한이 600이 아닌 경우
EOF

BAR

hosts_lpd_path="/etc/hosts.lpd"

if [ -e "$hosts_lpd_path" ]; then
    file_owner=$(stat -c "%u" "$hosts_lpd_path")
    file_mode=$(stat -c "%a" "$hosts_lpd_path")

    if [ "$file_owner" != "0" ] || [ "$file_mode" != "600" ]; then
        diagnosisResult="hosts.lpd 파일이 root 소유가 아니거나, 권한이 600이 아님"
        status="취약"
        owner_status="root 소유가 아님"
        permission_status="권한이 600이 아님"
        [ "$file_owner" == "0" ] && owner_status="소유자 상태는 양호함"
        [ "$file_mode" == "600" ] && permission_status="권한 상태는 양호함"
        echo "WARN: $diagnosisResult ($owner_status, $permission_status)" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="hosts.lpd 파일이 root 소유이고, 권한이 600으로 설정됨"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="hosts.lpd 파일이 존재하지 않음"
    status="양호"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
