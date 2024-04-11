#!/bin/bash

# /etc/hosts.equiv 파일과 각 사용자의 $HOME/.rhosts 파일의 보안 상태를 점검하는 스크립트

declare -A results=(
    ["분류"]="파일 및 디렉터리 관리"
    ["코드"]="U-17"
    ["위험도"]="상"
    ["진단 항목"]="$HOME/.rhosts, hosts.equiv 사용 금지"
    ["진단 결과"]="양호"
    ["현황"]=()
    ["대응방안"]="login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 $HOME/.rhosts 파일 소유자, 권한, 설정 검증"
)

function check_permission_and_owner() {
    local path=$1
    local expected_owner=$2

    if [ ! -f "$path" ]; then
        return
    fi

    local owner=$(stat -c "%U" "$path")
    local permissions=$(stat -c "%a" "$path")
    local content=$(cat "$path")

    if [ "$owner" != "$expected_owner" ]; then
        results["진단 결과"]="취약"
        results["현황"]+=("$path: 소유자가 $expected_owner가 아님")
    elif [ "$permissions" -gt "600" ]; then
        results["진단 결과"]="취약"
        results["현황"]+=("$path: 권한이 600보다 큼")
    elif [[ "$content" == *"+"* ]]; then
        results["진단 결과"]="취약"
        results["현황"]+=("$path: 파일 내에 '+' 문자가 있음")
    fi
}

# /etc/hosts.equiv 파일 검증
check_permission_and_owner "/etc/hosts.equiv" "root"

# 사용자별 .rhosts 파일 검증
while IFS=: read -r username dir _; do
    if [ -d "$dir" ]; then
        check_permission_and_owner "$dir/.rhosts" "$username"
    fi
done < /etc/passwd

# 결과 출력
if [ ${#results["현황"][@]} -eq 0 ]; then
    results["현황"]+=("login, shell, exec 서비스 사용 시 /etc/hosts.equiv 및 $HOME/.rhosts 파일 문제 없음")
fi

echo "{"
for key in "${!results[@]}"; do
    echo "  \"$key\": $(printf '%s\n' "${results[$key]}" | jq -R . | jq -s .),"
done | sed '$ s/,$//'
echo "}"
