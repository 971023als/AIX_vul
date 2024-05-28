#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-49"
riskLevel="하"
diagnosisItem="불필요한 계정 제거"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-49"
diagnosisItem="불필요한 계정 제거 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 계정이 존재하지 않는 경우
[취약]: 불필요한 계정이 존재하는 경우
EOF

BAR

# 로그인이 가능한 쉘 목록
login_shells=("/bin/bash" "/bin/sh" "/bin/ksh" "/bin/csh")
# 검사할 불필요한 계정 목록
unnecessary_accounts=("user" "test" "guest" "info" "adm" "mysql" "user1")

# 불필요한 계정 찾기
found_accounts=()
for account in "${unnecessary_accounts[@]}"; do
    if lsuser "$account" > /dev/null 2>&1; then
        shell=$(lsuser -a shell "$account" | awk '{print $2}' | cut -d= -f2)
        for login_shell in "${login_shells[@]}"; do
            if [[ "$shell" == "$login_shell" ]]; then
                found_accounts+=("$account")
                break
            fi
        done
    fi
done

if [ ${#found_accounts[@]} -gt 0 ]; then
    diagnosisResult="불필요한 계정이 존재합니다: ${found_accounts[*]}"
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="불필요한 계정이 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
