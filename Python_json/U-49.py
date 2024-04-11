#!/usr/bin/python3
import json
import pwd
import os

def check_unnecessary_accounts_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-49",
        "위험도": "하",
        "진단 항목": "불필요한 계정 제거 (AIX)",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "불필요한 계정이 존재하지 않도록 관리 (AIX)"
    }

    # AIX specific shells and unnecessary accounts list
    aix_login_shells = ["/usr/bin/ksh", "/usr/bin/bash", "/bin/ksh", "/bin/bash", "/usr/bin/csh", "/bin/csh"]
    unnecessary_accounts = [
        "user", "test", "guest", "info", "adm", "mysql", "user1", "lp", "uucp"
    ]

    all_accounts = pwd.getpwall()
    found_accounts = []
    for account in all_accounts:
        if account.pw_shell in aix_login_shells and account.pw_name in unnecessary_accounts:
            found_accounts.append(account.pw_name)

    if found_accounts:
        results["진단 결과"] = "취약"
        results["현황"].append("불필요한 계정이 존재합니다: " + ", ".join(found_accounts))
    else:
        results["현황"].append("불필요한 계정이 존재하지 않습니다.")

    return results

def main():
    unnecessary_accounts_check_results_aix = check_unnecessary_accounts_aix()
    print(json.dumps(unnecessary_accounts_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
