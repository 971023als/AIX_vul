#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-57"
riskLevel="중"
diagnosisItem="홈디렉토리 소유자 및 권한 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-57"
diagnosisItem="홈 디렉토리 소유자 및 권한 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 홈 디렉토리 소유자가 해당 계정이며 타 사용자 쓰기 권한이 없는 경우
[취약]: 홈 디렉토리 소유자가 해당 계정이 아니거나 타 사용자 쓰기 권한이 있는 경우
EOF

BAR

# Get all user entries and iterate
getent passwd | while IFS=: read -r username _ uid _ _ homedir _; do
    # Skip system users by UID
    if [ "$uid" -ge 1000 ]; then
        if [ -d "$homedir" ]; then
            dir_owner_uid=$(stat -c "%u" "$homedir")
            if [ "$dir_owner_uid" != "$uid" ]; then
                diagnosisResult="$homedir 홈 디렉토리의 소유자가 $username 이(가) 아닙니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
            if [ "$(stat -c "%A" "$homedir" | cut -c8)" == "w" ]; then
                diagnosisResult="$homedir 홈 디렉터리에 타 사용자(other) 쓰기 권한이 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
        else
            diagnosisResult="$homedir 홈 디렉터리가 존재하지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    fi
done

if [ ! -s $TMP1 ]; then
    diagnosisResult="모든 검사된 홈 디렉토리의 소유자 및 권한 설정이 적절합니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
