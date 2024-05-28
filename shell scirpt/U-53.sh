#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-53"
riskLevel="하"
diagnosisItem="사용자 shell 점검"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-53"
diagnosisItem="사용자 shell 점검 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그인이 필요하지 않은 계정에 /bin/false 또는 /sbin/nologin 쉘이 부여된 경우
[취약]: 로그인이 필요하지 않은 계정에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않은 경우
EOF

BAR

# 불필요한 계정 목록
unnecessary_accounts=(
    "daemon" "bin" "sys" "adm" "listen" "nobody" "nobody4"
    "noaccess" "diag" "operator" "gopher" "games" "ftp" "apache"
    "httpd" "www-data" "mysql" "mariadb" "postgres" "mail" "postfix"
    "news" "lp" "uucp" "nuucp"
)

if [ -f "/etc/passwd" ]; then
    shell_issue_found=false
    while IFS=: read -r username _ _ _ _ _ shell; do
        for account in "${unnecessary_accounts[@]}"; do
            if [ "$username" == "$account" ] && [ "$shell" != "/bin/false" ] && [ "$shell" != "/sbin/nologin" ]; then
                shell_issue_found=true
                echo "계정 $username에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다." >> $TMP1
                break
            fi
        done
    done < /etc/passwd

    if [ "$shell_issue_found" = true ]; then
        diagnosisResult="계정에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="로그인이 필요하지 않은 계정에 적절한 쉘이 부여되었습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="/etc/passwd 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
