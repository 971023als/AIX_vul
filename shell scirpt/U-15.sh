#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status,currentState" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-15"
riskLevel="상"
diagnosisItem="world writable 파일 점검"
diagnosisResult=""
status=""
currentState=""

start_dir="/tmp"
temp_file=$(mktemp)
> "$temp_file"

# Find world writable files
find "$start_dir" -type f ! -path "*/proc/*" \( ! -lname "*" \) -perm -2 -exec ls -l {} \; > "$temp_file"

if [ -s "$temp_file" ]; then
    # If there are world writable files
    diagnosisResult="취약"
    status="취약"
    currentState=$(cat "$temp_file" | tr '\n' ';')
    echo "WARN: World writable files found" >> $temp_file
else
    # If there are no world writable files
    diagnosisResult="양호"
    status="양호"
    currentState="world writable 설정이 되어있는 파일이 없습니다."
    echo "OK: No world writable files found" >> $temp_file
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status,$currentState" >> $OUTPUT_CSV

# Display the result
cat $temp_file
echo
cat $OUTPUT_CSV

# Clean up
rm -f "$temp_file"
