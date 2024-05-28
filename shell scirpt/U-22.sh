#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-22"
riskLevel="상"
diagnosisItem="crond 파일 소유자 및 권한 설정 (AIX)"
service="Service Management"
diagnosisResult="양호"
status="crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정
[취약]: crontab 명령어 일반사용자 허용 또는 cron 관련 파일 640 이하 권한 미설정
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

function validate_file() {
    local path=$1
    local permission_limit=$2
    if [ -e "$path" ]; then
        local mode=$(stat -c "%a" "$path")
        local owner=$(stat -c "%u" "$path")

        if [ "$owner" != "0" ] || [ "$mode" -gt "$permission_limit" ]; then
            results["진단 결과"]="취약"
            [ "$owner" != "0" ] && results["현황"]+=("$path 파일의 소유자(owner)가 root가 아닙니다.")
            [ "$mode" -gt "$permission_limit" ] && results["현황"]+=("$path 파일의 권한이 $permission_limit보다 큽니다.")
        fi
    fi
}

# crontab 명령어 권한 검사
validate_file "/usr/bin/crontab" 750

# cron 관련 경로 목록
cron_paths=(
    "/etc/crontab" "/etc/cron.allow" "/etc/cron.deny"
    "/var/spool/cron" "/var/spool/cron/crontabs"
    "/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly"
)

# cron 파일 및 디렉토리 권한 검사
for path in "${cron_paths[@]}"; do
    if [ -d "$path" ]; then
        for file in $(find "$path" -type f); do
            validate_file "$file" 640
        done
    else
        validate_file "$path" 640
    fi
done

# Combine status messages into a single string
if [ "${results["진단 결과"]}" == "양호" ]; then
    status="crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
else
    status=$(IFS="; " ; echo "${results["현황"][*]}")
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,${results["진단 결과"]},$status" >> $OUTPUT_CSV

# Display the result
echo "category: $category"
echo "code: $code"
echo "riskLevel: $riskLevel"
echo "diagnosisItem: $diagnosisItem"
echo "service: $service"
echo "diagnosisResult: ${results["진단 결과"]}"
echo "status: $status"

cat $TMP1
echo
cat $OUTPUT_CSV
