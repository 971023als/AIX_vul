#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-60"
riskLevel="중"
diagnosisItem="ssh 원격접속 허용"
service="Remote Access"
diagnosisResult=""
status=""

BAR

CODE="U-60"
diagnosisItem="ssh 원격접속 허용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SSH 서비스가 활성화되어 있고, Telnet 및 FTP 서비스가 비활성화된 경우
[취약]: SSH 서비스가 비활성화되었거나, Telnet 및 FTP 서비스가 활성화된 경우
EOF

BAR

# Variables
ssh_status=""
telnet_status=""
ftp_status=""
result=""
recommendation="SSH 사용 권장, Telnet 및 FTP 사용하지 않도록 설정"

# SSH 서비스 상태 확인
if ps -e | grep -q sshd; then
    ssh_status="활성화"
else
    ssh_status="비활성화"
fi

# Telnet 서비스 상태 확인
if ps -e | grep -q telnetd; then
    telnet_status="활성화"
else
    telnet_status="비활성화"
fi

# FTP 서비스 상태 확인
if ps -e | grep -q ftpd; then
    ftp_status="활성화"
else
    ftp_status="비활성화"
fi

# 전체 보안 상태 결정
if [ "$ssh_status" == "활성화" ] && [ "$telnet_status" == "비활성화" ] && [ "$ftp_status" == "비활성화" ]; then
    result="양호"
    status="SSH 서비스가 활성화되어 있고, Telnet 및 FTP 서비스가 비활성화되어 있습니다."
    echo "OK: $status" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
else
    result="취약"
    if [ "$ssh_status" != "활성화" ]; then
        status="SSH 서비스가 비활성화되어 있습니다."
        echo "WARN: $status" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    fi
    if [ "$telnet_status" == "활성화" ]; then
        status="Telnet 서비스가 활성화되어 있습니다."
        echo "WARN: $status" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    fi
    if [ "$ftp_status" == "활성화" ]; then
        status="FTP 서비스가 활성화되어 있습니다."
        echo "WARN: $status" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    fi
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
