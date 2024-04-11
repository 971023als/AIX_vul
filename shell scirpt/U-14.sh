#!/bin/bash

# 결과를 저장할 배열 초기화
declare -A results=(
    ["분류"]="파일 및 디렉터리 관리"
    ["코드"]="U-14"
    ["위험도"]="상"
    ["진단 항목"]="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"
    ["진단 결과"]=""
    ["현황"]=""
    ["대응방안"]="홈 디렉터리 환경변수 파일 소유자가 해당 계정으로 지정되어 있고, 쓰기 권한이 그룹 또는 다른 사용자에게 부여되지 않은 경우"
)

start_files=(.profile .cshrc .login .kshrc .bash_profile .bashrc .bash_login)
vulnerable_files=()

# 모든 사용자의 홈 디렉토리 검색
while IFS=: read -r user _ _ _ _ home _; do
    if [[ -d "$home" ]]; then
        for start_file in "${start_files[@]}"; do
            file_path="$home/$start_file"
            if [[ -f "$file_path" ]]; then
                # 파일 소유자와 권한 확인
                if [[ $(stat -c "%U" "$file_path") != "$user" ]] || [[ $(stat -c "%A" "$file_path") =~ .*w.*g ]] || [[ $(stat -c "%A" "$file_path") =~ .*w.*o ]]; then
                    vulnerable_files+=("$file_path")
                fi
            fi
        done
    fi
done </etc/passwd

if [[ ${#vulnerable_files[@]} -eq 0 ]]; then
    results["진단 결과"]="양호"
    results["현황"]="모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다."
else
    results["진단 결과"]="취약"
    for file in "${vulnerable_files[@]}"; do
        results["현황"]+="{\"파일 경로\":\"$file\"},"
    done
fi

# 결과를 JSON 형태로 변환하여 출력
echo ${results[@]} | jq -R 'split(" ") | {
    "분류": .[0],
    "코드": .[1],
    "위험도": .[2],
    "진단 항목": .[3],
    "진단 결과": .[4],
    "현황": .[5],
    "대응방안": .[6]
}' > user_system_start_files_check_results.json
