#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-07"
riskLevel="상"
diagnosisItem="/etc/passwd 및 /etc/security/passwd 파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 파일의 소유자가 root이고, 권한이 644 이하인 경우
[취약]: 파일의 소유자가 root가 아니거나, 권한이 644를 초과하는 경우
EOF

check_file_permissions() {
    local file_path=$1
    if [ -e "$file_path" ]; then
        local file_info=$(ls -l "$file_path")
        local owner=$(echo "$file_info" | awk '{print $3}')
        local permissions=$(echo "$file_info" | awk '{print $1}')
        
        if [ "$owner" == "root" ]; then
            # Convert permissions from symbolic to numeric mode
            local mode=$(stat -c "%a" "$file_path")
            if [ "$mode" -le 644 ]; then
                echo "양호, ${file_path} 파일의 소유자가 root이고, 권한이 ${mode}입니다."
            else
                echo "취약, ${file_path} 파일의 권한이 ${mode}로 설정되어 있어 취약합니다."
            fi
        else
            echo "취약, ${file_path} 파일의 소유자가 root가 아닙니다."
        fi
    else
        echo "N/A, ${file_path} 파일이 없습니다."
    fi
}

# 검사 실행
passwd_result=$(check_file_permissions "/etc/passwd")
security_passwd_result=$(check_file_permissions "/etc/security/passwd")

# Determine overall status
overall_status="양호"
if [[ "$passwd_result" == 취약* || "$security_passwd_result" == 취약* ]]; then
    overall_status="취약"
fi

# Write results to CSV
IFS=',' read -r passwd_status passwd_message <<< "$passwd_result"
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$passwd_message,$passwd_status" >> $OUTPUT_CSV

IFS=',' read -r security_passwd_status security_passwd_message <<< "$security_passwd_result"
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$security_passwd_message,$security_passwd_status" >> $OUTPUT_CSV

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
