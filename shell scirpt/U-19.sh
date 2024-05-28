#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-19"
riskLevel="상"
diagnosisItem="Finger 서비스 비활성화 (AIX)"
service="Service Management"
diagnosisResult="양호"
status="Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다."

results=()
diagnostic_result="양호"
diagnostic_action="Finger 서비스가 비활성화 되어 있는 경우"

# /etc/inetd.conf 파일에서 Finger 서비스 정의 확인
if grep -q "finger" /etc/inetd.conf && ! grep -E "^#" /etc/inetd.conf | grep -q "finger"; then
    results+=("/etc/inetd.conf에 Finger 서비스 활성화")
    diagnostic_result="취약"
fi

# Finger 서비스가 SRC에 의해 실행 중인지 확인
if lssrc -s fingerd | grep -q "active"; then
    results+=("Finger 서비스가 SRC에 의해 활성화되어 있습니다.")
    diagnostic_result="취약"
fi

if [ ${#results[@]} -eq 0 ]; then
    results+=("Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다.")
fi

# Combine status messages into a single string
status=$(IFS="; " ; echo "${results[*]}")

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnostic_result,$status" >> $OUTPUT_CSV

# Display the result
echo "category: $category"
echo "code: $code"
echo "riskLevel: $riskLevel"
echo "diagnosisItem: $diagnosisItem"
echo "service: $service"
echo "diagnosisResult: $diagnostic_result"
echo "status: $status"

cat $OUTPUT_CSV
