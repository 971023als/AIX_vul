#!/bin/bash

# 변수 설정
security_passwd_file="/etc/security/passwd"
status="양호"
conditions=()

# /etc/security/passwd 파일 존재 및 권한 설정 검사
if [ -f "$security_passwd_file" ]; then
    # 파일 권한 검사 (읽기 전용으로 설정되어 있는지 확인)
    if [ ! -r "$security_passwd_file" ]; then
        conditions+=("/etc/security/passwd 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
        status="취약"
    fi
else
    conditions+=("/etc/security/passwd 파일이 존재하지 않습니다.")
    status="취약"
fi

if [ "$status" == "양호" ]; then
    conditions+=("패스워드 정보가 안전하게 암호화되어 저장되며 /etc/security/passwd 파일의 권한 설정이 적절합니다.")
else
    conditions+=("패스워드 정보가 안전하게 암호화되어 저장되지 않았거나 /etc/security/passwd 파일의 권한 설정이 적절하지 않습니다.")
fi

# JSON 형태로 결과 출력
echo "{"
echo "  \"분류\": \"계정 관리\","
echo "  \"코드\": \"U-04\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"패스워드 파일 보호\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": ["
for condition in "${conditions[@]}"; do
    echo "    \"$condition\""
    if [[ ! ${condition} == ${conditions[-1]} ]]; then
        echo ","
    fi
done
echo "  ],"
echo "  \"대응방안\": \"패스워드 암호화 저장\""
echo "}"
