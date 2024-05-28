#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-56"
riskLevel="중"
diagnosisItem="UMASK 설정 관리"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-56"
diagnosisItem="UMASK 설정 관리 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: UMASK 값이 022 이상으로 설정된 경우
[취약]: UMASK 값이 022 미만으로 설정된 경우
EOF

BAR

# Define files to check
files_to_check=(
    "/etc/profile"
    "/etc/bash.bashrc"
    "/etc/csh.login"
    "/etc/csh.cshrc"
    /home/*/.profile
    /home/*/.bashrc
    /home/*/.cshrc
    /home/*/.login
)

checked_files=0
is_vulnerable=0

# Check umask values in each file
for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        checked_files=$((checked_files + 1))
        while IFS= read -r line; do
            if echo "$line" | grep -q "umask" && ! echo "$line" | grep -q "^#"; then
                umask_value=$(echo "$line" | awk '{print $2}')
                if [ "$umask_value" -lt 22 ]; then
                    is_vulnerable=1
                    diagnosisResult="$file_path 파일에서 UMASK 값이 $umask_value 으로 설정되어 있습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                fi
            fi
        done < "$file_path"
    fi
done

if [ "$checked_files" -eq 0 ]; then
    diagnosisResult="검사할 파일이 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ "$is_vulnerable" -eq 0 ]; then
    diagnosisResult="모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
