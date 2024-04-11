#!/usr/bin/python3
import json
import subprocess

def check_password_min_usage_period_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-48",
        "위험도": "중",
        "진단 항목": "패스워드 최소 사용기간 설정 (AIX)",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "패스워드 최소 사용기간 1일 이상으로 설정 (AIX)"
    }

    # Use the lssec command to query the minage attribute from the /etc/security/user file
    try:
        output = subprocess.check_output(
            ['lssec', '-f', '/etc/security/user', '-s', 'default', '-a', 'minage'],
            text=True
        ).strip()
        minage_setting = output.split('=')[1] if '=' in output else None

        if minage_setting and minage_setting.isdigit():
            min_days = int(minage_setting) * 7  # Convert weeks to days
            if min_days < 1:
                results["진단 결과"] = "취약"
                results["현황"].append(f"패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다: 설정값 {minage_setting}주({min_days}일).")
            else:
                results["현황"].append(f"패스워드 최소 사용 기간이 적절히 설정되어 있습니다: 설정값 {minage_setting}주({min_days}일).")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("패스워드 최소 사용 기간 설정이 적절하게 구성되지 않았거나 기본 설정을 사용 중입니다.")

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"패스워드 최소 사용 기간 설정을 확인하는 도중 오류 발생: {e}")

    return results

def main():
    password_min_usage_period_check_results_aix = check_password_min_usage_period_aix()
    print(json.dumps(password_min_usage_period_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

