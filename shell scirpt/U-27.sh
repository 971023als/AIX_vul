#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-27"
riskLevel="상"
diagnosisItem="RPC 서비스 확인"
service="Service Management"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 불필요한 RPC 서비스가 비활성화되어 있습니다.
[취약]: 불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")
inetd_conf="/etc/inetd.conf"
service_found=false

# /etc/inetd.conf 파일 내 서비스 검사
if [ -f "$inetd_conf" ]; then
    for service in "${rpc_services[@]}"; do
        if grep -q "^$service" "$inetd_conf"; then
            results["진단 결과"]="취약"
            results["현황"]+=("불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다: $service")
            service_found=true
        fi
    done
fi

if ! $service_found; then
    results["현황"]+=("모든 불필요한 RPC 서비스가 비활성화되어 있습니다.")
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
