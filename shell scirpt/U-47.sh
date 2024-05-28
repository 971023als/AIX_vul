#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-47"
riskLevel="중"
diagnosisItem="패스워드 최대 사용기간 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-47"
diagnosisItem="패스워드 최대 사용기간 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 패스워드 최대 사용기간이 90일 이하로 설정된 경우
[취약]: 패스워드 최대 사용기간이 90일을 초과하여 설정된 경우
EOF

BAR

login_defs_path="/etc/security/login.cfg"

if [ -f "$login_defs_path" ]; then
    max_days=$(grep -i "^MAXWEEKS" "$login_defs_path" | grep -v '^#' | awk -F= '{print $2}' | tr -d ' ')
    if [ -n "$max_days" ]; then
        max_days=$((max_days * 7))  # Convert weeks to days
        if [ "$max_days" -gt 90 ]; then
            diagnosisResult="/etc/security/login.cfg 파일에 패스워드 최대 사용 기간이 90일을 초과하여 $max_days 일로 설정되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="패스워드 최대 사용기간이 90일 이하로 설정되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="/etc/security/login.cfg 파일에 패스워드 최대 사용 기간이 설정되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/security/login.cfg 파일이 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
