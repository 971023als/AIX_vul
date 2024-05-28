#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-44"
riskLevel="중"
diagnosisItem="root 이외의 UID가 '0' 금지"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-44"
diagnosisItem="root 이외의 UID가 '0' 금지 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: root 계정 외에 UID 0을 갖는 계정이 존재하지 않는 경우
[취약]: root 계정과 동일한 UID(0)를 갖는 계정이 존재하는 경우
EOF

BAR

vulnerable=false

while IFS=: read -r username _ userid _; do
    if [ "$userid" == "0" ] && [ "$username" != "root" ]; then
        vulnerable=true
        diagnosisResult="root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: $username"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        break
    fi
done < /etc/passwd

if [ "$vulnerable" = false ]; then
    diagnosisResult="root 계정 외에 UID 0을 갖는 계정이 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
