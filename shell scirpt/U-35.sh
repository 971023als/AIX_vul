#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-35"
riskLevel="상"
diagnosisItem="웹서비스 디렉토리 리스팅 제거"
service="웹 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-35"
diagnosisItem="웹서비스 디렉토리 리스팅 제거 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹서비스 디렉토리 리스팅이 적절히 제거된 경우
[취약]: 웹서비스 디렉토리 리스팅이 제거되지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
vulnerable=0
file_exists_count=0

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        if grep -qi "options indexes" "$file" && ! grep -qi "-indexes" "$file"; then
            if [ "$webconf_file" == "userdir.conf" ]; then
                if ! grep -qi "userdir disabled" "$file"; then
                    vulnerable=1
                    diagnosisResult="$file 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            else
                vulnerable=1
                diagnosisResult="$file 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ $vulnerable -eq 0 ]; then
    diagnosisResult="웹서비스 디렉토리 리스팅이 적절히 제거되었습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
