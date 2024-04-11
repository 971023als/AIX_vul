#!/usr/bin/python3
import subprocess
import os
import json

def check_ftp_root_access_restriction():
    results = {
        "분류": "서비스 관리",
        "코드": "U-64",
        "위험도": "중",
        "진단 항목": "ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": [],
        "대응방안": "FTP 서비스가 활성화된 경우 root 계정 접속을 차단"
    }

    # AIX-specific paths for FTP user list files
    ftpusers_files = [
        "/etc/ftpusers",  # Standard location
        # Additional locations depending on the FTP server used (if custom FTP servers are installed)
    ]

    # AIX uses inetd for FTP by default; check inetd.conf for FTP service
    ftp_service_active = False
    if os.path.exists("/etc/inetd.conf"):
        with open("/etc/inetd.conf", 'r') as inetd_conf:
            for line in inetd_conf:
                if "ftp" in line and not line.strip().startswith("#"):
                    ftp_service_active = True
                    break

    if not ftp_service_active:
        results["현황"].append("FTP 서비스가 inetd를 통해 비활성화되어 있습니다.")
        results["진단 결과"] = "양호"
        return results

    root_access_restricted = False

    for ftpusers_file in ftpusers_files:
        if os.path.exists(ftpusers_file):
            with open(ftpusers_file, 'r') as file:
                if 'root' in file.read():
                    root_access_restricted = True
                    break

    if root_access_restricted:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 서비스 root 계정 접근이 제한되어 있습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다.")

    return results

def main():
    ftp_root_access_restriction_check_results = check_ftp_root_access_restriction()
    print(json.dumps(ftp_root_access_restriction_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
