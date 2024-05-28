#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="패치 관리"
code="U-42"
riskLevel="상"
diagnosisItem="최신 보안패치 및 벤더 권고사항 적용"
service="패치 관리"
diagnosisResult=""
status=""

BAR

CODE="U-42"
diagnosisItem="최신 보안패치 및 벤더 권고사항 적용 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 시스템은 최신 보안 패치를 보유하고 있습니다.
[취약]: 시스템에 보안 패치가 필요합니다.
EOF

BAR

# AIX 시스템에서 설치된 패치 정보를 확인
patch_info=$(instfix -i | grep 'Not Applied' | wc -l)

if [ "$patch_info" -eq 0 ]; then
    diagnosisResult="시스템은 최신 보안 패치를 보유하고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="시스템에 보안 패치가 필요합니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
