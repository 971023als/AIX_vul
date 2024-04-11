#!/usr/bin/python3
import os
import json

def check_su_restriction_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-45",
        "위험도": "하",
        "진단 항목": "root 계정 su 제한 (AIX)",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "su 명령어 사용 특정 그룹 제한 (AIX)"
    }

    user_security_path = "/etc/security/user"
    if os.path.isfile(user_security_path):
        with open(user_security_path, 'r') as file:
            for line in file:
                if line.strip().startswith("su ="):
                    su_setting = line.strip().split("=")[-1].strip()
                    if su_setting.lower() in ["true", "yes"]:
                        results["진단 결과"] = "양호"
                        results["현황"].append("su 명령어 사용이 제한되어 있습니다.")
                        break
                    else:
                        results["진단 결과"] = "취약"
                        results["현황"].append("su 명령어 사용 제한 설정이 적절하지 않습니다.")
                        break
            else:
                # If the loop completes without breaking, su setting was not found
                results["진단 결과"] = "취약"
                results["현황"].append("su 명령어 사용 제한 설정이 구성되지 않았습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/security/user 파일이 존재하지 않습니다.")

    return results

def main():
    su_restriction_check_results_aix = check_su_restriction_aix()
    print(json.dumps(su_restriction_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

