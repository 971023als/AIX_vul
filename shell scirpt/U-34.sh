#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-34"
riskLevel="상"
diagnosisItem="DNS Zone Transfer 설정"
service="DNS 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-34"
diagnosisItem="DNS Zone Transfer 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: DNS Zone Transfer가 허가된 사용자에게만 허용된 경우
[취약]: DNS Zone Transfer가 모든 사용자에게 허용된 경우
EOF

BAR

named_conf_path="/etc/named.conf"  # Adjust as necessary for your AIX setup

# Check if DNS service is running
dns_service_status=$(lssrc -s named)
dns_service_running=$(echo "$dns_service_status" | grep -c "active")

if [ $dns_service_running -gt 0 ]; then
    if [ -f $named_conf_path ]; then
        if grep -q "allow-transfer { any; }" "$named_conf_path"; then
            diagnosisResult="$named_conf_path 파일에 'allow-transfer { any; }' 설정이 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
        else
            diagnosisResult="DNS Zone Transfer가 허가된 사용자에게만 허용되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
        fi
    else
        diagnosisResult="$named_conf_path 파일이 존재하지 않습니다. DNS 서비스 구성 확인 필요."
        status="오류"
        echo "ERROR: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="DNS 서비스가 실행 중이지 않습니다."
    status="양호"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
