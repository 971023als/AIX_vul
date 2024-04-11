#!/bin/bash

# /dev 디렉터리를 점검하여 적절하지 않은 디바이스 파일이 아닌 항목을 찾는 쉘 스크립트

DEV_DIRECTORY="/dev"
NON_DEVICE_FILES=()
RESULT=""
STATUS=""

# /dev 내의 파일을 순회하며 체크
for ITEM in $(ls $DEV_DIRECTORY); do
    ITEM_PATH="${DEV_DIRECTORY}/${ITEM}"
    if [ -f "$ITEM_PATH" ] && [ ! -L "$ITEM_PATH" ]; then  # 심볼릭 링크 제외
        if [ ! -c "$ITEM_PATH" ] && [ ! -b "$ITEM_PATH" ]; then  # 캐릭터 및 블록 디바이스가 아닌 경우
            NON_DEVICE_FILES+=("$ITEM_PATH")
        fi
    fi
done

# 진단 결과 설정
if [ ${#NON_DEVICE_FILES[@]} -gt 0 ]; then
    RESULT="취약"
    STATUS=$(printf ",%s" "${NON_DEVICE_FILES[@]}")
    STATUS=${STATUS:1}  # 앞에 붙은 콤마 제거
else
    RESULT="양호"
    STATUS="/dev 디렉터리에 존재하지 않는 device 파일이 없습니다."
fi

# JSON 형태로 결과 출력
cat <<EOF
{
    "분류": "파일 및 디렉터리 관리",
    "코드": "U-16",
    "위험도": "상",
    "진단 항목": "/dev에 존재하지 않는 device 파일 점검",
    "진단 결과": "$RESULT",
    "현황": [
        "$STATUS"
    ],
    "대응방안": "/dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우"
}
EOF
