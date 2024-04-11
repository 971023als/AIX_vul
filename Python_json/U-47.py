#!/usr/bin/python3
import json
import subprocess

def check_password_max_usage_period_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-47",
        "위험도": "중",
        "진단 항목": "패스워드 최대 사용기간 설정 (AIX)",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "패스워드 최대 사용기간 90일 이하로 설정 (AIX)"
    }

    # Use the lssec command to query the maxage attribute from the /etc/security/user file
    try:
        output = subprocess.check_output(
            ['lssec', '-f', '/etc/security/user', '-s', 'default', '-a', 'maxage'],
            text=True
        ).strip()
        maxage_setting = output.split('=')[1] if '=' in output else None

        if maxage_setting and maxage_setting.isdigit():
            max_days = int(maxage_setting) * 7  # Convert weeks to days
            if max_days > 90:
                results["진단 결과"] = "취약"
                results["현황"].append(f"패스워드 최대 사용 기간이 90일을 초과하여 {max_days}일로 설정되어 있습니다. (설정값: {maxage_setting}주)")
            else:
                results["현황"].append(f"패스워드 최대 사용 기간이 적절하게 설정되어 있습니다: {max_days}일.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("패스워드 최대 사용 기간 설정이 적절하게 구성되지 않았거나 기본 설정을 사용 중입니다.")

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"패스워드 최대 사용 기간 설정을 확인하는 도중 오류 발생: {e}")

    return results

def main():
    password_max_usage_period_check_results_aix = check_password_max_usage_period_aix()
    print(json.dumps(password_max_usage_period_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

