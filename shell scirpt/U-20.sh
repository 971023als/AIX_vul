#!/bin/bash

# AIX 시스템에서 익명 FTP(Anonymous FTP) 사용 여부를 점검하는 스크립트

declare -A results=(
    ["분류"]="시스템 설정"
    ["코드"]="U-20"
    ["위험도"]="상"
    ["진단 항목"]="Anonymous FTP 비활성화 (AIX)"
    ["진단 결과"]=""
    ["현황"]=()
    ["대응방안"]="[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우\n[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우"
)

# FTP 계정 존재 여부 확인
if getent passwd ftp > /dev/null 2>&1; then
    results["진단 결과"]="취약"
    results["현황"]+=("FTP 계정이 /etc/passwd 파일에 있습니다.")
else
    results["진단 결과"]="양호"
    results["현황"]+=("FTP 계정이 /etc/passwd 파일에 없습니다.")
fi

# FTP 서비스 활성화 여부 확인
ftp_service_status=$(lssrc -s ftpd)
if echo "$ftp_service_status" | grep -q "active"; then
    results["진단 결과"]="취약"
    results["현황"]+=("FTP 서비스가 활성화되어 있습니다.")
fi

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
