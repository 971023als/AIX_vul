#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-61"
riskLevel="하"
diagnosisItem="FTP 서비스 확인"
service="FTP Service"
diagnosisResult=""
status=""

BAR

CODE="U-61"
diagnosisItem="FTP 서비스 확인"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: FTP 서비스가 비활성화된 경우
[취약]: FTP 서비스가 활성화된 경우
EOF

BAR

# Initialize variables
result=""
recommendation="FTP 서비스를 비활성화 하십시오."
status=()

# Check FTP ports in /etc/services
ftp_ports=$(grep "^ftp\s" /etc/services | awk '{print $2}' | cut -d'/' -f1)
if [[ ! -z "$ftp_ports" ]]; then
    status+=("FTP 포트가 /etc/services에 설정됨: $ftp_ports")
    ftp_found=true
else
    status+=("/etc/services 파일에서 FTP 포트를 찾을 수 없습니다.")
    ftp_found=false
fi

# Check if FTP service is running
if ss -tuln | grep -qE ":(21|${ftp_ports}) "; then
    status+=("FTP 서비스가 실행 중입니다.")
    ftp_found=true
fi

# Check for vsftpd and proftpd configuration files
for ftp_conf in vsftpd.conf proftpd.conf; do
    if find / -name $ftp_conf 2>/dev/null | grep -q $ftp_conf; then
        status+=("$ftp_conf 파일이 시스템에 존재합니다.")
        ftp_found=true
    fi
done

# Check for general FTP service processes
if ps -ef | grep -Eiq 'ftpd|vsftpd|proftpd'; then
    status+=("FTP 관련 프로세스가 실행 중입니다.")
    ftp_found=true
fi

# Determine the overall security status
if [[ "$ftp_found" = true ]]; then
    diagnosisResult="취약"
else
    diagnosisResult="양호"
    status=("FTP 서비스 관련 항목이 시스템에 존재하지 않습니다.")
fi

# Write final result to CSV
for i in "${status[@]}"; do
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$i" >> $OUTPUT_CSV
done

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
