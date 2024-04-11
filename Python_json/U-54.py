#!/usr/bin/python3
import os
import json
import glob

def check_session_timeout_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-54",
        "위험도": "하",
        "진단 항목": "AIX Session Timeout 설정",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "AIX Session Timeout을 600초(10분) 이하로 설정"
    }

    # AIX-specific files to check for session timeout settings
    check_files = ["/etc/profile", "/etc/environment"]
    # Including user-specific .kshrc files
    check_files += glob.glob("/home/*/.kshrc")
    check_files += glob.glob("/home/*/.profile")

    file_exists_count = 0
    no_tmout_setting_file = 0

    for file_path in check_files:
        if os.path.isfile(file_path):
            file_exists_count += 1
            with open(file_path, 'r') as file:
                contents = file.read()
                if "TMOUT" in contents or "LOGOUT" in contents:  # AIX might use LOGOUT for ksh
                    for line in contents.splitlines():
                        if line.strip().startswith("TMOUT") or line.strip().startswith("LOGOUT"):
                            setting_value = line.split("=")[-1].strip()
                            try:
                                if int(setting_value) > 600:
                                    results["진단 결과"] = "취약"
                                    results["현황"].append(f"{file_path} 파일에 세션 타임아웃이 600초 이하로 설정되지 않았습니다.")
                                    break
                            except ValueError:
                                continue  # Skip lines where the value is not an integer
                else:
                    no_tmout_setting_file += 1

    if file_exists_count == 0 or file_exists_count == no_tmout_setting_file:
        results["진단 결과"] = "취약"
        results["현황"].append("AIX 세션 타임아웃을 적절히 설정한 파일이 없습니다.")

    return results

def main():
    session_timeout_check_results_aix = check_session_timeout_aix()
    print(json.dumps(session_timeout_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
