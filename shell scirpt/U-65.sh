#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-65"
riskLevel="중"
diagnosisItem="at 서비스 권한 설정"
service="at Service"
diagnosisResult=""
status=""
recommendation="일반 사용자의 at 명령어 사용 금지 및 관련 파일 권한 640 이하 설정"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다.
[취약]: at 관련 파일의 권한이 적절하지 않은 경우
EOF

BAR

# Initialize result and status
result=""
declare -a status
permission_issues_found=false

# Check at command execution file permissions
for path in ${PATH//:/ }; do
    if [[ -x "$path/at" ]]; then
        permissions=$(stat -c "%a" "$path/at")
        if [[ "$permissions" =~ .*[2-7]. ]]; then
            result="취약"
            permission_issues_found=true
            status+=("$path/at 실행 파일이 다른 사용자(other)에 의해 실행이 가능합니다.")
        fi
    fi
done

# Check /etc/at.allow and /etc/at.deny file permissions
at_access_control_files=("/etc/at.allow" "/etc/at.deny")
for file in "${at_access_control_files[@]}"; do
    if [[ -f "$file" ]]; then
        permissions=$(stat -c "%a" "$file")
        file_owner=$(stat -c "%U" "$file")
        if [[ "$file_owner" != "root" ]] || [[ "$permissions" -gt 640 ]]; then
            result="취약"
            permission_issues_found=true
            status+=("$file 파일의 소유자가 $file_owner이고, 권한이 ${permissions}입니다.")
        fi
    fi
done

# Determine final diagnosis result
if ! $permission_issues_found; then
    result="양호"
    status=("모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다.")
fi

# Write final result to CSV
diagnosisResult="$result"
for i in "${status[@]}"; do
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$i" >> $OUTPUT_CSV
done

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
