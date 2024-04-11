#!/usr/bin/python3
import os
import stat
import json

def check_file_ownership_and_permissions(file_path):
    try:
        file_stat = os.stat(file_path)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root and permissions are 600 or more
        if owner_uid == 0 and int(mode, 8) >= 0o600:
            return False
        else:
            return True
    except FileNotFoundError:
        # File does not exist
        return None

def check_directory_files_ownership_and_permissions(directory_path):
    if not os.path.exists(directory_path) or not os.path.isdir(directory_path):
        return None

    files_check_result = True
    for root, _, files in os.walk(directory_path):
        for name in files:
            file_path = os.path.join(root, name)
            if check_file_ownership_and_permissions(file_path):
                files_check_result = False
                break
    return files_check_result

def main():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-10",
        "위험도": "상",
        "진단 항목": "/etc/(x)inetd.conf 파일 소유자 및 권한 설정",
        "진단 결과": None,
        "현황": [],
        "대응방안": "/etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 미만인 경우"
    }

    files_to_check = ['/etc/inetd.conf', '/etc/xinetd.conf']
    directories_to_check = ['/etc/xinetd.d']
    check_passed = True

    for file_path in files_to_check:
        file_check = check_file_ownership_and_permissions(file_path)
        if file_check is False:
            results["현황"].append(f"{file_path} 파일의 소유자가 root이고, 권한이 600 이상입니다.")
            check_passed = False
        elif file_check is None:
            results["현황"].append(f"{file_path} 파일이 없습니다.")

    for directory_path in directories_to_check:
        directory_check = check_directory_files_ownership_and_permissions(directory_path)
        if directory_check is False:
            results["현황"].append(f"{directory_path} 디렉터리 내 파일 중 소유자가 root이고, 권한이 600 이상인 파일이 있습니다.")
            check_passed = False
        elif directory_check is None:
            results["현황"].append(f"{directory_path} 디렉터리가 없습니다.")

    results["진단 결과"] = "양호" if check_passed else "취약"

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
