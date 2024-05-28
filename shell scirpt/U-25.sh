#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-25"
riskLevel="상"
diagnosisItem="NFS 접근 통제"
service="Service Management"
diagnosisResult="양호"
status="NFS 접근 통제 설정에 문제가 없습니다."

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NFS 접근 통제 설정에 문제가 없습니다.
[취약]: NFS 서비스가 실행 중이지만, /etc/exports 파일에 '*' 설정이 있습니다.
[취약]: NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다.
[오류]: NFS 서비스 확인 중 오류 발생.
EOF

declare -A results
results["진단 결과"]="양호"
results["현황"]=()

cmd="ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'"
process_output=$(eval "$cmd")
process_status=$?

if [ $process_status -eq 0 ]; then
    if [ -f "/etc/exports" ]; then
        # /etc/exports 파일 분석
        while IFS= read -r line; do
            if [[ ! $line =~ ^# && $line =~ \* ]]; then
                results["진단 결과"]="취약"
                results["현황"]+=("/etc/exports 파일에 '*' 설정이 있습니다.")
                break
            fi
        done < "/etc/exports"
    else
        results["진단 결과"]="취약"
        results["현황"]+=("NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다.")
    fi
elif [ $process_status -eq 1 ]; then
    results["진단 결과"]="양호"
    results["현황"]+=("NFS 서비스가 실행 중이지 않습니다.")
else
    results["진단 결과"]="오류"
    results["현황"]+=("NFS 서비스 확인 중 오류 발생")
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
