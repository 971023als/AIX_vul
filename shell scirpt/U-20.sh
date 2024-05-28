#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 설정"
code="U-20"
riskLevel="상"
diagnosisItem="Anonymous FTP 비활성화 (AIX)"
service="Service Management"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우
[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우
EOF

# FTP 계정 존재 여부 확인
if getent passwd ftp > /dev/null 2>&1; then
    diagnosisResult="취약"
    status="FTP 계정이 /etc/passwd 파일에 있습니다."
    echo "WARN: $status" >> $TMP1
else
    diagnosisResult="양호"
    status="FTP 계정이 /etc/passwd 파일에 없습니다."
    echo "OK: $status" >> $TMP1
fi

# FTP 서비스 활성화 여부 확인
ftp_service_status=$(lssrc -s ftpd)
if echo "$ftp_service_status" | grep -q "active"; then
    diagnosisResult="취약"
    status+="; FTP 서비스가 활성화되어 있습니다."
    echo "WARN: FTP 서비스가 활성화되어 있습니다." >> $TMP1
fi

if [ "$diagnosisResult" == "양호" ]; then
    status="Anonymous FTP (익명 ftp) 접속을 차단한 경우"
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
