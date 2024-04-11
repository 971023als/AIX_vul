#!/usr/bin/python3
import os
import stat
import json

def check_cron_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-22",
        "위험도": "상",
        "진단 항목": "crond 파일 소유자 및 권한 설정 (AIX)",
        "진단 결과": "양호",  # Assume compliance until a violation is found
        "현황": [],
        "대응방안": "crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
    }

    # Check crontab command permissions
    crontab_path = "/usr/bin/crontab"  # Common path; adjust if necessary for AIX
    if os.path.exists(crontab_path):
        validate_file(crontab_path, 750, results)

    # Directories and files to check
    cron_paths = [
        "/etc/crontab", "/etc/cron.allow", "/etc/cron.deny",
        "/var/spool/cron", "/var/spool/cron/crontabs",  # AIX specific paths included
        "/etc/cron.hourly", "/etc/cron.daily", "/etc/cron.weekly", "/etc/cron.monthly"
    ]

    # Check permissions and ownership of cron files and directories
    for path in cron_paths:
        if os.path.isdir(path):
            for root, dirs, files in os.walk(path):
                for name in files:
                    validate_file(os.path.join(root, name), 640, results)
        else:
            validate_file(path, 640, results)

    return results

def validate_file(path, permission_limit, results):
    if os.path.exists(path):
        mode = os.stat(path).st_mode
        permission = int(oct(mode)[-3:])
        owner = os.stat(path).st_uid

        if owner != 0 or permission > permission_limit:
            results["진단 결과"] = "취약"
            if owner != 0:
                results["현황"].append(f"{path} 파일의 소유자(owner)가 root가 아닙니다.")
            if permission > permission_limit:
                results["현황"].append(f"{path} 파일의 권한이 {permission_limit}보다 큽니다.")

def main():
    results = check_cron_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
