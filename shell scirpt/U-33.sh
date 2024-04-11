#!/usr/bin/python3
import subprocess
import json
import re

def parse_version(version_string):
    """Parse version string to a tuple of integers."""
    return tuple(map(int, re.findall(r'\d+', version_string)))

def get_bind_version_aix():
    """Get BIND version on AIX using lslpp."""
    try:
        output = subprocess.check_output("lslpp -L all | grep -i 'bind.base'", shell=True, text=True).strip()
        return output
    except subprocess.CalledProcessError:
        return ""

def check_dns_security_patch():
    results = {
        "분류": "서비스 관리",
        "코드": "U-33",
        "위험도": "상",
        "진단 항목": "DNS 보안 버전 패치",
        "진단 결과": "양호",  # Default state
        "현황": [],
        "대응방안": "DNS 서비스 주기적 패치 관리"
    }

     minimum_version = "9.18.7"  # Adjust based on actual security requirements

    bind_version_output = get_bind_version_aix()

    if bind_version_output:
        version_match = re.search(r'bind.base\w+\s+(\d+\.\d+\.\d+)', bind_version_output)
        if version_match:
            current_version = version_match.group(1)
            if parse_version(current_version) < parse_version(minimum_version):
                results["진단 결과"] = "취약"
                results["현황"].append(f"BIND 버전이 최신 보안 버전({minimum_version}) 이상이 아닙니다: {current_version}")
            else:
                results["현황"].append(f"BIND 버전이 최신 보안 버전({minimum_version}) 이상입니다: {current_version}")
        else:
            results["진단 결과"] = "오류"
            results["현황"].append("BIND 버전 확인 중 오류 발생 (버전 정보 없음)")
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("BIND가 설치되어 있지 않거나 lslpp 명령어 실행 실패")

    return results

def main():
    results = check_dns_security_patch()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
