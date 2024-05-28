#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-03"
riskLevel="상"
diagnosisItem="계정 잠금 임계값 설정"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 계정 잠금 임계값이 10회 이하로 설정된 경우
[취약]: 계정 잠금 임계값이 10회를 초과하여 설정된 경우
EOF

# 변수 설정
file_path="/etc/security/user"
status="양호"
conditions=()

# 파일 존재 여부 확인
if [ -f "$file_path" ]; then
    # loginretries 설정 검사
    while IFS= read -r line; do
        if [[ ! $line =~ ^# && $line =~ loginretries ]]; then
            loginretries_value=$(echo $line | awk -F"=" '{print $2}' | tr -d ' ')
            if [ "$loginretries_value" -le 10 ]; then
                conditions+=("계정 잠금 임계값이 적절히 설정되었습니다.")
            else
                conditions+=("$file_path에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")
                status="취약"
            fi
            break
        fi
    done < "$file_path"
else
    conditions+=("적절한 계정 잠금 임계값 설정이 없습니다.")
    status="취약"
fi

if [ "$status" == "취약" ]; then
    diagnosisResult="계정 잠금 임계값이 10회를 초과하여 설정되었습니다."
    for condition in "${conditions[@]}"; do
        echo "WARN: $condition" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$condition,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="계정 잠금 임계값이 적절히 설정되었습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
