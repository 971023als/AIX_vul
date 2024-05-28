#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-11"
riskLevel="상"
diagnosisItem="syslog 설정 파일 소유자 및 권한"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: syslog 설정 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우
[취약]: syslog 설정 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 640을 초과하는 경우
EOF

# Initialize variables to count files and compliance
file_exists_count=0
compliant_files_count=0
results_info=()

# AIX typically uses /etc/syslog.conf for syslog configuration
syslog_conf_files="/etc/syslog.conf"

check_file_ownership_and_permissions() {
    file_path=$1
    if [ -f "$file_path" ]; then
        file_exists_count=$((file_exists_count+1))
        owner=$(ls -l $file_path | awk '{print $3}')
        perms=$(ls -l $file_path | awk '{print $1}')
        octal_perms=$(stat -c "%a" $file_path)

        # Check if owner is root, bin, or sys and permissions are 640 or less
        if [ "$owner" = "root" ] || [ "$owner" = "bin" ] || [ "$owner" = "sys" ]; then
            if [ "$octal_perms" -le 640 ]; then
                compliant_files_count=$((compliant_files_count+1))
                results_info+=("$file_path 파일의 소유자가 $owner이고, 권한이 ${octal_perms}입니다.")
            else
                results_info+=("$file_path 파일의 소유자가 $owner이지만, 권한이 ${octal_perms}로 설정되어 있어 취약합니다.")
            fi
        else
            results_info+=("$file_path 파일의 소유자가 root, bin, sys 중 하나가 아닙니다.")
        fi
    else
        results_info+=("$file_path 파일이 없습니다.")
    fi
}

# 파일 검사
for file_path in $syslog_conf_files; do
    check_file_ownership_and_permissions "$file_path"
done

# 진단 결과 업데이트
if [ "$file_exists_count" -gt 0 ]; then
    if [ "$compliant_files_count" -eq "$file_exists_count" ]; then
        status="양호"
        diagnosisResult="모든 syslog 설정 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하입니다."
    else
        status="취약"
        diagnosisResult="일부 syslog 설정 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 640을 초과합니다."
    fi
else
    status="파일 없음"
    diagnosisResult="syslog 설정 파일이 존재하지 않습니다."
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
