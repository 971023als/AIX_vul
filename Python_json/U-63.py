#!/usr/bin/python3
import os
import stat
import json

def check_ftpusers_file_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-63",
        "위험도": "하",
        "진단 항목": "ftpusers 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "ftpusers 파일의 소유자를 root로 설정하고, 권한을 640 이하로 설정"
    }

    # AIX specific common paths for ftpusers, adjust as needed based on the FTP server used
    ftpusers_files = [
        "/etc/ftpusers",  # Common path
        # Add or remove paths based on the specific FTP server software and custom configurations
    ]

    file_checked_and_secure = False

    for ftpusers_file in ftpusers_files:
        if os.path.isfile(ftpusers_file):
            file_checked_and_secure = True
            st = os.stat(ftpusers_file)
            mode = st.st_mode
            owner = st.st_uid
            permissions = stat.S_IMODE(mode)

            if owner != 0 or permissions > 0o640:
                results["진단 결과"] = "취약"
                if owner != 0:
                    results["현황"].append(f"{ftpusers_file} 파일의 소유자(owner)가 root가 아닙니다.")
                if permissions > 0o640:
                    results["현황"].append(f"{ftpusers_file} 파일의 권한이 640보다 큽니다.")

    if not results["현황"]:
        if file_checked_and_secure:
            results["진단 결과"] = "양호"
            results["현황"].append("모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("ftp 접근제어 파일이 없습니다.")

    return results

def main():
    ftpusers_file_check_results = check_ftpusers_file_permissions()
    print(json.dumps(ftpusers_file_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
