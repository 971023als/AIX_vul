#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-69"
riskLevel="중"
diagnosisItem="NFS 설정파일 접근권한"
service="NFS"
diagnosisResult=""
status=""
recommendation="NFS 설정파일의 소유자를 root으로 설정하고, 권한을 644 이하로 설정"

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하인 경우
[취약]: NFS 접근제어 설정파일의 소유자가 root가 아니거나, 권한이 644보다 큰 경우
EOF

BAR

exports_file='/etc/exports'

if [ -e "$exports_file" ]; then
    # Get the file's mode (permissions and ownership)
    mode=$(stat -c "%a" "$exports_file")
    owner_uid=$(stat -c "%u" "$exports_file")

    # Check if owner is root and file permissions are 644 or less
    if [ "$owner_uid" -eq 0 ] && [ "$mode" -le 644 ]; then
        diagnosisResult="NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다."
        status="양호"
        echo "INFO: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="NFS 접근제어 설정파일의 소유자가 root가 아니거나, 권한이 644보다 큽니다."
        status="취약"
        if [ "$owner_uid" -ne 0 ]; then
            diagnosisResult="/etc/exports 파일의 소유자(owner)가 root가 아닙니다."
            echo "WARN: $diagnosisResult" >> $TMP1
        fi
        if [ "$mode" -gt 644 ]; then
            diagnosisResult="/etc/exports 파일의 권한이 644보다 큽니다."
            echo "WARN: $diagnosisResult" >> $TMP1
        fi
    fi
else
    diagnosisResult="/etc/exports 파일이 없습니다."
    status="N/A"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

# Write final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo
cat $OUTPUT_CSV
