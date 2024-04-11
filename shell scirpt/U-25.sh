#!/bin/bash

# AIX 시스템에서 NFS 접근 통제 설정을 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-25"
    ["위험도"]="상"
    ["진단 항목"]="NFS 접근 통제"
    ["진단 결과"]=null
    ["현황"]=()
    ["대응방안"]="불필요한 NFS 서비스를 사용하지 않거나, 사용 시 everyone 공유 제한"
)

cmd="ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'"
process_output=$(eval "$cmd")
process_status=$?

if [ $process_status -eq 0 ]; then
    if [ -f "/etc/exports" ]; then
        # /etc/exports 파일 분석
        while IFS= read -r line; do
            if [[ ! $line =~ ^# && $line =~ \* ]]; then
                results["진단 결과"]="취약"
                results["현황"]+=("/etc/exports 파일에 '*' 설정이 있습니다.")
                break
            fi
        done < "/etc/exports"
    else
        results["진단 결과"]="취약"
        results["현황"]+=("NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다.")
    fi
elif [ $process_status -eq 1 ]; then
    results["진단 결과"]="양호"
    results["현황"]+=("NFS 서비스가 실행 중이지 않습니다.")
else
    results["진단 결과"]="오류"
    results["현황"]+=("NFS 서비스 확인 중 오류 발생")
fi

# 진단 결과가 명시적으로 설정되지 않은 경우 기본값을 "양호"로 설정
if [ "${results["진단 결과"]}" == null ]; then
    results["진단 결과"]="양호"
    results["현황"]+=("NFS 접근 통제 설정에 문제가 없습니다.")
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
