#!/usr/bin/python3
import os
import json
import re
import pwd

def check_insecure_path():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-05",
        "위험도": "상",
        "진단 항목": "root홈, 패스 디렉터리 권한 및 패스 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정"
    }

    # AIX에서 사용되는 글로벌 설정 파일
    global_files = [
        "/etc/profile",
        "/etc/environment",
        # AIX에는 /etc/.login, /etc/csh.cshrc, /etc/csh.login와 같은 파일이 없을 수 있으므로,
        # 주로 사용되는 /etc/profile과 /etc/environment를 포함시킴
    ]

    # AIX 시스템에서 사용자별로 적용될 수 있는 환경 설정 파일
    user_files = [
        ".profile",
        ".kshrc",
        ".bash_profile",
        ".bashrc",
        ".bash_login",
        # AIX 사용자가 주로 사용할 수 있는 쉘 구성 파일 목록
    ]

    # 글로벌 설정 파일 검사
    for file in global_files:
        if os.path.exists(file):
            with open(file, 'r') as f:
                content = f.read()
                if re.search(r'\b\.\b|(^|:)\.(:|$)', content):
                    results["현황"].append(f"{file} 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")

    # 사용자 홈 디렉터리 설정 파일 검사
    users = pwd.getpwall()
    for user in users:
        home_dir = user.pw_dir
        for file in user_files:
            file_path = os.path.join(home_dir, file)
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    content = f.read()
                    if re.search(r'\b\.\b|(^|:)\.(:|$)', content):
                        results["현황"].append(f"{file_path} 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")

    # 진단 결과 설정
    if results["현황"]:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_insecure_path()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
