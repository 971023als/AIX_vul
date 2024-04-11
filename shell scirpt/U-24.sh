#!/bin/bash

# AIX 시스템에서 NFS 서비스의 비활성화 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-24"
    ["위험도"]="상"
    ["진단 항목"]="NFS 서비스 비활성화 (AIX)"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="불필요한 NFS 서비스 관련 데몬 비활성화"
)

# NFS 서비스 관련 데몬 확인
nfs_services_output=$(lssrc -g nfs)
nfs_services_status=$?

if echo "$nfs_services_output" | grep -q "active"; then
    results["진단 결과"]="취약"
    results["현황"]+=("NFS 서비스 관련 데몬이 SRC를 통해 실행 중입니다.")
elif [ $nfs_services_status -eq 1 ]; then
    results["진단 결과"]="양호"
    results["현황"]+=("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
else
    results["진단 결과"]="오류"
    results["현황"]+=("서비스 확인 중 오류 발생")
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
