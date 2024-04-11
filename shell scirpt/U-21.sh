#!/bin/bash

# AIX 시스템에서 r 계열 서비스의 비활성화 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-21"
    ["위험도"]="상"
    ["진단 항목"]="r 계열 서비스 비활성화 (AIX)"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="불필요한 r 계열 서비스 비활성화"
)

r_commands=("rsh" "rlogin" "rexec" "shell" "login" "exec")
vulnerable_services=()

# /etc/xinetd.d 아래 서비스 검사
if [ -d "/etc/xinetd.d" ]; then
    for r_command in "${r_commands[@]}"; do
        service_path="/etc/xinetd.d/$r_command"
        if [ -f "$service_path" ] && grep -q "disable = no" "$service_path"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# /etc/inetd.conf 아래 서비스 검사
if [ -f "/etc/inetd.conf" ]; then
    for r_command in "${r_commands[@]}"; do
        if grep -q "$r_command" "/etc/inetd.conf"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# 서비스 상태 검사
for service in "${r_commands[@]}"; do
    if lssrc -s "$service" | grep -q "active"; then
        vulnerable_services+=("$service")
    fi
done

if [ ${#vulnerable_services[@]} -gt 0 ]; then
    results["진단 결과"]="취약"
    results["현황"]+=("불필요한 r 계열 서비스가 실행 중입니다: ${vulnerable_services[*]}")
else
    results["현황"]+=("모든 r 계열 서비스가 비활성화되어 있습니다.")
fi

# 결과를 JSON 형태로 출력
echo "{"
echo "    \"분류\": \"${results["분류"]}\","
echo "    \"코드\": \"${results["코드"]}\","
echo "    \"위험도\": \"${results["위험도"]}\","
echo "    \"진단 항목\": \"${results["진단 항목"]}\","
echo "    \"진단 결과\": \"${results["진단 결과"]}\","
echo "    \"현황\": ["
for ((i=0; i<${#results["현황"][@]}; i++)); do
    echo "        \"${results["현황"][$i]}\"$(if [[ $i -lt $((${#results["현황"][@]} - 1)) ]]; then echo ","; fi)"
done
echo "    ],"
echo "    \"대응방안\": \"${results["대응방안"]}\""
echo "}"
