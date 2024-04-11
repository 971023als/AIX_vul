#!/usr/bin/python3
import subprocess
import re
import json

def check_finger_service_disabled_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-19",
        "위험도": "상",
        "진단 항목": "Finger 서비스 비활성화 (AIX)",
        "진단 결과": "양호",  # Assume the service is disabled by default
        "현황": [],
        "대응방안": "Finger 서비스가 비활성화 되어 있는 경우"
    }

    # /etc/services에서 Finger 서비스 정의 확인
    try:
        with open('/etc/inetd.conf', 'r') as inetd_conf:
            for line in inetd_conf:
                if 'finger' in line and not line.startswith('#'):
                    results["현황"].append("/etc/inetd.conf에 Finger 서비스 활성화")
                    results["진단 결과"] = "취약"
                    break
    except FileNotFoundError:
        results["현황"].append("/etc/inetd.conf 파일을 찾을 수 없습니다.")

    # Finger 프로세스 실행 중인지 확인
    try:
        src_status = subprocess.run(['lssrc', '-s', 'fingerd'], capture_output=True, text=True)
        if 'active' in src_status.stdout.lower():
            results["현황"].append("Finger 서비스가 SRC에 의해 활성화되어 있습니다.")
            results["진단 결과"] = "취약"
    except Exception as e:
        results["현황"].append(f"Finger 서비스 상태 확인 중 오류 발생: {str(e)}")

    if not results["현황"]:
        results["현황"].append("Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다.")

    return results

def main():
    results = check_finger_service_disabled_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
