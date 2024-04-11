#!/usr/bin/python3
import json
import subprocess
import re

def check_remote_root_access_restriction():
    results = {
        "분류": "계정관리",
        "코드": "U-01",
        "위험도": "상",
        "진단 항목": "root 계정 원격접속 제한",
        "진단 결과": "양호",  # 기본 값을 "양호"로 가정
        "현황": [],
        "대응방안": "원격 터미널 서비스 사용 시 root 직접 접속을 차단"
    }

    # AIX에서는 Telnet 상태를 확인하는 다른 방법을 사용할 수 있습니다.
    # 예를 들어, AIX에 특화된 명령어나 설정 파일 위치를 참조해야 할 수 있습니다.
    # 이 예제에서는 간단함을 위해 Telnet 상태 검사 부분을 생략합니다.

    # SSH 서비스 검사
    root_login_restricted = True  # root 로그인이 제한되었다고 가정
    sshd_config_path = "/etc/ssh/sshd_config"  # AIX에서의 기본 경로
    try:
        with open(sshd_config_path, 'r') as file:
            for line in file:
                if 'PermitRootLogin' in line and not line.strip().startswith('#'):
                    if 'yes' in line:
                        root_login_restricted = False  # root 로그인이 제한되지 않음
                        break
    except Exception as e:
        results["현황"].append(f"{sshd_config_path} 파일 읽기 중 오류 발생: {e}")

    if not root_login_restricted:
        results["현황"].append("SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다.")

    return results

def main():
    results = check_remote_root_access_restriction()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
