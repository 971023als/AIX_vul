#!/usr/bin/python3
import os
import json
import subprocess

def check_password_min_length_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-46",
        "위험도": "중",
        "진단 항목": "패스워드 최소 길이 설정 (AIX)",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "패스워드 최소 길이 8자 이상으로 설정"
    }

    try:
        # Use 'lssec' to query the password minimum length setting
        output = subprocess.check_output(['lssec', '-f', '/etc/security/user', '-s', 'default', '-a', 'minlen'], universal_newlines=True)
        min_length = int(output.strip().split('=')[-1])
        
        if min_length < 8:
            results["진단 결과"] = "취약"
            results["현황"].append(f"패스워드 최소 길이가 {min_length}자로 설정되어 있습니다. 권장: 최소 8자")
        else:
            results["현황"].append(f"패스워드 최소 길이가 적절히 설정되어 있습니다: {min_length}자")

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"패스워드 최소 길이 설정을 확인하는 데 실패했습니다: {e}")

    return results

def main():
    password_min_length_check_results = check_password_min_length_aix()
    print(json.dumps(password_min_length_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
