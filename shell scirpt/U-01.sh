#!/bin/bash

# 변수 초기화
sshd_config_path="/etc/ssh/sshd_config"  # SSH 설정 파일 경로
root_login_restricted="true"  # root 로그인 제한 여부
status="양호"  # 기본 진단 결과
condition=()  # 현황 정보를 저장할 배열

# SSH 서비스 검사
while IFS= read -r line; do
  if [[ $line =~ ^PermitRootLogin\ yes ]]; then
    root_login_restricted="false"
    break
  fi
done < "$sshd_config_path"

if [ "$root_login_restricted" == "false" ]; then
  status="취약"
  condition+=("SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다.")
else
  condition+=("SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다.")
fi

# JSON 형태로 출력
echo "{"
echo "  \"분류\": \"계정관리\","
echo "  \"코드\": \"U-01\","
echo "  \"위험도\": \"상\","
echo "  \"진단 항목\": \"root 계정 원격접속 제한\","
echo "  \"진단 결과\": \"$status\","
echo "  \"현황\": ["
for ((i = 0; i < ${#condition[@]}; i++)); do
  echo "    \"${condition[$i]}\""
  if [ $((i + 1)) -lt ${#condition[@]} ]; then
    echo ","
  fi
done
echo "  ],"
echo "  \"대응방안\": \"원격 터미널 서비스 사용 시 root 직접 접
