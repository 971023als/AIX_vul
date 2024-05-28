#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-12"
riskLevel="상"
diagnosisItem="/etc/services 파일 소유자 및 권한 설정"
service="File Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우
[취약]: /etc/services 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 644를 초과하는 경우
EOF

# Define the services file path
services_file="/etc/services"
results_info=()

# Check if the services file exists
if [ -e "$services_file" ]; then
    # Get file owner and permissions
    owner_name=$(ls -l $services_file | awk '{print $3}')
    perms=$(stat -c '%a' $services_file)

    # Check conditions
    if [ "$owner_name" = "root" ] || [ "$owner_name" = "bin" ] || [ "$owner_name" = "sys" ]; then
        if [ "$perms" -le 644 ]; then
            status="양호"
            results_info+=("$services_file 파일의 소유자가 $owner_name이고, 권한이 $perms입니다.")
        else
            status="취약"
            results_info+=("$services_file 파일의 소유자가 $owner_name이지만, 권한이 $perms로 설정되어 있어 취약합니다.")
        fi
    else
        status="취약"
        results_info+=("$services_file 파일의 소유자가 root, bin, sys 중 하나가 아닙니다.")
    fi
else
    status="N/A"
    results_info+=("$services_file 파일이 없습니다.")
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
