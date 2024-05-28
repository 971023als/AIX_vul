#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-31"
riskLevel="상"
diagnosisItem="스팸 메일 릴레이 제한"
service="SMTP 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-31"
diagnosisItem="스팸 메일 릴레이 제한 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: sendmail.cf 파일에 릴레이 제한이 적절히 설정된 경우
[취약]: sendmail.cf 파일에 릴레이 제한 설정이 없는 경우
EOF

BAR

sendmail_cf_path="/etc/mail/sendmail.cf"

if [ -f $sendmail_cf_path ]; then
    if ! grep -q "DS" $sendmail_cf_path; then
        diagnosisResult="sendmail.cf 파일에 릴레이 제한 설정이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="sendmail.cf 파일에 릴레이 제한이 적절히 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="sendmail.cf 파일을 찾을 수 없거나 접근할 수 없습니다."
    status="양호"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
