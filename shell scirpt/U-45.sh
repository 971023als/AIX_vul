#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-45"
riskLevel="하"
diagnosisItem="root 계정 su 제한"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-45"
diagnosisItem="root 계정 su 제한 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: /etc/pam.d/su 파일에 대한 설정이 적절하게 구성되어 있는 경우
[취약]: /etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않은 경우
EOF

BAR

pam_su_path="/etc/security/login.cfg"

if [ -f "$pam_su_path" ]; then
    pam_contents=$(cat "$pam_su_path")
    if echo "$pam_contents" | grep -q "auth\s*required\s*pam_wheel.so\s*use_uid"; then
        diagnosisResult="/etc/security/login.cfg 파일에 대한 설정이 적절하게 구성되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="/etc/security/login.cfg 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="/etc/security/login.cfg 파일이 존재하지 않습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
