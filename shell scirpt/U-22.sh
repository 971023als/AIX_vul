#!/bin/bash

# AIX 시스템에서 cron 관련 파일 및 디렉토리의 권한 및 소유권을 점검하는 스크립트

declare -A results=(
    ["분류"]="서비스 관리"
    ["코드"]="U-22"
    ["위험도"]="상"
    ["진단 항목"]="crond 파일 소유자 및 권한 설정 (AIX)"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
)

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

# 결과를 JSON 형태로 출력
echo "{"
echo "    \"분류\": \"${results["분류"]}\","
echo "    \"코드\": \"${results["코드"]}\","
echo "    \"위험도\": \"${results["위험도"]}\","
echo "    \"진단 항목\": \"${results["진단 항목"]}\","
echo "    \"진단 결과\": \"${results["진단 결과"]}\","
echo "    \"현황\": ["
for ((i=0; i<${#results["현황"][@]}; i++)); do
    echo "        \"${results["현황"][$i]}\"$(if [[ $i -lt $((${#results["현황"][@]} - 1)) ]]; then echo ","; fi)"
done
echo "    ],"
echo "    \"대응방안\": \"${results["대응방안"]}\""
echo "}"
