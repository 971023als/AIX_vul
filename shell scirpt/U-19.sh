#!/bin/bash

# AIX 시스템에서 Finger 서비스의 활성화 상태를 점검하는 스크립트

results=()
diagnostic_result="양호"
diagnostic_action="Finger 서비스가 비활성화 되어 있는 경우"

# /etc/inetd.conf 파일에서 Finger 서비스 정의 확인
if grep -q "finger" /etc/inetd.conf && ! grep -E "^#" /etc/inetd.conf | grep -q "finger"; then
    results+=("/etc/inetd.conf에 Finger 서비스 활성화")
    diagnostic_result="취약"
fi

# Finger 서비스가 SRC에 의해 실행 중인지 확인
if lssrc -s fingerd | grep -q "active"; then
    results+=("Finger 서비스가 SRC에 의해 활성화되어 있습니다.")
    diagnostic_result="취약"
fi

if [ ${#results[@]} -eq 0 ]; then
    results+=("Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다.")
fi

# 결과를 JSON 형태로 출력
echo "{"
echo "    \"분류\": \"서비스 관리\","
echo "    \"코드\": \"U-19\","
echo "    \"위험도\": \"상\","
echo "    \"진단 항목\": \"Finger 서비스 비활성화 (AIX)\","
echo "    \"진단 결과\": \"$diagnostic_result\","
echo "    \"현황\": ["
for ((i=0; i<${#results[@]}; i++)); do
    echo "        \"${results[$i]}\"$(if [[ $i -lt $((${#results[@]} - 1)) ]]; then echo ","; fi)"
done
echo "    ],"
echo "    \"대응방안\": \"$diagnostic_action\""
echo "}"
