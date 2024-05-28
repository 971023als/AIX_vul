#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-62"
riskLevel="중"
diagnosisItem="ftp 계정 shell 제한"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-62"
diagnosisItem="ftp 계정 shell 제한"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: ftp 계정에 /bin/false 쉘이 부여되어 있는 경우
[취약]: ftp 계정에 /bin/false 쉘이 부여되어 있지 않은 경우
EOF

BAR

# Initialize result and status
result=""
status=""

# Check ftp account in /etc/passwd
if grep -q "^ftp:" /etc/passwd; then
    ftp_shell=$(grep "^ftp:" /etc/passwd | cut -d':' -f7)
    if [ "$ftp_shell" = "/bin/false" ]; then
        result="양호"
        status="ftp 계정에 /bin/false 쉘이 부여되어 있습니다."
    else
        result="취약"
        status="ftp 계정에 /bin/false 쉘이 부여되어 있지 않습니다."
    fi
else
    result="양호"
    status="ftp 계정이 시스템에 존재하지 않습니다."
fi

# Write final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
