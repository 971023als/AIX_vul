#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-71"
riskLevel="중"
diagnosisItem="Apache 웹 서비스 정보 숨김"
service="Apache"
diagnosisResult=""
status=""
recommendation="ServerTokens Prod, ServerSignature Off로 설정"

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Apache 설정이 적절히 설정되어 있는 경우
[취약]: Apache 설정이 적절히 설정되어 있지 않은 경우
EOF

BAR

# Web configuration files to search for
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
configuration_set_correctly=false

# Search and check configurations
for conf_file in "${webconf_files[@]}"; do
    while IFS= read -r -d '' file_path; do
        if [[ -f "$file_path" ]]; then
            if grep -Eiq '^\s*ServerTokens\s+Prod' "$file_path" && grep -Eiq '^\s*ServerSignature\s+Off' "$file_path"; then
                configuration_set_correctly=true
                break 2 # Exit both loop and if condition as soon as one file is correctly configured
            fi
        fi
    done < <(find / -type f -name "$conf_file" -print0 2>/dev/null)
done

# Determine the diagnostic result
if $configuration_set_correctly; then
    diagnosisResult="Apache 설정이 적절히 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    if pgrep -f 'apache2|httpd' > /dev/null; then
        diagnosisResult="Apache 서비스를 사용하고 있으나, ServerTokens Prod, ServerSignature Off 설정이 적절히 구성되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Apache 서비스 미사용."
        status="양호"
        echo "INFO: $diagnosisResult" >> $TMP1
    fi
fi

# Write final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo
cat $OUTPUT_CSV
