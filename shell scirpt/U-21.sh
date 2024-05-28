#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-21"
riskLevel="상"
diagnosisItem="r 계열 서비스 비활성화 (AIX)"
service="Service Management"
diagnosisResult="양호"
status="모든 r 계열 서비스가 비활성화되어 있습니다."

r_commands=("rsh" "rlogin" "rexec" "shell" "login" "exec")
vulnerable_services=()

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 r 계열 서비스가 비활성화되어 있습니다.
[취약]: 불필요한 r 계열 서비스가 실행 중입니다.
EOF

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
    diagnosisResult="취약"
    status="불필요한 r 계열 서비스가 실행 중입니다: ${vulnerable_services[*]}"
    echo "WARN: $status" >> $TMP1
else
    diagnosisResult="양호"
    status="모든 r 계열 서비스가 비활성화되어 있습니다."
    echo "OK: $status" >> $TMP1
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
