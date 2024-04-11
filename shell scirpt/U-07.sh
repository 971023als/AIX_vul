#!/bin/bash

check_file_permissions() {
    local file_path=$1
    if [ -e "$file_path" ]; then
        local file_info=$(ls -l "$file_path")
        local owner=$(echo "$file_info" | awk '{print $3}')
        local permissions=$(echo "$file_info" | awk '{print $1}')
        
        if [ "$owner" == "root" ]; then
            # Convert permissions from symbolic to numeric mode
            local mode=$(stat -c "%a" "$file_path")
            if [ "$mode" -le 644 ]; then
                echo "\"양호\", \"${file_path} 파일의 소유자가 root이고, 권한이 ${mode}입니다.\""
            else
                echo "\"취약\", \"${file_path} 파일의 권한이 ${mode}로 설정되어 있어 취약합니다.\""
            fi
        else
            echo "\"취약\", \"${file_path} 파일의 소유자가 root가 아닙니다.\""
        fi
    else
        echo "\"N/A\", \"${file_path} 파일이 없습니다.\""
    fi
}

# 검사 실행
passwd_result=$(check_file_permissions "/etc/passwd")
security_passwd_result=$(check_file_permissions "/etc/security/passwd")

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"파일 및 디렉터리 관리\","
echo "  \"코드\": \"U-07\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"/etc/passwd 및 /etc/security/passwd 파일 소유자 및 권한 설정\","
echo "  \"진단 결과\": \"$( [ "$passwd_result" == "\"취약\"" ] || [ "$security_passwd_result" == "\"취약\"" ] && echo "취약" || echo "양호")\","
echo "  \"현황\": [ $passwd_result, $security_passwd_result ],"
echo "  \"대응방안\": \"파일의 소유자가 root이고, 권한이 644 이하인 경우\""
echo "}"
