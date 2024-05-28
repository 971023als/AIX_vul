#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-59"
riskLevel="하"
diagnosisItem="숨겨진 파일 및 디렉터리 검색 및 제거"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-59"
diagnosisItem="숨겨진 파일 및 디렉터리 검색 및 제거"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 숨겨진 파일이나 디렉터리가 없는 경우
[취약]: 숨겨진 파일이나 디렉터리가 발견된 경우
EOF

BAR

vulnerability_found=false
start_path="$HOME"
declare -a hidden_files
declare -a hidden_dirs

while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        hidden_files+=("$file")
    elif [[ -d "$file" ]]; then
        hidden_dirs+=("$file")
    fi
done < <(find "$start_path" -name ".*" -print0)

if [ ${#hidden_files[@]} -eq 0 ] && [ ${#hidden_dirs[@]} -eq 0 ]; then
    result="양호"
    status="숨겨진 파일이나 디렉터리가 없습니다."
    echo "OK: $status" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
else
    vulnerability_found=true
    result="취약"
    echo "WARN: 숨겨진 파일 및 디렉터리 발견" >> $TMP1
    for file in "${hidden_files[@]}"; do
        status="숨겨진 파일 발견: $file"
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    done
    for dir in "${hidden_dirs[@]}"; do
        status="숨겨진 디렉터리 발견: $dir"
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    done
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
