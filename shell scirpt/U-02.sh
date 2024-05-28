#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-02"
riskLevel="상"
diagnosisItem="패스워드 복잡성 설정"
service="Password Policy"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능이 설정된 경우
[취약]: 패스워드 복잡성 설정이 요구 사항에 맞지 않는 경우
EOF

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

if [ "$status" == "취약" ]; then
    diagnosisResult="패스워드 복잡성 설정이 요구 사항에 맞지 않습니다."
    for condition in "${conditions[@]}"; do
        echo "WARN: $condition" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$condition,$status" >> $OUTPUT_CSV
    done
else
    diagnosisResult="패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능이 설정되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
