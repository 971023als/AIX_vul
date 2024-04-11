#!/bin/bash

# JSON 형태로 결과를 출력하기 위해 jq 필요 (jq 설치 필요)
# AIX 시스템에 jq가 설치되어 있지 않다면, 설치해야 합니다.

declare -A results=(
    ["분류"]="파일 및 디렉터리 관리"
    ["코드"]="U-13"
    ["위험도"]="상"
    ["진단 항목"]="SUID, SGID 설정 파일 점점"
    ["진단 결과"]=""
    ["현황"]=""
    ["대응방안"]="주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우"
)

    executables = [
        "/sbin/dump", "/sbin/restore", "/sbin/unix_chkpwd",
        "/usr/bin/at", "/usr/bin/lpq", "/usr/bin/lpq-lpd",
        "/usr/bin/lpr", "/usr/bin/lpr-lpd", "/usr/bin/lprm",
        "/usr/bin/lprm-lpd", "/usr/bin/newgrp", "/usr/sbin/lpc",
        "/usr/sbin/lpc-lpd", "/usr/sbin/traceroute"
    ]
vulnerable_files=()

for executable in "${executables[@]}"; do
    if [[ -f "$executable" ]]; then
        mode=$(stat -c "%a" "$executable")
        if [[ $((mode & 4000)) -ne 0 ]] || [[ $((mode & 2000)) -ne 0 ]]; then
            vulnerable_files+=("$executable")
        fi
    fi
done

if [[ ${#vulnerable_files[@]} -eq 0 ]]; then
    results["진단 결과"]="양호"
    results["현황"]="SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 없습니다."
else
    results["진단 결과"]="취약"
    for file in "${vulnerable_files[@]}"; do
        results["현황"]+="{\"파일 경로\":\"$file\"},"
    done
fi

# JSON 형태로 결과 출력
echo ${results[@]} | jq -R 'split(" ") | {분류:.[0], 코드:.[1], 위험도:.[2], 진단 항목:.[3], 진단 결과:.[4], 현황:.[5], 대응방안:.[6]}' > suid_sgid_check_results.json