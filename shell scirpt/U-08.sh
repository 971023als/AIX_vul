#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-08"
riskLevel="상"
diagnosisItem="/etc/security/passwd 파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/security/passwd 파일의 소유자가 root이고, 권한이 400 이하인 경우
[취약]: /etc/security/passwd 파일의 소유자가 root가 아니거나, 권한이 400을 초과하는 경우
EOF

# 변수 설정
security_passwd_file="/etc/security/passwd"
results_status="양호"
results_info=""

# /etc/security/passwd 파일 존재 여부 및 소유자, 권한 검사
if [ -e "$security_passwd_file" ]; then
    owner_uid=$(stat -c '%u' "$security_passwd_file")
    permissions=$(stat -c '%a' "$security_passwd_file")

    # 소유자가 root인지 확인
    if [ "$owner_uid" -eq 0 ]; then
        # 파일 권한이 400 이하인지 확인
        if [ "$permissions" -le 400 ]; then
            results_info="/etc/security/passwd 파일의 소유자가 root이고, 권한이 ${permissions}입니다."
        else
            results_status="취약"
            results_info="/etc/security/passwd 파일의 권한이 ${permissions}로 설정되어 있어 취약합니다."
        fi
    else
        results_status="취약"
        results_info="/etc/security/passwd 파일의 소유자가 root가 아닙니다."
    fi
else
    results_status="N/A"
    results_info="/etc/security/passwd 파일이 없습니다."
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$results_info,$results_status" >> $OUTPUT_CSV

# Log and output CSV
echo "현황: $results_info" >> $TMP1
echo "진단 결과: $results_status" >> $TMP1

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
