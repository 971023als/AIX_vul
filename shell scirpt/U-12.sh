#!/bin/sh

# Define the services file path
services_file="/etc/services"

# Initialize JSON result structure
results='{
  "분류": "파일 및 디렉터리 관리",
  "코드": "U-12",
  "위험도": "상",
  "진단 항목": "/etc/services 파일 소유자 및 권한 설정",
  "진단 결과": "",
  "현황": [],
  "대응방안": "/etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우"
}'

# Check if the services file exists
if [ -e "$services_file" ]; then
  # Get file owner and permissions
  owner_name=$(ls -l $services_file | awk '{print $3}')
  perms=$(stat -c '%a' $services_file)

  # Check conditions
  if [ "$owner_name" = "root" ] || [ "$owner_name" = "bin" ] || [ "$owner_name" = "sys" ]; then
    if [ "$perms" -le 644 ]; then
      # Update JSON for compliant case
      results=$(echo $results | jq '.진단 결과 = "양호" | .현황 += [{"파일": "'$services_file'", "소유자": "'$owner_name'", "권한": "'$perms'"}]')
    else
      # Update JSON for non-compliant case
      results=$(echo $results | jq '.진단 결과 = "취약" | .현황 += [{"파일": "'$services_file'", "소유자": "'$owner_name'", "권한": "'$perms'"}]')
    fi
  else
    # Update JSON for non-compliant case
    results=$(echo $results | jq '.진단 결과 = "취약" | .현황 += [{"파일": "'$services_file'", "소유자": "'$owner_name'", "권한": "'$perms'"}]')
  fi
else
  # Update JSON for file not existing
  results=$(echo $results | jq '.진단 결과 = "N/A" | .현황 += [{"파일": "'$services_file'", "메시지": "파일이 없습니다."}]')
fi

# Output the results
echo $results | jq .
