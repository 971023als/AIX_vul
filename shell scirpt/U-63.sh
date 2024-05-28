#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-63"
riskLevel="하"
diagnosisItem="ftpusers 파일 소유자 및 권한 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-63"
diagnosisItem="ftpusers 파일 소유자 및 권한 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: ftpusers 파일의 소유자가 root로 설정되고, 권한이 640 이하로 설정된 경우
[취약]: ftpusers 파일의 소유자가 root가 아니거나, 권한이 640보다 큰 경우
EOF

BAR

# Initialize result and status
result=""
declare -a status
file_checked_and_secure=false

# List of ftpusers files to check
ftpusers_files=(
    "/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers"
    "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers"
    "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list"
)

# Check each ftpusers file
for ftpusers_file in "${ftpusers_files[@]}"; do
    if [ -f "$ftpusers_file" ]; then
        file_checked_and_secure=true
        owner=$(ls -l "$ftpusers_file" | awk '{print $3}')
        permissions=$(ls -l "$ftpusers_file" | awk '{print $1}')
        permissions=${permissions:1}  # Remove the first character (file type)

        # Check if owner is not root or permissions are greater than 640
        if [ "$owner" != "root" ] || [[ ! "$permissions" =~ ^rw-r----- ]]; then
            result="취약"
            [ "$owner" != "root" ] && status+=("$ftpusers_file 파일의 소유자(owner)가 root가 아닙니다.")
            [[ ! "$permissions" =~ ^rw-r----- ]] && status+=("$ftpusers_file 파일의 권한이 640보다 큽니다.")
        fi
    fi
done

# Set result to 양호 if no issues were found
if [ ${#status[@]} -eq 0 ]; then
    if $file_checked_and_secure; then
        result="양호"
        status=("모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다.")
    else
        result="취약"
        status=("ftp 접근제어 파일이 없습니다.")
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
