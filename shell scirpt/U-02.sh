#!/bin/bash

# 변수 설정
file_path="/etc/security/user"
min_length=8
minalpha=1
minother=1
status="양호"
conditions=()

# 파일 존재 여부 확인
if [ -f "$file_path" ]; then
    # 파일 읽기 및 조건 검사
    while IFS= read -r line; do
        if [[ ! $line =~ ^# && $line != "" ]]; then
            if [[ $line =~ minlen ]]; then
                value=$(echo $line | grep -o '[0-9]*')
                if [ $value -lt $min_length ]; then
                    conditions+=("$file_path에서 설정된 minlen이(가) 요구 사항보다 낮습니다.")
                    status="취약"
                fi
            elif [[ $line =~ minalpha ]]; then
                value=$(echo $line | grep -o '[0-9]*')
                if [ $value -lt $minalpha ]; then
                    conditions+=("$file_path에서 설정된 minalpha가 요구 사항보다 낮습니다.")
                    status="취약"
                fi
            elif [[ $line =~ minother ]]; then
                value=$(echo $line | grep -o '[0-9]*')
                if [ $value -lt $minother ]; then
                    conditions+=("$file_path에서 설정된 minother가 요구 사항보다 낮습니다.")
                    status="취약"
                fi
            fi
        fi
    done < "$file_path"
else
    conditions+=("패스워드 복잡성 설정 파일이 없습니다.")
    status="취약"
fi

# JSON 형태로 결과 출력 (간단한 버전)
echo "{"
echo "  \"분류\": \"계정 관리\","
echo "  \"코드\": \"U-02\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"패스워드 복잡성 설정\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": ["
for condition in "${conditions[@]}"; do
    echo "    \"$condition\","
done
echo "  ],"
echo "  \"대응방안\": \"패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능 설정\""
echo "}"
