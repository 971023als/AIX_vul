#!/usr/bin/python3
import os
import subprocess
import json

def check_r_services_disabled_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-21",
        "위험도": "상",
        "진단 항목": "r 계열 서비스 비활성화 (AIX)",
        "진단 결과": "양호",  # Assume services are disabled until found otherwise
        "현황": [],
        "대응방안": "불필요한 r 계열 서비스 비활성화"
    }

    r_commands = ["rsh", "rlogin", "rexec", "shell", "login", "exec"]
    xinetd_dir = "/etc/xinetd.d"
    inetd_conf = "/etc/inetd.conf"
    vulnerable_services = []

    # xinetd.d 아래 서비스 검사
    if os.path.isdir(xinetd_dir):
        for r_command in r_commands:
            service_path = os.path.join(xinetd_dir, r_command)
            if os.path.isfile(service_path):
                with open(service_path, 'r') as file:
                    if 'disable = no' in file.read():
                        vulnerable_services.append(r_command)

    # inetd.conf 아래 서비스 검사
    if os.path.isfile(inetd_conf):
        with open(inetd_conf, 'r') as file:
            inetd_contents = file.read()
            for r_command in r_commands:
                if r_command in inetd_contents:
                    vulnerable_services.append(r_command)

    for service in r_services:
        try:
            src_status = subprocess.run(['lssrc', '-s', service], capture_output=True, text=True)
            if 'active' in src_status.stdout.lower():
                vulnerable_services.append(service)
        except Exception as e:
            results["현황"].append(f"{service} 서비스 상태 확인 중 오류: {str(e)}")
    
    if vulnerable_services:
        results["진단 결과"] = "취약"
        results["현황"].append(f"불필요한 r 계열 서비스가 실행 중입니다: {', '.join(vulnerable_services)}")
    else:
        results["현황"].append("모든 r 계열 서비스가 비활성화되어 있습니다.")

    return results

def main():
    results = check_r_services_disabled_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
