#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-32"
riskLevel="상"
diagnosisItem="일반사용자의 Sendmail 실행 방지"
service="SMTP 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-32"
diagnosisItem="일반 사용자의 Sendmail 실행 방지 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정된 경우
[취약]: sendmail.cf 파일에 restrictqrun 옵션이 설정되어 있지 않은 경우
EOF

BAR

sendmail_cf_files=$(find / -name 'sendmail.cf' -type f 2>/dev/null)
file_exists_count=0
restriction_set=0

for file_path in $sendmail_cf_files; do
    ((file_exists_count++))
    if grep -vE '^#|^\s#' "$file_path" | grep -q 'restrictqrun'; then
        restriction_set=1
        diagnosisResult="$file_path 파일에 restrictqrun 옵션이 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        break
    fi
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="sendmail.cf 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ $restriction_set -eq 0 ]; then
    diagnosisResult="sendmail.cf 파일 중 restrictqrun 옵션이 설정되어 있지 않은 파일이 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
