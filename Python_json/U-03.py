#!/usr/bin/python3
import os
import json
import re

def check_account_lockout_threshold():
    results = {
        "분류": "계정 관리",
        "코드": "U-03",
        "위험도": "상",
        "진단 항목": "계정 잠금 임계값 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "계정 잠금 임계값을 10회 이하로 설정"
    }

    file_path = "/etc/security/user"
    lockout_threshold_set = False

    if os.path.exists(file_path):
        with open(file_path, "r", encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                if not line.startswith("#") and "loginretries" in line:
                    # Extract the loginretries value
                    loginretries_value_matches = re.findall(r'loginretries\s*=\s*[0-9]+', line)
                    if loginretries_value_matches:
                        loginretries_value = int(loginretries_value_matches[0].split('=')[1].strip())
                        if loginretries_value <= 10:
                            lockout_threshold_set = True
                        else:
                            results["현황"].append(f"{file_path}에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")
                    break  # loginretries 설정을 찾으면 루프를 종료

    if not lockout_threshold_set:
        results["현황"].append(f"{file_path}에서 적절한 계정 잠금 임계값 설정이 없습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("계정 잠금 임계값이 적절히 설정되었습니다.")
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_account_lockout_threshold()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
