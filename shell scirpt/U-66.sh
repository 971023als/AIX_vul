#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-66"
riskLevel="중"
diagnosisItem="SNMP 서비스 구동 점검"
service="SNMP"
diagnosisResult=""
status=""
recommendation="SNMP 서비스 사용을 필요로 하지 않는 경우, 서비스를 비활성화"

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SNMP 서비스를 사용하지 않는 경우
[취약]: SNMP 서비스를 사용하는 경우
EOF

BAR

# SNMP 서비스 실행 여부 확인
if ps -ef | grep -i "snmp" | grep -v "grep" > /dev/null; then
    diagnosisResult="SNMP 서비스를 사용하고 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="SNMP 서비스를 사용하지 않고 있습니다."
    status="양호"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

# Write final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo
cat $OUTPUT_CSV
