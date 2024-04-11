#!/bin/sh

# Initialize variables to count files and compliance
file_exists_count=0
compliant_files_count=0

# Initialize an empty JSON string to hold the results
results='{
  "분류": "파일 및 디렉터리 관리",
  "코드": "U-11",
  "위험도": "상",
  "진단 항목": "syslog 설정 파일 소유자 및 권한",
  "진단 결과": "N/A",
  "현황": [],
  "대응방안": "syslog 설정 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우"
}'

# Function to update JSON results
update_json() {
  path=$1
  owner=$2
  perms=$3
  new_status="{ \"file\": \"$path\", \"owner\": \"$owner\", \"permissions\": \"$perms\" }"
  results=$(echo $results | jq --argjson newStatus "$new_status" '.현황 += [$newStatus]')
}

# AIX typically uses /etc/syslog.conf for syslog configuration
syslog_conf_files="/etc/syslog.conf"

for file_path in $syslog_conf_files; do
  if [ -f "$file_path" ]; then
    file_exists_count=$((file_exists_count+1))
    owner=$(ls -l $file_path | awk '{print $3}')
    perms=$(ls -l $file_path | awk '{print $1}')

    # Check if owner is root, bin, or sys and permissions are 640 or less
    if [ "$owner" = "root" ] || [ "$owner" = "bin" ] || [ "$owner" = "sys" ]; then
      octal_perms=$(stat -c "%a" $file_path)
      if [ "$octal_perms" -le 640 ]; then
        compliant_files_count=$((compliant_files_count+1))
        update_json "$file_path" "$owner" "$perms"
      fi
    fi
  fi
done

# Update the overall diagnosis based on file checks
if [ "$file_exists_count" -gt 0 ]; then
  if [ "$compliant_files_count" -eq "$file_exists_count" ]; then
    results=$(echo $results | jq '.진단 결과 = "양호"')
  else
    results=$(echo $results | jq '.진단 결과 = "취약"')
  fi
else
  results=$(echo $results | jq '.진단 결과 = "파일 없음"')
fi

echo $results | jq .
