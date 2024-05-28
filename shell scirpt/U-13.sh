#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-13"
riskLevel="상"
diagnosisItem="SUID, SGID 설정 파일 점검"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CCSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우
[취약]: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있는 경우
EOF

# List of executables to check
executables=(
    "/sbin/dump" "/sbin/restore" "/sbin/unix_chkpwd"
    "/usr/bin/at" "/usr/bin/lpq" "/usr/bin/lpq-lpd"
    "/usr/bin/lpr" "/usr/bin/lpr-lpd" "/usr/bin/lprm"
    "/usr/bin/lprm-lpd" "/usr/bin/newgrp" "/usr/sbin/lpc"
    "/usr/sbin/lpc-lpd" "/usr/sbin/traceroute"
)
vulnerable_files=()

for executable in "${executables[@]}"; do
    if [[ -f "$executable" ]]; then
        mode=$(stat -c "%a" "$executable")
        if [[ $((mode & 4000)) -ne 0 ]] || [[ $((mode & 2000)) -ne 0 ]]; then
            vulnerable_files+=("$executable")
        fi
    fi
done

if [[ ${#vulnerable_files[@]} -eq 0 ]]; then
    status="양호"
    diagnosisResult="SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 없습니다."
else
    status="취약"
    diagnosisResult="SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 있습니다."
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
