#!/bin/bash

# JSON 출력을 위한 준비
echo '{
    "분류": "파일 및 디렉터리 관리",
    "코드": "U-10",
    "위험도": "상",
    "진단 항목": "/etc/(x)inetd.conf 파일 소유자 및 권한 설정",
    "진단 결과": null,
    "현황": [],
    "대응방안": "/etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 미만인 경우"
}' > results.json

# 검사할 파일 및 디렉터리
files_to_check=("/etc/inetd.conf" "/etc/xinetd.conf")
directories_to_check=("/etc/xinetd.d")
check_passed=true

check_file_ownership_and_permissions() {
    file_path=$1
    if [ ! -f "$file_path" ]; then
        jq --arg file_path "$file_path" '.현황 += ["\($file_path) 파일이 없습니다."]' results.json > temp.json && mv temp.json results.json
    else
        owner_uid=$(stat -c "%u" "$file_path")
        permissions=$(stat -c "%a" "$file_path")
        if [ "$owner_uid" == "0" ] && [ "$permissions" -ge "600" ]; then
            jq --arg file_path "$file_path" '.현황 += ["\($file_path) 파일의 소유자가 root이고, 권한이 600 이상입니다."]' results.json > temp.json && mv temp.json results.json
            check_passed=false
        fi
    fi
}

check_directory_files_ownership_and_permissions() {
    directory_path=$1
    if [ ! -d "$directory_path" ]; then
        jq --arg directory_path "$directory_path" '.현황 += ["\($directory_path) 디렉터리가 없습니다."]' results.json > temp.json && mv temp.json results.json
    else
        find "$directory_path" -type f | while read -r file_path; do
            check_file_ownership_and_permissions "$file_path"
        done
    fi
}

# 파일 검사
for file_path in "${files_to_check[@]}"; do
    check_file_ownership_and_permissions "$file_path"
done

# 디렉터리 검사
for directory_path in "${directories_to_check[@]}"; do
    check_directory_files_ownership_and_permissions "$directory_path"
done

# 진단 결과 업데이트
if $check_passed; then
    jq '.진단 결과 = "양호"' results.json > temp.json && mv temp.json results.json
else
    jq '.진단 결과 = "취약"' results.json > temp.json && mv temp.json results.json
fi

# 최종 결과 출력
cat results.json
