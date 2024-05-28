#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-40"
riskLevel="상"
diagnosisItem="웹서비스 파일 업로드 및 다운로드 제한"
service="웹 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-40"
diagnosisItem="웹서비스 파일 업로드 및 다운로드 제한 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있는 경우
[취약]: 웹서비스 설정 파일에서 파일 업로드 및 다운로드가 제한되지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0
found_vulnerability=0

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file_path in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        if ! grep -q "LimitRequestBody" "$file_path"; then
            found_vulnerability=1
            diagnosisResult="$file_path 파일에 파일 업로드 및 다운로드 제한 설정이 없습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            break 2
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ $found_vulnerability -eq 0 ]; then
    diagnosisResult="웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
