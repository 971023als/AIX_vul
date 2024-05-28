#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-24"
riskLevel="상"
diagnosisItem="NFS 서비스 비활성화 (AIX)"
service="Service Management"
diagnosisResult="양호"
status="NFS 서비스 관련 데몬이 비활성화되어 있습니다."

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NFS 서비스 관련 데몬이 비활성화되어 있습니다.
[취약]: NFS 서비스 관련 데몬이 SRC를 통해 실행 중입니다.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

# NFS 서비스 관련 데몬 확인
nfs_services_output=$(lssrc -g nfs)
nfs_services_status=$?

if echo "$nfs_services_output" | grep -q "active"; then
    results["진단 결과"]="취약"
    results["현황"]+=("NFS 서비스 관련 데몬이 SRC를 통해 실행 중입니다.")
elif [ $nfs_services_status -eq 1 ]; then
    results["현황"]+=("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
else
    results["진단 결과"]="오류"
    results["현황"]+=("서비스 확인 중 오류 발생")
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
