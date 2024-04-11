#!/usr/bin/python3
import subprocess
import re
import json

def check_ftp_service_on_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-61",
        "위험도": "하",
        "진단 항목": "FTP 서비스 확인",
        "진단 결과": "",
        "현황": [],
        "대응방안": "FTP 서비스가 비활성화 되어 있는 경우"
    }

    # Checking /etc/services for FTP port
    try:
        with open('/etc/services', 'r') as file:
            services_content = file.read()
            if "ftp" in services_content:
                results["현황"].append("/etc/services 파일에 FTP 서비스 포트 설정됨.")
    except FileNotFoundError:
        results["현황"].append("/etc/services 파일을 찾을 수 없습니다.")

    # Checking for running FTP service using lssrc command
    lssrc_output = subprocess.run(['lssrc', '-s', 'ftpd'], stdout=subprocess.PIPE, text=True).stdout
    if "active" in lssrc_output:
        results["현황"].append("FTP 서비스가 실행 중입니다.")
    else:
        results["현황"].append("FTP 서비스가 비활성화되어 있습니다.")

    # Check for the existence of common FTP configuration files
    ftp_config_files = ['/etc/vsftpd/vsftpd.conf', '/etc/proftpd.conf']
    for config_file in ftp_config_files:
        if os.path.exists(config_file):
            results["현황"].append(f"{config_file} 파일이 존재합니다.")

    # Finalize the result based on findings
    if "FTP 서비스가 실행 중입니다." in results["현황"] or any("파일이 존재합니다." in status for status in results["현황"]):
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        if len(results["현황"]) == 0:  # No FTP related configurations or active services were found
            results["현황"].append("FTP 서비스 관련 항목이 시스템에 존재하지 않습니다.")

    return results

def main():
    ftp_check_results = check_ftp_service_on_aix()
    print(json.dumps(ftp_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
