#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-48"
riskLevel="중"
diagnosisItem="패스워드 최소 사용기간 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-48"
diagnosisItem="패스워드 최소 사용기간 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 패스워드 최소 사용기간이 1일 이상으로 설정된 경우
[취약]: 패스워드 최소 사용기간이 1일 미만으로 설정된 경우
EOF

BAR

login_defs_path="/etc/security/login.cfg"

if [ -f "$login_defs_path" ]; then
    min_days=$(grep -i "^MINWEEKS" "$login_defs_path" | grep -v '^#' | awk -F= '{print $2}' | tr -d ' ')
    if [ -n "$min_days" ]; then
        min_days=$((min_days * 7))  # Convert weeks to days
        if [ "$min_days" -lt 1 ]; then
            diagnosisResult="/etc/security/login.cfg 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="패스워드 최소 사용기간이 1일 이상으로 설정되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="/etc/security/login.cfg 파일에 패스워드 최소 사용 기간이 설정되어 있지 않습니다."
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
