#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-05"
riskLevel="상"
diagnosisItem="root홈, 패스 디렉터리 권한 및 패스 설정"
service="Directory Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정된 경우
[취약]: PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함된 경우
EOF

# 변수 설정
declare -a global_files=(
    "/etc/profile"
    "/etc/environment"
)
declare -a user_files=(
    ".profile"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)
conditions=()

# 글로벌 설정 파일 검사
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -E '\b\.\b|(^|:)\.(:|$)' "$file" > /dev/null; then
            conditions+=("$file 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")
        fi
    fi
done

# 사용자 홈 디렉터리 설정 파일 검사
while IFS=: read -r _ _ _ _ _ home _; do
    for file in "${user_files[@]}"; do
        file_path="$home/$file"
        if [ -f "$file_path" ]; then
            if grep -E '\b\.\b|(^|:)\.(:|$)' "$file_path" > /dev/null; then
                conditions+=("$file_path 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")
            fi
        fi
    done
done < /etc/passwd

# Determine status based on conditions
if [ ${#conditions[@]} -ne 0 ]; then
    status="취약"
    diagnosisResult="PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되어 있습니다."
    for condition in "${conditions[@]}"; do
        echo "WARN: $condition" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$condition,$status" >> $OUTPUT_CSV
    done
else
    status="양호"
    diagnosisResult="PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정되어 있습니다."
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
