#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-23"
riskLevel="상"
diagnosisItem="DoS 공격에 취약한 서비스 비활성화"
service="Service Management"
diagnosisResult="양호"
status="모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다."

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.
[취약]: DoS 공격에 취약한 서비스가 실행 중입니다.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

vulnerable_services=("echo" "discard" "daytime" "chargen")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# /etc/xinetd.d 아래 서비스 검사
if [ -d "$xinetd_dir" ]; then
    for service in "${vulnerable_services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -Eiq '^\s*disable\s*=\s*yes' "$service_path"; then
                results["진단 결과"]="취약"
                results["현황"]+=("$service 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.")
            fi
        fi
    done
fi

# /etc/inetd.conf 파일 내 서비스 검사
if [ -f "$inetd_conf" ]; then
    for service in "${vulnerable_services[@]}"; do
        if grep -Eiq "^\s*$service\s" "$inetd_conf"; then
            results["진단 결과"]="취약"
            results["현황"]+=("$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
        fi
    done
fi

if [ "${results["진단 결과"]}" == "양호" ]; then
    results["현황"]+=("모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.")
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
