#!/usr/bin/python3
import subprocess
import json

def check_service_status(service_name):
    """Check the status of a service using AIX-specific commands."""
    try:
        # Use 'lssrc' on AIX to check service status
        output = subprocess.check_output(['lssrc', '-s', service_name], text=True)
        if "active" in output:
            return "활성화"
        else:
            return "비활성화"
    except subprocess.CalledProcessError:
        return "서비스가 설치되지 않았거나 확인할 수 없습니다."

def check_ssh_telnet_services():
    results = {
        "분류": "서비스 관리",
        "코드": "U-60",
        "위험도": "중",
        "진단 항목": "ssh 원격접속 허용",
        "진단 결과": "",
        "현황": {
            "SSH 서비스 상태": check_service_status('sshd'),
            "Telnet 서비스 상태": check_service_status('telnet'),
            "FTP 서비스 상태": check_service_status('ftpd')
        },
        "대응방안": "SSH 사용 권장, Telnet 및 FTP 사용하지 않도록 설정"
    }

    # Determine overall security status
    if results["현황"]["SSH 서비스 상태"] == "활성화" and results["현황"]["Telnet 서비스 상태"] == "비활성화" and results["현황"]["FTP 서비스 상태"] == "비활성화":
        results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "취약"

    return results

def main():
    security_check_results = check_ssh_telnet_services()
    print(json.dumps(security_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

