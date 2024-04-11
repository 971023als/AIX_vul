#!/usr/bin/python3
import os
import json
import pwd
import grp

def check_for_unnecessary_groups_aix():
    results = {
        "분류": "계정관리",
        "코드": "U-51",
        "위험도": "하",
        "진단 항목": "AIX: 계정이 존재하지 않는 GID 금지",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "AIX: 계정이 없는 불필요한 그룹 삭제"
    }

    # Getting all GIDs used in the system
    gids_in_use = {user.pw_gid for user in pwd.getpwall()}

    # Getting all group names and GIDs
    groups = grp.getgrall()
    unnecessary_groups = [group.gr_name for group in groups if group.gr_gid not in gids_in_use and group.gr_gid >= 200]

    if unnecessary_groups:
        results["진단 결과"] = "취약"
        results["현황"].append("계정이 없는 불필요한 그룹이 존재합니다: " + ", ".join(unnecessary_groups))
    else:
        results["현황"].append("계정이 없는 불필요한 그룹이 존재하지 않습니다.")

    return results

def main():
    unnecessary_groups_check_results_aix = check_for_unnecessary_groups_aix()
    print(json.dumps(unnecessary_groups_check_results_aix, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

