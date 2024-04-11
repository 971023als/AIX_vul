#!/bin/bash

# 변수 설정
file_path="/etc/security/user"
status="양호"
conditions=()

# 파일 존재 여부 확인
if [ -f "$file_path" ]; then
    # loginretries 설정 검사
    while IFS= read -r line; do
        if [[ ! $line =~ ^# && $line =~ loginretries ]]; then
            loginretries_value=$(echo $line | awk -F"=" '{print $2}' | tr -d ' ')
            if [ "$loginretries_value" -le 10 ]; then
                conditions+=("계정 잠금 임계값이 적절히 설정되었습니다.")
            else
                conditions+=("$file_path에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")
                status="취약"
            fi
            break
        fi
    done < "$file_path"
else
    conditions+=("적절한 계정 잠금 임계값 설정이 없습니다.")
    status="취약"
fi

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"계정 관리\","
echo "  \"코드\": \"U-03\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"계정 잠금 임계값 설정\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": ["
for condition in "${conditions[@]}"; do
    echo "    \"$condition\""
    if [[ ! ${condition} == ${conditions[-1]} ]]; then
        echo ","
    fi
done
echo "  ],"
echo "  \"대응방안\": \"계정 잠금 임계값을 10회 이하로 설정\""
echo "}"
