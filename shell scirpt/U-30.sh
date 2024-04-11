#!/bin/bash

# 변수 선언 및 초기화
declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-30"
    ["위험도"]="상"
    ["진단 항목"]="Sendmail 버전 점검 (AIX)"
    ["진단 결과"]=()
    ["현황"]=()
    ["대응방안"]="Sendmail 버전을 최신 버전으로 유지"
)
latest_version="8.17.1" # 최신 Sendmail 버전 예시

# AIX에서 Sendmail 버전 확인
output=$(lslpp -L | grep -i 'sendmail')
sendmail_version=""

if [[ $output ]]; then
    if [[ $output =~ sendmail[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        sendmail_version="${BASH_REMATCH[1]}"
    fi
fi

# 버전 비교 및 결과 설정
if [[ $sendmail_version ]]; then
    if [[ $sendmail_version == $latest_version* ]]; then
        results["진단 결과"]="양호"
        results["현황"]+=("Sendmail 버전이 최신 버전(${latest_version})입니다.")
    else
        results["진단 결과"]="취약"
        results["현황"]+=("Sendmail 버전이 최신 버전(${latest_version})이 아닙니다. 현재 버전: ${sendmail_version}")
    fi
else
    results["진단 결과"]="양호"
    results["현황"]+=("Sendmail이 설치되어 있지 않습니다.")
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
