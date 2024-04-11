#!/usr/bin/python3
import os
import json
import grp

def check_admin_group_accounts_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-50",
        "위험도": "하",
        "진단 항목": "AIX 관리자 그룹에 최소한의 계정 포함 (AIX)",
        "진단 결과": "양호",  # 기본적으로 "양호"로 가정
        "현황": [],
        "대응방안": "관리자 그룹(system, security)에 불필요한 계정이 등록되지 않도록 관리 (AIX)"
    }

    # AIX-specific administrative groups and potential unnecessary accounts
    admin_groups = ["system", "security"]
    unnecessary_accounts = [
        "daemon", "bin", "sys", "adm", "uucp", "guest", "nobody",
        "lpd", "lp", "invscout", "snapp", "ipsec", "nuucp", "pconsole",
        "esaadmin", "esearch", "eservice", "cron", "mqm", "postgres", "mysql"
    ]

    for group_name in admin_groups:
        try:
            grp_info = grp.getgrnam(group_name)
            found_accounts = [acc for acc in grp_info.gr_mem if acc in unnecessary_accounts]
            if found_accounts:
                results["진단 결과"] = "취약"
                results["현황"].append(f"AIX 관리자 그룹({group_name})에 불필요한 계정이 등록되어 있습니다: " + ", ".join(found_accounts))
            else:
                results["현황"].append(f"AIX 관리자 그룹({group_name})에 불필요한 계정이 없습니다.")
        except KeyError:
            # This group does not exist on the system
            results["현황"].append(f"AIX 관리자 그룹({group_name})을 찾을 수 없습니다.")

    return results

def main():
    admin_group_accounts_check_results_aix = check_admin_group_accounts_aix()
    print(json.dumps(admin_group_accounts_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

