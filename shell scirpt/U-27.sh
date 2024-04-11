#!/bin/bash

# AIX 시스템에서 불필요한 RPC 서비스의 비활성화 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-27"
    ["위험도"]="상"
    ["진단 항목"]="RPC 서비스 확인"
    ["진단 결과"]=""
    ["현황"]=()
    ["대응방안"]="불필요한 RPC 서비스 비활성화"
)

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
    results["진단 결과"]="양호"
    results["현황"]+=("모든 불필요한 RPC 서비스가 비활성화되어 있습니다.")
fi

# 결과를 JSON 형태로 출력
echo "{"
echo "    \"분류\": \"${results["분류"]}\","
echo "    \"코드\": \"${results["코드"]}\","
echo "    \"위험도\": \"${results["위험도"]}\","
echo "    \"진단 항목\": \"${results["진단 항목"]}\","
echo "    \"진단 결과\": \"${results["진단 결과"]}\","
echo "    \"현황\": ["
for i in "${!results["현황"][@]}"; do
    echo "        \"${results["현황"][$i]}\""$(if [ $i -lt $((${#results["현황"][@]} - 1)) ]; then echo ","; fi)
done
echo "    ],"
echo "    \"대응방안\": \"${results["대응방안"]}\""
echo "}"
