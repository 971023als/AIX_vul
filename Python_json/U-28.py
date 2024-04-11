#!/usr/bin/python3
import subprocess
import json

def check_nis_services_status_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-28",
        "위험도": "상",
        "진단 항목": "NIS, NIS+ 점검 (AIX)",
        "진단 결과": "양호",  # Assume services are disabled by default
        "현황": [],
        "대응방안": "NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
    }

    # Check NIS service status using SRC commands
    nis_services = ['ypserv', 'ypbind', 'yppasswdd', 'ypupdated', 'ypxfrd']
    active_services = []

    for service in nis_services:
        cmd = ['lssrc', '-s', service]
        process = subprocess.run(cmd, capture_output=True, text=True)
        
        if 'active' in process.stdout:
            active_services.append(service)

    if active_services:
        results["진단 결과"] = "취약"
        results["현황"].append(f"NIS 서비스가 실행 중입니다: {', '.join(active_services)}")
    else:
        results["현황"].append("NIS 서비스가 비활성화되어 있습니다.")

    return results

def main():
    results = check_nis_services_status_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

