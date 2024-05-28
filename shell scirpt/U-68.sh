#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-68"
riskLevel="하"
diagnosisItem="로그온 시 경고 메시지 제공"
service="Various Services"
diagnosisResult=""
status=""
recommendation="서버 및 주요 서비스(Telnet, FTP, SMTP, DNS)에 로그온 메시지 설정"

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그온 메시지가 적절히 설정되어 있는 경우
[취약]: 로그온 메시지가 설정되어 있지 않은 경우
EOF

BAR

# Initialize result and status
result=""
status=()

# Check /etc/motd
if [ -s "/etc/motd" ]; then
    message_found=true
else
    message_found=false
fi

# Check /etc/issue.net
if [ -s "/etc/issue.net" ]; then
    message_found=true
fi

# Check FTP service config files
ftp_configs=("/etc/vsftpd.conf" "/etc/proftpd/proftpd.conf" "/etc/pure-ftpd/conf/WelcomeMsg")
for config in "${ftp_configs[@]}"; do
    if [ -s "$config" ] && grep -Eq "(ftpd_banner|ServerIdent|WelcomeMsg)" "$config"; then
        message_found=true
    fi
done

# Check /etc/sendmail.cf for SMTP
if [ -s "/etc/sendmail.cf" ] && grep -q "GreetingMessage" "/etc/sendmail.cf"; then
    message_found=true
fi

# Determine diagnosis result
if [ "$message_found" = true ]; then
    result="양호"
    status+=("로그온 메시지가 적절히 설정되어 있습니다.")
else
    result="취약"
    status+=("일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다.")
fi

# Add DNS service config file check suggestion
status+=("DNS 배너의 경우 '/etc/named.conf' 또는 '/var/named' 파일을 수동으로 점검하세요.")

# Write final result to CSV
status_str=$(printf "%s\n" "${status[@]}" | tr '\n' ' ' | sed 's/,$//')
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status_str" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
