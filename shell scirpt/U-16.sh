#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-16"
riskLevel="상"
diagnosisItem="/dev에 존재하지 않는 device 파일 점검"
service="System Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: /dev 디렉터리에 존재하지 않는 device 파일이 없습니다.
[취약]: /dev 디렉터리에 존재하지 않는 device 파일이 있습니다.
EOF

DEV_DIRECTORY="/dev"
NON_DEVICE_FILES=()
RESULT=""
STATUS=""

# Traverse /dev directory to check for non-device files
for ITEM in $(ls $DEV_DIRECTORY); do
    ITEM_PATH="${DEV_DIRECTORY}/${ITEM}"
    if [ -f "$ITEM_PATH" ] && [ ! -L "$ITEM_PATH" ]; then  # Exclude symbolic links
        if [ ! -c "$ITEM_PATH" ] && [ ! -b "$ITEM_PATH" ]; then  # Not a character or block device
            NON_DEVICE_FILES+=("$ITEM_PATH")
        fi
    fi
done

# Set diagnosis result
if [ ${#NON_DEVICE_FILES[@]} -gt 0 ]; then
    diagnosisResult="취약"
    status=$(printf ",%s" "${NON_DEVICE_FILES[@]}")
    status=${status:1}  # Remove leading comma
    echo "WARN: /dev 디렉터리에 존재하지 않는 device 파일이 있습니다." >> $TMP1
else
    diagnosisResult="양호"
    status="/dev 디렉터리에 존재하지 않는 device 파일이 없습니다."
    echo "OK: /dev 디렉터리에 존재하지 않는 device 파일이 없습니다." >> $TMP1
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Display the result
cat $TMP1
echo
cat $OUTPUT_CSV
