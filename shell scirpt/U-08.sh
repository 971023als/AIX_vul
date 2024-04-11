#!/bin/bash

# 변수 설정
security_passwd_file="/etc/security/passwd"
results_status="양호"
results_info=""

# /etc/security/passwd 파일 존재 여부 및 소유자, 권한 검사
if [ -e "$security_passwd_file" ]; then
    owner_uid=$(stat -c '%u' "$security_passwd_file")
    permissions=$(stat -c '%a' "$security_passwd_file")

    # 소유자가 root인지 확인
    if [ "$owner_uid" -eq 0 ]; then
        # 파일 권한이 400 이하인지 확인
        if [ "$permissions" -le 400 ]; then
            results_info="/etc/security/passwd 파일의 소유자가 root이고, 권한이 ${permissions}입니다."
        else
            results_status="취약"
            results_info="/etc/security/passwd 파일의 권한이 ${permissions}로 설정되어 있어 취약합니다."
        fi
    else
        results_status="취약"
        results_info="/etc/security/passwd 파일의 소유자가 root가 아닙니다."
    fi
else
    results_status="N/A"
    results_info="/etc/security/passwd 파일이 없습니다."
fi

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"파일 및 디렉터리 관리\","
echo "  \"코드\": \"U-08\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"/etc/security/passwd 파일 소유자 및 권한 설정\","
echo "  \"진단 결과\": \"$results_status\","
echo "  \"현황\": [\"$results_info\"],"
echo "  \"대응방안\": \"/etc/security/passwd 파일의 소유자가 root이고, 권한이 400 이하인 경우\""
echo "}"
