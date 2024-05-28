#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-64"
riskLevel="중"
diagnosisItem="ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)"
service="FTP Service"
diagnosisResult=""
status=""

BAR

CODE="U-64"
diagnosisItem="ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: FTP 서비스 root 계정 접근이 제한되어 있는 경우
[취약]: FTP 서비스 root 계정 접근 제한 설정이 충분하지 않은 경우
EOF

BAR

# Initialize result and status
result=""
declare -a status
file_checked_and_secure=false

# List of ftpusers files and configuration files to check
ftpusers_files=(
    "/etc/ftpusers" "/etc/ftpd/ftpusers" "/etc/proftpd.conf"
    "/etc/vsftp/ftpusers" "/etc/vsftp/user_list" "/etc/vsftpd.ftpusers"
    "/etc/vsftpd.user_list"
)

# Check if FTP services are running
if ! pgrep -f -e ftpd > /dev/null && ! pgrep -f -e vsftpd > /dev/null && ! pgrep -f -e proftpd > /dev/null; then
    status+=("FTP 서비스가 비활성화 되어 있습니다.")
    result="양호"
else
    root_access_restricted=false

    for ftpusers_file in "${ftpusers_files[@]}"; do
        if [ -f "$ftpusers_file" ]; then
            # Check 'RootLogin on' setting for proftpd.conf
            if [[ "$ftpusers_file" == *proftpd.conf* ]] && grep -q "RootLogin on" "$ftpusers_file"; then
                result="취약"
                status+=("$ftpusers_file 파일에 'RootLogin on' 설정이 있습니다.")
                break
            # Check for 'root' entry in other ftpusers files
            elif grep -q "^root$" "$ftpusers_file"; then
                root_access_restricted=true
            fi
        fi
    done

    if $root_access_restricted; then
        result="양호"
        status+=("FTP 서비스 root 계정 접근이 제한되어 있습니다.")
    else
        result="취약"
        status+=("FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다.")
    fi
fi

# Write final result to CSV
diagnosisResult="$result"
for i in "${status[@]}"; do
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$i" >> $OUTPUT_CSV
done

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
