#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-17"
riskLevel="상"
diagnosisItem="$HOME/.rhosts, hosts.equiv 사용 금지"
service="System Management"
diagnosisResult="양호"
status="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 $HOME/.rhosts 파일 문제 없음"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/hosts.equiv 및 $HOME/.rhosts 파일에 문제가 없는 경우
[취약]: /etc/hosts.equiv 및 $HOME/.rhosts 파일에 문제가 있는 경우
EOF

function check_permission_and_owner() {
    local path=$1
    local expected_owner=$2

    if [ ! -f "$path" ]; then
        return
    fi

    local owner=$(stat -c "%U" "$path")
    local permissions=$(stat -c "%a" "$path")
    local content=$(cat "$path")

    if [ "$owner" != "$expected_owner" ]; then
        diagnosisResult="취약"
        status="$path: 소유자가 $expected_owner가 아님"
        echo "WARN: $status" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    elif [ "$permissions" -gt "600" ]; then
        diagnosisResult="취약"
        status="$path: 권한이 600보다 큼"
        echo "WARN: $status" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    elif [[ "$content" == *"+"* ]]; then
        diagnosisResult="취약"
        status="$path: 파일 내에 '+' 문자가 있음"
        echo "WARN: $status" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
}

# Check /etc/hosts.equiv file
check_permission_and_owner "/etc/hosts.equiv" "root"

# Check .rhosts files for each user
while IFS=: read -r username dir _; do
    if [ -d "$dir" ]; then
        check_permission_and_owner "$dir/.rhosts" "$username"
    fi
done < /etc/passwd

# If no issues found, ensure the diagnosisResult is "양호"
if grep -q "WARN" "$TMP1"; then
    diagnosisResult="취약"
else
    diagnosisResult="양호"
    status="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 $HOME/.rhosts 파일 문제 없음"
    echo "OK: $status" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1
echo
cat $OUTPUT_CSV
