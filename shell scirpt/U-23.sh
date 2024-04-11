#!/bin/bash

# 시스템에서 DoS 공격에 취약한 서비스의 비활성화 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-23"
    ["위험도"]="상"
    ["진단 항목"]="DoS 공격에 취약한 서비스 비활성화"
    ["진단 결과"]=null
    ["현황"]=()
    ["대응방안"]="사용하지 않는 DoS 공격에 취약한 서비스 비활성화"
)

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

if [ "${results["진단 결과"]}" == null ]; then
    results["진단 결과"]="양호"
    results["현황"]+=("모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.")
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
