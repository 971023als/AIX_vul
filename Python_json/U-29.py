#!/usr/bin/python3
import subprocess
import os
import re
import json

def check_service_status_with_src(service_name):
    """Check if a service is active using the lssrc command."""
    cmd = ['lssrc', '-s', service_name]
    process = subprocess.run(cmd, capture_output=True, text=True)
    return 'active' in process.stdout

def check_tftp_talk_services_disabled_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-29",
        "위험도": "상",
        "진단 항목": "tftp, talk 서비스 비활성화 (AIX)",
        "진단 결과": "양호",  # Assume services are disabled by default
        "현황": [],
        "대응방안": "tftp, talk, ntalk 서비스 비활성화"
    }

    services = ["tftp", "talk", "ntalk"]
    service_found = False

    # Check for inetd-managed services in /etc/inetd.conf
    if os.path.isfile("/etc/inetd.conf"):
        with open("/etc/inetd.conf", 'r') as file:
            inetd_contents = file.read()
            for service in services:
                if re.search(f"^{service}\s", inetd_contents, re.MULTILINE) and not re.search(f"^#.*{service}\s", inetd_contents, re.MULTILINE):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{service} 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
                    service_found = True

    # /etc/inetd.conf 파일 내 서비스 검사
    if os.path.isfile(inetd_conf):
        with open(inetd_conf, 'r') as file:
            content = file.read()
            for service in services:
                if re.search(f"^{service}\s", content, re.MULTILINE):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{service} 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
                    service_found = True

    if not service_found:
        results["진단 결과"] = "양호"
        results["현황"].append("tftp, talk, ntalk 서비스가 모두 비활성화되어 있습니다.")

    return results

def main():
    results = check_tftp_talk_services_disabled_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()