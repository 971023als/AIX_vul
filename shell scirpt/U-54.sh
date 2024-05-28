#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-54"
riskLevel="하"
diagnosisItem="Session Timeout 설정"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-54"
diagnosisItem="Session Timeout 설정 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 세션 타임아웃이 600초(10분) 이하로 설정된 경우
[취약]: 세션 타임아웃이 600초(10분) 이하로 설정되지 않은 경우
EOF

BAR

# Files to check for session timeout settings
check_files=("/etc/profile" "/etc/csh.login" "/etc/csh.cshrc" "/home/*/.profile")

file_exists_count=0
no_tmout_setting_file=0

for file_path in ${check_files[@]}; do
    for expanded_file_path in $(eval echo $file_path); do
        if [ -f "$expanded_file_path" ]; then
            file_exists_count=$((file_exists_count+1))
            if grep -q "TMOUT" "$expanded_file_path" || grep -q "autologout" "$expanded_file_path"; then
                while IFS= read -r line; do
                    if echo "$line" | grep -q "TMOUT"; then
                        setting_value=$(echo "$line" | cut -d'=' -f2)
                        if [ "$setting_value" -gt 600 ]; then
                            diagnosisResult="파일에 세션 타임아웃이 600초 이하로 설정되지 않았습니다: $expanded_file_path"
                            status="취약"
                            echo "WARN: $diagnosisResult" >> $TMP1
                            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                            break
                        fi
                    elif echo "$line" | grep -q "autologout"; then
                        setting_value=$(echo "$line" | cut -d'=' -f2)
                        if [ "$setting_value" -gt 10 ]; then
                            diagnosisResult="파일에 세션 타임아웃이 10분 이하로 설정되지 않았습니다: $expanded_file_path"
                            status="취약"
                            echo "WARN: $diagnosisResult" >> $TMP1
                            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                            break
                        fi
                    fi
                done < "$expanded_file_path"
            else
                no_tmout_setting_file=$((no_tmout_setting_file+1))
            fi
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="세션 타임아웃을 설정하는 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ $file_exists_count -eq $no_tmout_setting_file ]; then
    diagnosisResult="세션 타임아웃을 설정한 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="세션 타임아웃이 적절하게 설정되었습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
