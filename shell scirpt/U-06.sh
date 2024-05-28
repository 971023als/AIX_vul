#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-06"
riskLevel="상"
diagnosisItem="파일 및 디렉터리 소유자 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 소유자가 존재하지 않는 파일 및 디렉터리가 없는 경우
[취약]: 소유자가 존재하지 않는 파일 및 디렉터리가 있는 경우
EOF

start_path="/tmp"
no_owner_files=()

# 소유자가 없는 파일 및 디렉터리 찾기
while IFS= read -r -d '' file; do
    uid=$(stat -c "%u" "$file")
    gid=$(stat -c "%g" "$file")
    if ! getent passwd "$uid" &>/dev/null || ! getent group "$gid" &>/dev/null; then
        no_owner_files+=("$file")
    fi
done < <(find "$start_path" -print0)

# 결과 설정
if [ ${#no_owner_files[@]} -gt 0 ]; then
    status="취약"
    diagnosisResult="소유자가 존재하지 않는 파일 및 디렉터리가 발견되었습니다."
    for file in "${no_owner_files[@]}"; do
        echo "WARN: $file" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$file,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="소유자가 존재하지 않는 파일 및 디렉터리가 없습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
