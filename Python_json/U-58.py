#!/usr/bin/python3
import pwd
import os
import json

def check_home_directories_existence():
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-58",
        "위험도": "중",
        "진단 항목": "홈디렉토리로 지정한 디렉토리의 존재 관리",
        "진단 결과": "",
        "현황": [],
        "대응방안": "홈 디렉터리가 존재하지 않는 계정이 없도록 관리"
    }

    users = pwd.getpwall()
    any_vulnerabilities_found = False
    for user in users:
        # Adjust UID threshold according to your AIX environment
        if user.pw_uid >= 500 and not user.pw_shell.endswith("nologin") and not user.pw_shell.endswith("false"):
            home_dir = os.path.realpath(user.pw_dir)  # Resolve any symbolic links to get the real path
            if not os.path.exists(home_dir) or (home_dir == "/" and user.pw_name != "root"):
                any_vulnerabilities_found = True
                if not os.path.exists(home_dir):
                    results["현황"].append(f"{user.pw_name} 계정의 홈 디렉터리 ({user.pw_dir}) 가 존재하지 않습니다.")
                elif home_dir == "/":
                    results["현황"].append(f"관리자 계정(root)이 아닌데 {user.pw_name} 계정의 홈 디렉터리가 '/'로 설정되어 있습니다.")

    if any_vulnerabilities_found:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 사용자 계정의 홈 디렉터리가 적절히 설정되어 있습니다.")

    return results

def main():
    home_directory_check_results = check_home_directories_existence()
    print(json.dumps(home_directory_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
