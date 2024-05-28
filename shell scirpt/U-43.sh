#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="로그 관리"
code="U-43"
riskLevel="상"
diagnosisItem="로그의 정기적 검토 및 보고"
service="로그 관리"
diagnosisResult=""
status=""

BAR

CODE="U-43"
diagnosisItem="로그의 정기적 검토 및 보고 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그 파일이 존재하는 경우
[취약]: 로그 파일이 존재하지 않는 경우
EOF

BAR

declare -A log_files=(
    ["UTMP"]="/var/adm/utmp"
    ["WTMP"]="/var/adm/wtmp"
    ["BTMP"]="/var/adm/btmp"
    ["SULOG"]="/var/adm/sulog"
    ["XFERLOG"]="/var/adm/xferlog"
)

found_vulnerability=0

for log_name in "${!log_files[@]}"; do
    log_path="${log_files[$log_name]}"
    if [ -f "$log_path" ]; then
        result="존재함"
        status="양호"
    else
        result="존재하지 않음"
        status="취약"
        found_vulnerability=1
    fi
    diagnosisResult="$log_name 로그 파일: $result"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "$diagnosisResult" >> $TMP1
done

if [ $found_vulnerability -eq 0 ]; then
    echo "OK: 모든 로그 파일이 존재합니다." >> $TMP1
else
    echo "WARN: 일부 로그 파일이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
