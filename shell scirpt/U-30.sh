#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-30"
riskLevel="상"
diagnosisItem="Sendmail 버전 점검 (AIX)"
service="Service Management"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Sendmail 버전이 최신 버전입니다.
[취약]: Sendmail 버전이 최신 버전이 아닙니다.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

latest_version="8.17.1" # 최신 Sendmail 버전 예시

# AIX에서 Sendmail 버전 확인
output=$(lslpp -L | grep -i 'sendmail')
sendmail_version=""

if [[ $output ]]; then
    if [[ $output =~ sendmail[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        sendmail_version="${BASH_REMATCH[1]}"
    fi
fi

# 버전 비교 및 결과 설정
if [[ $sendmail_version ]]; then
    if [[ $sendmail_version == $latest_version* ]]; then
        results["진단 결과"]="양호"
        results["현황"]+=("Sendmail 버전이 최신 버전(${latest_version})입니다.")
    else
        results["진단 결과"]="취약"
        results["현황"]+=("Sendmail 버전이 최신 버전(${latest_version})이 아닙니다. 현재 버전: ${sendmail_version}")
    fi
else
    results["진단 결과"]="양호"
    results["현황"]+=("Sendmail이 설치되어 있지 않습니다.")
fi

# Combine status messages into a single string
status=$(IFS="; " ; echo "${results["현황"][*]}")

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
