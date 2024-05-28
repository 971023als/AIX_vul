#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-36"
riskLevel="상"
diagnosisItem="웹서비스 웹 프로세스 권한 제한"
service="웹 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-36"
diagnosisItem="웹서비스 웹 프로세스 권한 제한 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Apache 데몬이 root 권한으로 구동되도록 설정되어 있지 않은 경우
[취약]: Apache 데몬이 root 권한으로 구동되도록 설정되어 있는 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
found_vulnerability=0

for conf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$conf_file" -type f 2>/dev/null))
    for file_path in "${find_webconf_files[@]}"; do
        if [ -f "$file_path" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^Group && ! "$line" =~ ^# ]]; then
                    group_setting=($line)
                    if [ "${#group_setting[@]}" -gt 1 ] && [ "${group_setting[1],,}" == "root" ]; then
                        diagnosisResult="$file_path 파일에서 Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다."
                        status="취약"
                        found_vulnerability=1
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                        break 2
                    fi
                fi
            done < "$file_path"
        fi
    done
    if [ $found_vulnerability -eq 1 ]; then
        break
    fi
done

if [ $found_vulnerability -eq 0 ]; then
    diagnosisResult="Apache 데몬이 root 권한으로 구동되도록 설정되어 있지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
