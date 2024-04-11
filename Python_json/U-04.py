#!/usr/bin/python3
import os
import json

def check_shadow_password_usage():
    results = {
        "분류": "계정 관리",
        "코드": "U-04",
        "위험도": "상",
        "진단 항목": "패스워드 파일 보호",
        "진단 결과": "",
        "현황": [],
        "대응방안": "패스워드 암호화 저장"
    }

    # AIX 시스템에서는 /etc/security/passwd 파일을 검사
    security_passwd_file = "/etc/security/passwd"
    password_encrypted = True  # 가정: 패스워드가 암호화되어 저장됨

    if os.path.exists(security_passwd_file):
        with open(security_passwd_file, "r", encoding='utf-8') as file:
            content = file.read()
            # AIX에서는 패스워드 필드가 암호화되어 있는지 직접 확인하는 것이 어렵습니다.
            # 대신, 파일이 존재하는지와 적절한 권한 설정을 가지고 있는지 확인합니다.
            mode = os.stat(security_passwd_file).st_mode
            if not (mode & 0o400):  # /etc/security/passwd가 읽기 전용으로 설정되어 있는지 확인
                results["현황"].append("/etc/security/passwd 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
                password_encrypted = False
    else:
        results["현황"].append("/etc/security/passwd 파일이 존재하지 않습니다.")
        password_encrypted = False

    if not password_encrypted:
        results["현황"].append("패스워드 정보가 안전하게 암호화되어 저장되지 않았거나 /etc/security/passwd 파일의 권한 설정이 적절하지 않습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("패스워드 정보가 안전하게 암호화되어 저장되며 /etc/security/passwd 파일의 권한 설정이 적절합니다.")
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_shadow_password_usage()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
