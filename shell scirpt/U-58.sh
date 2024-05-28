#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-58"
riskLevel="중"
diagnosisItem="홈디렉토리로 지정한 디렉토리의 존재 관리"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-58"
diagnosisItem="홈 디렉토리로 지정한 디렉토리의 존재 관리"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 사용자 계정의 홈 디렉터리가 적절히 설정되어 있는 경우
[취약]: 사용자 계정의 홈 디렉터리가 존재하지 않거나 잘못 설정되어 있는 경우
EOF

BAR

vulnerability_found=false

# Check all user accounts
while IFS=: read -r username _ uid _ _ home_dir shell; do
  # Skip system accounts and accounts without a login shell
  if [ "$uid" -ge 1000 ] && [[ "$shell" != *"nologin" ]] && [[ "$shell" != *"false" ]]; then
    # If the home directory does not exist or is set to '/' for non-root accounts
    if [ ! -d "$home_dir" ] || { [ "$home_dir" == "/" ] && [ "$username" != "root" ]; }; then
      vulnerability_found=true
      if [ ! -d "$home_dir" ]; then
        diagnosisResult="$username 계정의 홈 디렉터리 ($home_dir) 가 존재하지 않습니다."
        status="취약"
      elif [ "$home_dir" == "/" ]; then
        diagnosisResult="관리자 계정(root)이 아닌데 $username 계정의 홈 디렉터리가 '/'로 설정되어 있습니다."
        status="취약"
      fi
      echo "WARN: $diagnosisResult" >> $TMP1
      echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
  fi
done < /etc/passwd

if [ "$vulnerability_found" = false ]; then
  diagnosisResult="모든 사용자 계정의 홈 디렉터리가 적절히 설정되어 있습니다."
  status="양호"
  echo "OK: $diagnosisResult" >> $TMP1
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
