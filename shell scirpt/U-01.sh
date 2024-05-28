#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-01"
riskLevel="상"
diagnosisItem="root 계정 원격접속 제한"
service="SSH"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다.
[취약]: SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다.
EOF

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
  diagnosisResult="SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다."
  condition+=("SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다.")
  echo "WARN: $diagnosisResult" >> $TMP1
else
  diagnosisResult="SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다."
  condition+=("SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다.")
  echo "OK: $diagnosisResult" >> $TMP1
fi

# Write result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
