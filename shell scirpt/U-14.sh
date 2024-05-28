#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-14"
riskLevel="상"
diagnosisItem="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CCSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 홈 디렉터리 환경변수 파일 소유자가 해당 계정으로 지정되어 있고, 쓰기 권한이 그룹 또는 다른 사용자에게 부여되지 않은 경우
[취약]: 홈 디렉터리 환경변수 파일 소유자가 해당 계정으로 지정되어 있지 않거나, 쓰기 권한이 그룹 또는 다른 사용자에게 부여된 경우
EOF

start_files=(.profile .cshrc .login .kshrc .bash_profile .bashrc .bash_login)
vulnerable_files=()

# 모든 사용자의 홈 디렉토리 검색
while IFS=: read -r user _ _ _ _ home _; do
    if [[ -d "$home" ]]; then
        for start_file in "${start_files[@]}"; do
            file_path="$home/$start_file"
            if [[ -f "$file_path" ]]; then
                # 파일 소유자와 권한 확인
                if [[ $(stat -c "%U" "$file_path") != "$user" ]] || [[ $(stat -c "%A" "$file_path") =~ .*w.*g ]] || [[ $(stat -c "%A" "$file_path") =~ .*w.*o ]]; then
                    vulnerable_files+=("$file_path")
                fi
            fi
        done
    fi
done </etc/passwd

if [[ ${#vulnerable_files[@]} -eq 0 ]]; then
    diagnosisResult="모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다."
    status="양호"
else
    diagnosisResult="홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있지 않습니다."
    status="취약"
    for file in "${vulnerable_files[@]}"; do
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$file,$status" >> $OUTPUT_CSV
    done
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Log and output CSV
echo "현황:" >> $TMP1
for file in "${vulnerable_files[@]}"; do
    echo "$file" >> $TMP1
done
echo "진단 결과: $status" >> $TMP1

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
