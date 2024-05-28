#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-33"
riskLevel="상"
diagnosisItem="DNS 보안 버전 패치"
service="DNS 서비스"
diagnosisResult=""
status=""

BAR

CODE="U-33"
diagnosisItem="DNS 보안 버전 패치 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: BIND 버전이 최신 보안 버전(9.18.7) 이상인 경우
[취약]: BIND 버전이 최신 보안 버전(9.18.7) 이상이 아닌 경우
EOF

BAR

get_bind_version_aix() {
    lslpp -L all | grep -i 'bind.base'
}

parse_version() {
    echo "$1" | awk -F. '{ printf "%d%03d%03d\n", $1,$2,$3 }'
}

minimum_version="9.18.7"

bind_version_output=$(get_bind_version_aix)

if [ -n "$bind_version_output" ]; then
    current_version=$(echo "$bind_version_output" | awk '{print $2}')
    if [ $(parse_version "$current_version") -lt $(parse_version "$minimum_version") ]; then
        diagnosisResult="BIND 버전이 최신 보안 버전($minimum_version) 이상이 아닙니다: $current_version"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="BIND 버전이 최신 보안 버전($minimum_version) 이상입니다: $current_version"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="BIND가 설치되어 있지 않거나 lslpp 명령어 실행 실패"
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
