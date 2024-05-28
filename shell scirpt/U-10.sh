#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-10"
riskLevel="상"
diagnosisItem="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 이하인 경우
[취약]: /etc/(x)inetd.conf 파일의 소유자가 root가 아니거나, 권한이 600을 초과하는 경우
EOF

# 검사할 파일 및 디렉터리
files_to_check=("/etc/inetd.conf" "/etc/xinetd.conf")
directories_to_check=("/etc/xinetd.d")
check_passed=true
results_info=()

check_file_ownership_and_permissions() {
    file_path=$1
    if [ ! -f "$file_path" ]; then
        results_info+=("$file_path 파일이 없습니다.")
        check_passed=false
    else
        owner_uid=$(stat -c "%u" "$file_path")
        permissions=$(stat -c "%a" "$file_path")
        if [ "$owner_uid" != "0" ]; then
            results_info+=("$file_path 파일의 소유자가 root가 아닙니다.")
            check_passed=false
        elif [ "$permissions" -gt 600 ]; then
            results_info+=("$file_path 파일의 권한이 ${permissions}로 설정되어 있어 취약합니다.")
            check_passed=false
        else
            results_info+=("$file_path 파일의 소유자가 root이고, 권한이 ${permissions}입니다.")
        fi
    fi
}

check_directory_files_ownership_and_permissions() {
    directory_path=$1
    if [ ! -d "$directory_path" ]; then
        results_info+=("$directory_path 디렉터리가 없습니다.")
        check_passed=false
    else
        find "$directory_path" -type f | while read -r file_path; do
            check_file_ownership_and_permissions "$file_path"
        done
    fi
}

# 파일 검사
for file_path in "${files_to_check[@]}"; do
    check_file_ownership_and_permissions "$file_path"
done

# 디렉터리 검사
for directory_path in "${directories_to_check[@]}"; do
    check_directory_files_ownership_and_permissions "$directory_path"
done

# 진단 결과 업데이트
if $check_passed; then
    status="양호"
    diagnosisResult="모든 검사된 파일 및 디렉터리의 소유자가 root이고, 권한이 600 이하입니다."
else
    status="취약"
    diagnosisResult="일부 파일 및 디렉터리의 소유자가 root가 아니거나, 권한이 600을 초과합니다."
fi

# Write results to CSV
for info in "${results_info[@]}"; do
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$info,$status" >> $OUTPUT_CSV
done

# Log and output CSV
echo "현황:" >> $TMP1
for info in "${results_info[@]}"; do
    echo "$info" >> $TMP1
done
echo "진단 결과: $status" >> $TMP1

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
