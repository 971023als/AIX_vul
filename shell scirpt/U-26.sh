#!/bin/bash

# AIX 시스템에서 automountd 서비스의 비활성화 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-26"
    ["위험도"]="상"
    ["진단 항목"]="automountd 제거 (AIX)"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="automountd 서비스 비활성화"
)

# automountd 서비스 상태 확인
src_output=$(lssrc -s automountd)
src_status=$?

if echo "$src_output" | grep -iq "active"; then
    results["진단 결과"]="취약"
    results["현황"]+=("automountd 서비스가 실행 중입니다.")
elif echo "$src_output" | grep -iq "inoperative"; then
    results["진단 결과"]="양호"
    results["현황"]+=("automountd 서비스가 비활성화되어 있습니다.")
else
    results["진단 결과"]="오류"
    results["현황"]+=("automountd 서비스 상태를 확인할 수 없습니다.")
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
