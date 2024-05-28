#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-38"
riskLevel="상"
diagnosisItem="웹서비스 불필요한 파일 제거"
service="웹 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-38"
diagnosisItem="웹서비스 불필요한 파일 제거 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있는 경우
[취약]: Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
serverroot_directories=()
vulnerable=0

for conf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$conf_file" -type f 2>/dev/null))
    for file_path in "${find_webconf_files[@]}"; do
        if [ -f "$file_path" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^ServerRoot ]] && [[ ! "$line" =~ ^# ]]; then
                    serverroot=$(echo $line | awk '{print $2}' | tr -d '"')
                    if [[ ! " ${serverroot_directories[@]} " =~ " ${serverroot} " ]]; then
                        serverroot_directories+=("$serverroot")
                    fi
                fi
            done < "$file_path"
        fi
    done
done

for directory in "${serverroot_directories[@]}"; do
    manual_path="$directory/manual"
    if [ -d "$manual_path" ]; then
        vulnerable=1
        diagnosisResult="Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다: $manual_path"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
done

if [ ${#serverroot_directories[@]} -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ $vulnerable -eq 0 ]; then
    diagnosisResult="Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
