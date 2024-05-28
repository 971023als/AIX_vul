#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-52"
riskLevel="중"
diagnosisItem="동일한 UID 금지"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-52"
diagnosisItem="동일한 UID 금지 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 동일한 UID로 설정된 사용자 계정이 없는 경우
[취약]: 동일한 UID로 설정된 사용자 계정이 존재하는 경우
EOF

BAR

min_regular_user_uid=1000
declare -A uid_counts

if [ -f "/etc/passwd" ]; then
    # UID를 추출하고, 정규 사용자 UID(>=1000)에 대해 중복을 검사합니다.
    while IFS=: read -r _ _ uid _; do
        if [ "$uid" -ge "$min_regular_user_uid" ]; then
            uid_counts["$uid"]=$((uid_counts["$uid"]+1))
        fi
    done < /etc/passwd

    duplicate_uids=()
    for uid in "${!uid_counts[@]}"; do
        if [ "${uid_counts[$uid]}" -gt 1 ]; then
            duplicate_uids+=("UID $uid (${uid_counts[$uid]}x)")
        fi
    done

    if [ ${#duplicate_uids[@]} -gt 0 ]; then
        diagnosisResult="동일한 UID로 설정된 사용자 계정이 존재합니다: ${duplicate_uids[*]}"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="동일한 UID를 공유하는 사용자 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="/etc/passwd 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
