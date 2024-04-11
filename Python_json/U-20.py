#!/usr/bin/python3
import subprocess
import json
import pwd

def check_anonymous_ftp_aix():
    results = {
        "분류": "시스템 설정",
        "코드": "U-20",
        "위험도": "상",
        "진단 항목": "Anonymous FTP 비활성화 (AIX)",
        "진단 결과": "",
        "현황": [],
        "대응방안": "[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우\n[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우"
    }

    try:
        pwd.getpwnam('ftp')
        results["진단 결과"] = "취약"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 있습니다.")
    except KeyError:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 없습니다.")

    # Additional AIX-specific checks can be added here
    # For example, checking the FTP service status:
    try:
        ftp_service_status = subprocess.run(['lssrc', '-s', 'ftpd'], capture_output=True, text=True)
        if 'active' in ftp_service_status.stdout:
            results["진단 결과"] = "취약"
            results["현황"].append("FTP 서비스가 활성화되어 있습니다.")
    except Exception as e:
        results["현황"].append(f"FTP 서비스 상태 확인 중 오류 발생: {str(e)}")

    return results

def main():
    results = check_anonymous_ftp_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

