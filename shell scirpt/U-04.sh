#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-04"
riskLevel="상"
diagnosisItem="패스워드 파일 보호"
service="Password Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 패스워드 정보가 안전하게 암호화되어 저장되며 /etc/security/passwd 파일의 권한 설정이 적절한 경우
[취약]: 패스워드 정보가 안전하게 암호화되어 저장되지 않았거나 /etc/security/passwd 파일의 권한 설정이 적절하지 않은 경우
EOF

# 변수 설정
security_passwd_file="/etc/security/passwd"
status="양호"
conditions=()

# /etc/security/passwd 파일 존재 및 권한 설정 검사
if [ -f "$security_passwd_file" ]; then
    # 파일 권한 검사 (읽기 전용으로 설정되어 있는지 확인)
    if [ ! -r "$security_passwd_file" ]; then
        conditions+=("/etc/security/passwd 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
        status="취약"
    fi
else
    conditions+=("/etc/security/passwd 파일이 존재하지 않습니다.")
    status="취약"
fi

if [ "$status" == "양호" ]; then
    diagnosisResult="패스워드 정보가 안전하게 암호화되어 저장되며 /etc/security/passwd 파일의 권한 설정이 적절합니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="패스워드 정보가 안전하게 암호화되어 저장되지 않았거나 /etc/security/passwd 파일의 권한 설정이 적절하지 않습니다."
    for condition in "${conditions[@]}"; do
        echo "WARN: $condition" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$condition,$status" >> $OUTPUT_CSV
    done
fi

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
