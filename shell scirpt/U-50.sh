#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-50"
riskLevel="하"
diagnosisItem="관리자 그룹에 최소한의 계정 포함"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="U-50"
diagnosisItem="관리자 그룹에 최소한의 계정 포함 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 관리자 그룹(root)에 불필요한 계정이 없는 경우
[취약]: 관리자 그룹(root)에 불필요한 계정이 있는 경우
EOF

BAR

# 불필요한 계정 목록
unnecessary_accounts=(
    "bin" "sys" "adm" "listen" "nobody4" "noaccess" "diag"
    "operator" "gopher" "games" "ftp" "apache" "httpd" "www-data"
    "mysql" "mariadb" "postgres" "mail" "postfix" "news" "lp"
    "uucp" "nuucp" "sync" "shutdown" "halt" "mailnull" "smmsp"
    "manager" "dumper" "abuse" "webmaster" "noc" "security"
    "hostmaster" "info" "marketing" "sales" "support" "accounts"
    "help" "admin" "guest" "user" "ubuntu"
)

if [ -f "/etc/group" ]; then
    root_group_found=false
    while IFS=: read -r group_name _ _ members; do
        if [ "$group_name" == "system" ]; then
            root_group_found=true
            IFS=',' read -ra members_array <<< "$members"
            found_accounts=()
            for account in "${members_array[@]}"; do
                for unnecessary_account in "${unnecessary_accounts[@]}"; do
                    if [ "$account" == "$unnecessary_account" ]; then
                        found_accounts+=("$account")
                        break
                    fi
                done
            done

            if [ ${#found_accounts[@]} -gt 0 ]; then
                diagnosisResult="관리자 그룹(system)에 불필요한 계정이 등록되어 있습니다: ${found_accounts[*]}"
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
            else
                diagnosisResult="관리자 그룹(system)에 불필요한 계정이 없습니다."
                status="양호"
                echo "OK: $diagnosisResult" >> $TMP1
            fi
            break
        fi
    done < "/etc/group"

    if [ "$root_group_found" = false ]; then
        diagnosisResult="관리자 그룹(system)을 /etc/group 파일에서 찾을 수 없습니다."
        status="오류"
        echo "ERROR: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="/etc/group 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
