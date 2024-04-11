#!/bin/bash

# AIX 시스템에서 NIS, NIS+ 서비스의 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-28"
    ["위험도"]="상"
    ["진단 항목"]="NIS, NIS+ 점검 (AIX)"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
)

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
