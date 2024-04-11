#!/usr/bin/python3
import os
import stat
import json
import sys

# Python3의 경우, 표준 출력의 인코딩을 UTF-8로 설정
if sys.version_info.major == 3:
    sys.stdout.reconfigure(encoding='utf-8')

def check_file_permissions(file_path):
    if os.path.exists(file_path):
        file_stat = os.stat(file_path)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o644:
                return "양호", f"{file_path} 파일의 소유자가 root이고, 권한이 {mode}입니다."
            else:
                return "취약", f"{file_path} 파일의 권한이 {mode}로 설정되어 있어 취약합니다."
        else:
            return "취약", f"{file_path} 파일의 소유자가 root가 아닙니다."
    else:
        return "N/A", f"{file_path} 파일이 없습니다."

def main():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-07",
        "위험도": "상",
        "진단 항목": "/etc/passwd 및 /etc/security/passwd 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "파일의 소유자가 root이고, 권한이 644 이하인 경우"
    }

    passwd_check = check_file_permissions('/etc/passwd')
    security_passwd_check = check_file_permissions('/etc/security/passwd')

    results["현황"].append(passwd_check[1])
    results["현황"].append(security_passwd_check[1])

    if passwd_check[0] == "취약" or security_passwd_check[0] == "취약":
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
    
    # 결과를 콘솔에 출력
    print(json.dumps(results, ensure_ascii=False, indent=4))
    # 결과를 파일에 쓰기
    with open('results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
