#!/usr/bin/python3
import os
import json
import re

def check_password_complexity():
    results = {
        "분류": "계정 관리",
        "코드": "U-02",
        "위험도": "상",
        "진단 항목": "패스워드 복잡성 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능 설정"
    }

    # AIX 시스템에서 패스워드 복잡성 설정을 확인하기 위한 기준
    min_length = 8
    password_criteria = {
        "minlen": min_length,  # 최소 길이
        "minalpha": 1,  # 최소 알파벳 문자 수
        "minother": 1,  # 최소 비알파벳 문자 수 (숫자 + 특수 문자)
    }
    file_path = "/etc/security/user"
    password_settings_found = False

    if os.path.exists(file_path):
        with open(file_path, "r", encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                if not line.startswith("#") and line != "":
                    for key, requirement in password_criteria.items():
                        if key in line:
                            password_settings_found = True
                            value = int(re.search(r'\d+', line.split("=")[1]).group())
                            if value < requirement:
                                results["현황"].append(f"{file_path}에서 설정된 {key}이(가) 요구 사항보다 낮습니다.")

    if password_settings_found:
        results["진단 결과"] = "양호" if not results["현황"] else "취약"
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("패스워드 복잡성 설정이 없습니다.")

    return results

def main():
    results = check_password_complexity()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
