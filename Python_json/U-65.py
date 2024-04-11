#!/usr/bin/python3
import os
import stat
import pwd
import json

def check_at_service_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-65",
        "위험도": "중",
        "진단 항목": "at 서비스 권한 설정",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": [],
        "대응방안": "일반 사용자의 at 명령어 사용 금지 및 관련 파일 권한 640 이하 설정"
    }

    # AIX-specific paths for at service access control files
    at_access_control_files = ["/var/adm/cron/at.allow", "/var/adm/cron/at.deny"]

    # Check permissions for at.allow and at.deny files
    for file_path in at_access_control_files:
        if os.path.isfile(file_path):
            st = os.stat(file_path)
            permissions = stat.S_IMODE(st.st_mode)
            file_owner = pwd.getpwuid(st.st_uid).pw_name
            if file_owner != "root" or permissions > 0o640:
                results["진단 결과"] = "취약"
                permission_str = oct(permissions)[-3:]
                results["현황"].append(f"{file_path} 파일의 소유자가 {file_owner}이고, 권한이 {permission_str}입니다.")
        else:
            results["현황"].append(f"{file_path} 파일이 존재하지 않습니다.")

    # If no issues were added to 현황, update the diagnosis result to 양호
    if not results["현황"]:
        results["진단 결과"] = "양호"
        results["현황"].append("at 서비스 관련 파일이 적절한 권한 설정을 가지고 있습니다.")

    return results

def main():
    at_service_permission_check_results = check_at_service_permissions()
    print(json.dumps(at_service_permission_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

