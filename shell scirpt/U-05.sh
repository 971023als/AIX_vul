#!/bin/bash

# 변수 설정
declare -a global_files=(
    "/etc/profile"
    "/etc/environment"
)
declare -a user_files=(
    ".profile"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)
conditions=()

# 글로벌 설정 파일 검사
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -E '\b\.\b|(^|:)\.(:|$)' "$file" > /dev/null; then
            conditions+=("$file 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")
        fi
    fi
done

# 사용자 홈 디렉터리 설정 파일 검사
while IFS=: read -r _ _ _ _ _ home _; do
    for file in "${user_files[@]}"; do
        file_path="$home/$file"
        if [ -f "$file_path" ]; then
            if grep -E '\b\.\b|(^|:)\.(:|$)' "$file_path" > /dev/null; then
                conditions+=("$file_path 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")
            fi
        fi
    done
done < /etc/passwd

# JSON 형태로 결과 출력
status="양호"
if [ ${#conditions[@]} -ne 0 ]; then
    status="취약"
fi

echo "{"
echo "  \"분류\": \"파일 및 디렉터리 관리\","
echo "  \"코드\": \"U-05\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"root홈, 패스 디렉터리 권한 및 패스 설정\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": ["
for condition in "${conditions[@]}"; do
    echo "    \"$condition\""
    if [[ ! ${condition} == ${conditions[-1]} ]]; then
        echo ","
    fi
done
echo "  ],"
echo "  \"대응방안\": \"PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정\""
echo "}"
