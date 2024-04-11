#!/bin/bash

# 시작 디렉토리 설정
start_dir="/tmp"

# 임시 파일 초기화
temp_file=$(mktemp)
> "$temp_file"

# world writable 파일 찾기
find "$start_dir" -type f ! -path "*/proc/*" \( ! -lname "*" \) -perm -2 -exec ls -l {} \; > "$temp_file"

# 결과 JSON 생성
if [ -s "$temp_file" ]; then
    # 파일이 있을 경우
    jq -R -s --arg dir "$start_dir" --argjson status true '{
        분류: "파일 및 디렉터리 관리",
        코드: "U-15",
        위험도: "상",
        진단항목: "world writable 파일 점검",
        진단결과: "취약",
        현황: (split("\n") | map(select(. != ""))),
        대응방안: "시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인"
    }' < "$temp_file"
else
    # 파일이 없을 경우
    jq -n --arg dir "$start_dir" --argjson status false '{
        분류: "파일 및 디렉터리 관리",
        코드: "U-15",
        위험도: "상",
        진단항목: "world writable 파일 점검",
        진단결과: "양호",
        현황: ["world writable 설정이 되어있는 파일이 없습니다."],
        대응방안: "시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인"
    }'
fi

# 임시 파일 정리
rm -f "$temp_file"
