#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-67"
riskLevel="중"
diagnosisItem="SNMP 서비스 Community String의 복잡성 설정"
service="SNMP Service"
diagnosisResult=""
status=""
recommendation="SNMP Community 이름이 public, private이 아닌 경우"

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SNMP Community String이 적절히 설정되어 있는 경우
[취약]: SNMP Community String이 취약(public 또는 private)으로 설정되어 있는 경우
EOF

BAR

# Initialize result and status
result=""
status=""

# Check if SNMP service is running
if ! ps -ef | grep -i "snmp" | grep -v "grep" > /dev/null; then
    result="양호"
    status="SNMP 서비스를 사용하지 않고 있습니다."
else
    # Find snmpd.conf files
    snmpdconf_files=$(find / -name snmpd.conf -type f 2>/dev/null)
    weak_string_found=false

    if [[ -z "$snmpdconf_files" ]]; then
        result="취약"
        status="SNMP 서비스를 사용하고 있으나, Community String을 설정하는 파일이 없습니다."
    else
        for file_path in $snmpdconf_files; do
            if grep -Eiq "\b(public|private)\b" "$file_path"; then
                weak_string_found=true
                result="취약"
                status="SNMP Community String이 취약(public 또는 private)으로 설정되어 있습니다. 파일: $file_path"
                break
            fi
        done
    fi

    if ! $weak_string_found && [[ -n "$snmpdconf_files" ]]; then
        result="양호"
        status="SNMP Community String이 적절히 설정되어 있습니다."
    fi
fi

# Write final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
