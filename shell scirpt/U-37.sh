#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-37"
riskLevel="상"
diagnosisItem="웹서비스 상위 디렉토리 접근 금지"
service="웹 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-37"
diagnosisItem="웹서비스 상위 디렉토리 접근 금지 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있는 경우
[취약]: 웹서비스 상위 디렉터리 접근에 대한 제한이 설정되어 있지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
found_vulnerability=0

for conf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$conf_file" -type f 2>/dev/null))
    for file_path in "${find_webconf_files[@]}"; do
        if [ -f "$file_path" ]; then
            if ! grep -q "AllowOverride None" "$file_path"; then
                found_vulnerability=1
                diagnosisResult="$file_path 파일에 상위 디렉터리 접근 제한 설정이 없습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                break 2
            fi
        fi
    done
done

if [ $found_vulnerability -eq 0 ]; then
    diagnosisResult="웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
