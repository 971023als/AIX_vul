#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-28"
riskLevel="상"
diagnosisItem="NIS, NIS+ 점검 (AIX)"
service="Service Management"
diagnosisResult="양호"
status="NIS 서비스가 비활성화되어 있습니다."

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NIS 서비스가 비활성화되어 있습니다.
[취약]: NIS 서비스가 실행 중입니다.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

nis_services=("ypserv" "ypbind" "yppasswdd" "ypupdated" "ypxfrd")
active_services=()

for service in "${nis_services[@]}"; do
    cmd_output=$(lssrc -s "$service")
    if echo "$cmd_output" | grep -q "active"; then
        active_services+=("$service")
    fi
done

if [ ${#active_services[@]} -gt 0 ]; then
    results["진단 결과"]="취약"
    results["현황"]+=("NIS 서비스가 실행 중입니다: ${active_services[*]}")
else
    results["현황"]+=("NIS 서비스가 비활성화되어 있습니다.")
fi

# Combine status messages into a single string
status=$(IFS="; " ; echo "${results["현황"][*]}")

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,${results["진단 결과"]},$status" >> $OUTPUT_CSV

# Display the result
echo "category: $category"
echo "code: $code"
echo "riskLevel: $riskLevel"
echo "diagnosisItem: $diagnosisItem"
echo "service: $service"
echo "diagnosisResult: ${results["진단 결과"]}"
echo "status: $status"

cat $TMP1
echo
cat $OUTPUT_CSV
