#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-46"
riskLevel="중"
diagnosisItem="패스워드 최소 길이 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-46"
diagnosisItem="패스워드 최소 길이 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 패스워드 최소 길이가 8자 이상으로 설정된 경우
[취약]: 패스워드 최소 길이가 8자 미만으로 설정된 경우
EOF

BAR

files_to_check=(
    "/etc/security/user:MINWEEKS"
    "/etc/security/login.cfg:default:loginretries"
    "/etc/security/pwdpolicy:minlen"
)

file_exists_count=0
minlen_file_exists_count=0
no_settings_in_minlen_file=0

for item in "${files_to_check[@]}"; do
    IFS=: read -r file_path setting_key <<< "$item"
    if [ -f "$file_path" ]; then
        file_exists_count=$((file_exists_count + 1))
        if grep -iq "$setting_key" "$file_path"; then
            minlen_file_exists_count=$((minlen_file_exists_count + 1))
            min_length=$(grep -i "$setting_key" "$file_path" | grep -v '^#' | grep -o '[0-9]*' | head -1)
            if [ -n "$min_length" ] && [ "$min_length" -lt 8 ]; then
                diagnosisResult="$file_path 파일에 $setting_key 가 8 미만으로 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            elif [ -z "$min_length" ]; then
                no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
            fi
        else
            no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
        fi
    fi
done

if [ "$file_exists_count" -eq 0 ]; then
    diagnosisResult="패스워드 최소 길이를 설정하는 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ "$minlen_file_exists_count" -eq "$no_settings_in_minlen_file" ]; then
    diagnosisResult="패스워드 최소 길이를 설정한 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="패스워드 최소 길이가 8자 이상으로 설정된 파일이 존재합니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
