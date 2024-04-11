#!/bin/bash

start_path="/tmp"
no_owner_files=()
status="양호"
현황="소유자가 존재하지 않는 파일 및 디렉터리가 없습니다."

# 소유자가 없는 파일 및 디렉터리 찾기
while IFS= read -r -d '' file; do
    uid=$(stat -c "%u" "$file")
    gid=$(stat -c "%g" "$file")
    if ! getent passwd "$uid" &>/dev/null || ! getent group "$gid" &>/dev/null; then
        no_owner_files+=("$file")
    fi
done < <(find "$start_path" -print0)

# 결과 설정
if [ ${#no_owner_files[@]} -gt 0 ]; then
    status="취약"
    현황="${no_owner_files[@]}"
fi

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"파일 및 디렉터리 관리\","
echo "  \"코드\": \"U-06\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"파일 및 디렉터리 소유자 설정\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": \"$현황\","
echo "  \"대응방안\": \"소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않도록 설정\""
echo "}"
